# 容器后置配置

所有命令通过 `ssh <host> "docker exec <container> bash -c '...'"` 执行。

## 1. 安装并启动 SSH

```bash
apt update && apt install -y openssh-server
mkdir -p /run/sshd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh start
echo "root:1234" | chpasswd
```

然后配置 SSH 开机自启（容器重启后自动生效）：

```bash
# 写入 entrypoint 补丁，确保每次容器启动时 sshd 运行
cat >> /root/.bashrc <<'EOF'
if ! pgrep sshd > /dev/null 2>&1; then
  service ssh start 2>/dev/null
fi
EOF
```

## 2. 部署公钥

使用 `ssh-copy-id` 从本地直接部署：

```bash
ssh-copy-id -p <port> root@<host>
```

如果 `ssh-copy-id` 不可用或端口映射需要通过跳板，退回到手动方式：

```bash
ssh <host> "docker exec -i <container> bash -c 'mkdir -p /root/.ssh && chmod 700 /root/.ssh && cat > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'" < ~/.ssh/id_rsa.pub
```

## 3. Locale 配置

```bash
apt install -y locales
locale-gen en_US.UTF-8
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc
```

## 4. 测试连接

```bash
ssh -p <port> root@<host> "whoami"
# 预期输出：root
```

## 5. 添加本地 SSH 配置

```
Host <alias>
  HostName <ip>
  User root
  Port <port>
```

## 备注

- 所有默认密码为 `1234`，提醒用户生产环境需修改
