# Docker 启动 MySQL 与 Redis（远程 Ubuntu / 本机通用）

## 前置

- 已安装 Docker 与 Docker Compose 插件。
- 在 `backend` 目录下操作。

## 1. 准备密钥文件

```bash
cd backend
cp .env.docker.example .env.docker
# 编辑 .env.docker，设置 MYSQL_ROOT_PASSWORD、MYSQL_USER、MYSQL_PASSWORD
```

`backend/.env` 中的 `DATABASE_URL` 必须使用**与 `.env.docker` 相同的** `MYSQL_USER` / `MYSQL_PASSWORD`，且主机为 `127.0.0.1`、库名为 `social_app`：

```env
DATABASE_URL=mysql+pymysql://social_app:你的应用密码@127.0.0.1:3306/social_app
REDIS_URL=redis://127.0.0.1:6379/0
```

## 2. 启动容器

```bash
sudo docker compose -f docker-compose.db.yml up -d
sudo docker ps
```

端口仅绑定 `127.0.0.1`，公网无法直连 MySQL/Redis。

## 3. 数据库迁移

在已配置 Python 虚拟环境与 `pip install -r requirements.txt` 的前提下：

```bash
alembic upgrade head
```

## 4. 验证

```bash
# Redis
redis-cli -h 127.0.0.1 -p 6379 ping
# 期望: PONG

# FastAPI（需先启动 uvicorn）
curl -s http://127.0.0.1:8000/health
```

## 5. 停止与数据（谨慎）

```bash
sudo docker compose -f docker-compose.db.yml down
```

数据卷 `mysql_data`、`redis_data` 会保留；若需清空，使用 `docker volume rm`（会丢失数据）。
