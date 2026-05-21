---
name: ssh-server-and-container-setup
description: 通过 SSH 远程配置 Linux 服务器用户和 Docker 容器。自动化用户创建、公钥部署、GPU 容器创建、容器内 SSH 配置、本地 ~/.ssh/config 管理。当用户说"配置服务器"、"创建容器"、"添加用户"、"setup server"、"create container"时触发。
---

# 服务器 & 容器配置

## 快速开始

1. 询问用户：目标服务器（从已有 SSH config 中选）、要创建的用户名
2. 执行 5 步工作流，每步执行前确认

## 前置条件

- 本地公钥 `~/.ssh/id_rsa.pub`
- 目标服务器上有 sudo 权限的账户（已在 SSH config 中配置）
- SSH 配置文件 `~/.ssh/config`

## 工作流

### 第 0 步：环境检查

先检查 sudo 是否免密，这决定后续步骤的执行方式：

```bash
ssh <sudo_host> "sudo -n true 2>/dev/null && echo 'SUDO_NOPASSWD' || echo 'SUDO_NEEDS_PASSWORD'"
```

- **SUDO_NOPASSWD**：后续步骤可直接通过 SSH 远程执行 sudo 命令
- **SUDO_NEEDS_PASSWORD**：sudo 命令无法通过非交互式 SSH 执行，需要让用户在终端手动执行（提示用户 `! ssh <sudo_host>` 进入交互式会话）

### 第 1 步：创建用户

通过有 sudo 权限的账户 SSH 到目标服务器。先检查用户是否已存在：

```bash
ssh <sudo_host> "id <username> 2>/dev/null && echo 'USER_EXISTS' || echo 'USER_OK'"
```

如果已存在，询问用户是跳过还是删除重建。确认后创建用户，密码设为 `1234`。询问用户："用默认值 (docker,users + /bin/bash) 还是手动指定？"（注意：需要 Docker 访问的用户必须加入 `docker` 组）

如果 sudo 免密：
```bash
ssh <sudo_host> "sudo useradd -m -G <groups> -s <shell> <username> && echo '<username>:1234' | sudo chpasswd"
```

如果 sudo 需要密码，给出命令让用户在终端手动执行：
```bash
sudo useradd -m -G <groups> -s <shell> <username> && echo '<username>:1234' | sudo chpasswd
```

### 第 2 步：部署公钥 + 本地配置

用户已创建且密码为 `1234`，**优先用 `ssh-copy-id`**：

```bash
ssh-copy-id <username>@<host>
```

如果 `ssh-copy-id` 提示输入密码，输入 `1234`。注意：`ssh-copy-id` 需要交互式输入密码，如果本机没有 `sshpass`，请让用户在终端手动执行（`! ssh-copy-id <username>@<host>`）。

仅在 `ssh-copy-id` 不可用时，才通过 sudo 用户操作：

```bash
ssh <sudo_host> "sudo mkdir -p /home/<username>/.ssh && sudo tee /home/<username>/.ssh/authorized_keys" < ~/.ssh/id_rsa.pub
ssh <sudo_host> "sudo chown -R <username>:<username> /home/<username>/.ssh && sudo chmod 700 /home/<username>/.ssh && sudo chmod 600 /home/<username>/.ssh/authorized_keys"
```

追加到 `~/.ssh/config`：
```
Host <hostname>
  HostName <ip>
  User <username>
  Port 22
  [ProxyJump <jump_host>]
```

验证：`ssh <hostname> "whoami"` 应返回 `<username>`。

### 第 3 步：选择 Docker 镜像

SSH 到目标服务器，先检查 GPU 状态，再列出已有镜像：

```bash
ssh <hostname> "nvidia-smi --query-gpu=index,name,memory.used,memory.total --format=csv,noheader"
ssh <hostname> "docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}'"
```

展示 GPU 状态和镜像列表让用户选择。

### 第 4 步：创建容器

先检查容器名和端口是否已被占用：

```bash
ssh <hostname> "docker ps -a --filter name=<container_name> --format '{{.Names}}'"
ssh <hostname> "ss -tlnp | grep ':<port>'"
```

选择可用端口（建议范围 2000-2999，按顺序检查）。

使用 [references/docker-templates.md](references/docker-templates.md) 中的模板，根据服务器适配挂载路径。展示最终 `docker run` 命令让用户确认后执行。

### 第 5 步：容器内 SSH 配置

进入容器，安装配置 SSH，设 root 密码 `1234`，部署公钥，测试连接，添加本地 Host 条目。

详见 [references/container-post-setup.md](references/container-post-setup.md)。

## 注意事项

- **每步执行前必须确认**
- 默认密码均为 `1234`，提醒用户生产环境需修改
