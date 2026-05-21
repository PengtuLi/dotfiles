"""Proxy tunnel setup utilities."""

import os
import select
import subprocess
import time
from pathlib import Path
from queue import Queue
from threading import Thread


def find_available_remote_port(host: str, start_port: int, max_tries: int = 100) -> int:
    """Find an available port on the remote host, starting from start_port."""
    check_cmd = (
        f'ssh {host} "ss -tlnH \\"sport = :{{port}}\\" | grep -q . '
        f'|| (exec 3<>/dev/tcp/127.0.0.1/{{port}} && echo used) 2>/dev/null"'
    )
    for port in range(start_port, start_port + max_tries):
        cmd = check_cmd.format(port=port)
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            return port
    raise RuntimeError(
        f"No available port found in range {start_port}-{start_port + max_tries - 1}"
    )


def setup_simple_proxy(
    host: str, clash_port: int = 7890
) -> tuple[subprocess.Popen, int]:
    """Set up reverse SSH tunnel forwarding local clash proxy to remote."""
    remote_port = find_available_remote_port(host, clash_port)
    proc = subprocess.Popen(
        f"ssh -S none -N -R {remote_port}:127.0.0.1:{clash_port} {host}",
        shell=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    # Poll until tunnel is ready or process exits
    for _ in range(50):  # up to ~10s
        if proc.poll() is not None:
            stderr = proc.stderr.read()
            raise RuntimeError(f"Tunnel failed: {stderr}")
        verify = subprocess.run(
            f'ssh {host} "ss -tlnH \\"sport = :{remote_port}\\" 2>/dev/null | grep -q . '
            f'|| (exec 3<>/dev/tcp/127.0.0.1/{remote_port} 2>/dev/null) && echo OK"',
            shell=True,
            capture_output=True,
            text=True,
        )
        if "OK" in verify.stdout:
            break
        time.sleep(0.2)
    else:
        proc.terminate()
        raise RuntimeError("Proxy port not available on remote")
    return proc, remote_port


def setup_socks_proxy_legacy(
    host: str, local_user: str, tunnel_port: int = 22222, socks_port: int = 1080
) -> Queue:
    """Set up SOCKS5 proxy via reverse SSH tunnel using agent forwarding."""
    result_queue = Queue()

    def _run_tunnel():
        try:
            # Ensure ssh-agent is running
            auth_sock = os.environ.get("SSH_AUTH_SOCK", "")
            if not auth_sock or not Path(auth_sock).exists():
                agent_output = subprocess.run(
                    "ssh-agent -s", shell=True, capture_output=True, text=True
                ).stdout
                for line in agent_output.splitlines():
                    if "SSH_AUTH_SOCK=" in line:
                        os.environ["SSH_AUTH_SOCK"] = line.split("=")[1].split(";")[0]
                    if "SSH_AGENT_PID=" in line:
                        os.environ["SSH_AGENT_PID"] = line.split("=")[1].split(";")[0]
                auth_sock = os.environ.get("SSH_AUTH_SOCK", "")
                if not auth_sock or not Path(auth_sock).exists():
                    result_queue.put((False, "Failed to start ssh-agent."))
                    return

            # Add key to agent if not present
            if (
                subprocess.run("ssh-add -l", shell=True, capture_output=True).returncode
                != 0
            ):
                if subprocess.run("ssh-add", shell=True).returncode != 0:
                    result_queue.put(
                        (False, "Failed to add SSH key. Run 'ssh-add' first.")
                    )
                    return

            # Find available SOCKS port on remote
            socks_port_actual = find_available_remote_port(host, socks_port)

            # Clean up existing SOCKS processes on that port
            subprocess.run(
                f'ssh {host} "pkill -f \\"ssh.*-D {socks_port_actual}\\" 2>/dev/null || true"',
                shell=True,
                capture_output=True,
            )

            # Ensure AllowAgentForwarding on remote
            fwd_check = subprocess.run(
                f'ssh {host} "grep -i AllowAgentForwarding /etc/ssh/sshd_config"',
                shell=True,
                capture_output=True,
                text=True,
            )
            if (
                "#AllowAgentForwarding" in fwd_check.stdout
                or "AllowAgentForwarding" not in fwd_check.stdout
            ):
                subprocess.run(
                    f"ssh -t {host} \"sudo sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/' /etc/ssh/sshd_config; "
                    f'sudo grep -q \\"^AllowAgentForwarding yes\\" /etc/ssh/sshd_config || '
                    f"sudo bash -c 'echo AllowAgentForwarding yes >> /etc/ssh/sshd_config'; "
                    f'sudo systemctl restart sshd"',
                    shell=True,
                )
                time.sleep(1)

            # Kill existing control master to ensure fresh connection with agent forwarding
            subprocess.run(
                f"ssh -O exit {host} 2>/dev/null || true",
                shell=True,
                capture_output=True,
            )

            # Kill any existing processes using tunnel port on remote
            cleanup_result = subprocess.run(
                f'''ssh -S none -A {host} "
                    pkill -9 -f 'ssh.*-R.*{tunnel_port}' 2>/dev/null || true
                    ss -tlpn 2>/dev/null | grep ':{tunnel_port}' | awk '{{print \$6}}' | xargs -r kill -9 2>/dev/null || true
                    lsof -ti :{tunnel_port} | xargs -r kill -9 2>/dev/null || true
                    fuser -k -9 {tunnel_port}/tcp 2>/dev/null || true
                    sleep 1
                "''',
                shell=True,
                capture_output=True,
                text=True,
            )
            time.sleep(1)

            # Create reverse tunnel
            tunnel_proc = subprocess.Popen(
                f"ssh -S none -A -N -R {tunnel_port}:127.0.0.1:22 {host}",
                shell=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
            )
            time.sleep(2)

            # Check for tunnel errors
            stderr_lines = []
            while (
                tunnel_proc.stderr
                in select.select([tunnel_proc.stderr], [], [], 0.1)[0]
            ):
                line = tunnel_proc.stderr.readline()
                if line:
                    stderr_lines.append(line)
                else:
                    break

            if tunnel_proc.poll() is not None:
                result_queue.put(
                    (False, f"Tunnel failed to start: {''.join(stderr_lines)}")
                )
                return

            if any("failed" in line.lower() for line in stderr_lines):
                result_queue.put(
                    (False, f"Port forwarding failed: {''.join(stderr_lines)}")
                )
                tunnel_proc.terminate()
                return

            # Add host key
            subprocess.run(
                f'ssh -S none -A {host} "ssh-keyscan -p {tunnel_port} localhost >> ~/.ssh/known_hosts 2>/dev/null"',
                shell=True,
                capture_output=True,
            )

            # Test tunnel connection
            test = subprocess.run(
                f'ssh -S none -A {host} "ssh -A -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -p {tunnel_port} {local_user}@localhost echo OK 2>&1"',
                shell=True,
                capture_output=True,
                text=True,
                timeout=15,
            )
            if "OK" not in test.stdout:
                result_queue.put((False, f"Tunnel test failed: {test.stdout.strip()}"))
                tunnel_proc.terminate()
                return

            # Start SOCKS proxy
            subprocess.run(
                f'ssh -S none -A {host} "ssh -A -f -N -D {socks_port_actual} -p {tunnel_port} -o StrictHostKeyChecking=accept-new {local_user}@localhost"',
                shell=True,
                capture_output=True,
                text=True,
            )
            time.sleep(1)

            # Verify
            verify_result = subprocess.run(
                f'ssh -S none -A {host} "nc -z 127.0.0.1 {socks_port_actual} && echo OK"',
                shell=True,
                capture_output=True,
                text=True,
            )
            if "OK" not in verify_result.stdout:
                result_queue.put((False, "SOCKS port not available."))
                tunnel_proc.terminate()
                return

            result_queue.put(
                (True, f"SOCKS5 proxy ready on 127.0.0.1:{socks_port_actual}")
            )
            result_queue.put(("tunnel_proc", tunnel_proc))
            result_queue.put(("host", host))
            result_queue.put(("socks_port", socks_port_actual))

        except Exception as e:
            result_queue.put((False, str(e)))

    Thread(target=_run_tunnel, daemon=True).start()
    return result_queue
