# 2026-03-26 后端创建与联调工作总结

## 一、这次后端一共完成了什么

本次完成了从 0 到 1 的后端搭建与 Flutter 联调闭环，核心包括：

1. **FastAPI 项目骨架与统一路由**
   - 完成 `app/main.py`，挂载 `auth / bindings / activities / chat / uploads / users / ws`。
   - 增加 `/health` 检查，便于本地连通性验证。

2. **配置、安全与鉴权体系**
   - 完成 `app/core/config.py`（`.env` 读取、数据库/Redis/JWT/CORS/COS 配置）。
   - 完成 `app/core/security.py`（JWT 编解码、密码哈希/校验）。
   - 通过依赖注入实现登录态校验、角色权限控制（家长/儿童）。

3. **数据库模型与迁移**
   - 完成 SQLAlchemy 模型：用户、家长/儿童资料、绑定码与绑定关系、会话与消息、活动审批等。
   - 完成 Alembic 初始化迁移，支持 `alembic upgrade head` 一键建表。

4. **核心 REST API**
   - **认证**：注册（家长/儿童）、登录、`/auth/me`。
   - **绑定流程**：家长生成绑定码、儿童发起绑定请求、家长审批/拒绝、待审批列表。
   - **聊天**：会话列表、消息列表、发送消息。
   - **用户资料**：头像、儿童资料 PATCH。
   - **活动与审批**：活动发布/列表/加入请求审批流。
   - **上传**：预签名上传接口（COS 可选）。

5. **实时能力与多 worker 支持**
   - 提供 `WebSocket /ws?token=...`。
   - 通过 Redis Pub/Sub 实现服务内外消息推送，聊天与绑定状态更新可实时触达。

6. **联调问题修复（本次关键）**
   - 修复 `User` 与 `ChildProfile` 双外键导致的 relationship 歧义。
   - 修复 `passlib + bcrypt 5.x` 兼容问题（注册时 500）。
   - 本地 CORS 改为显式白名单，匹配 Flutter Web 固定端口联调。

---

## 二、本次后端涉及/修改的关键文件

### 1) 应用入口与配置
- `backend/app/main.py`
- `backend/app/core/config.py`
- `backend/app/core/security.py`
- `backend/.env`
- `backend/.env.example`
- `backend/requirements.txt`

### 2) 数据库与迁移
- `backend/app/db/base.py`
- `backend/app/db/session.py`
- `backend/alembic.ini`
- `backend/alembic/env.py`
- `backend/alembic/versions/001_initial.py`

### 3) 模型层
- `backend/app/models/user.py`
- `backend/app/models/parent_profile.py`
- `backend/app/models/child_profile.py`
- `backend/app/models/bind_code.py`
- `backend/app/models/binding.py`
- `backend/app/models/activity.py`
- `backend/app/models/conversation.py`

### 4) 接口层
- `backend/app/api/deps.py`
- `backend/app/api/routes/auth.py`
- `backend/app/api/routes/bindings.py`
- `backend/app/api/routes/activities.py`
- `backend/app/api/routes/chat.py`
- `backend/app/api/routes/uploads.py`
- `backend/app/api/routes/users.py`
- `backend/app/api/routes/ws.py`

### 5) Schema 与服务
- `backend/app/schemas/auth.py`
- `backend/app/schemas/binding.py`
- `backend/app/schemas/activity.py`
- `backend/app/schemas/chat.py`
- `backend/app/schemas/common.py`
- `backend/app/services/redis_client.py`

---

## 三、这几处代码比较重要（建议优先阅读）

1. **`backend/app/main.py`**
   - 看整体服务是如何拼装的：CORS、路由挂载、启动后可用入口。
   - 定位联调问题时，先确认 `/health` 与路由前缀 `/api/v1`。

2. **`backend/app/api/routes/auth.py` + `backend/app/schemas/auth.py`**
   - 注册/登录/`me` 的主链路。
   - 参数校验规则都在 schema（例如用户名、密码长度），422 排查入口。

3. **`backend/app/core/security.py`**
   - 密码哈希、JWT 签发与解码。
   - 所有认证问题（401、token 失效、密码处理）都与这里直接相关。

4. **`backend/app/api/deps.py`**
   - 认证依赖和角色权限依赖（`require_parent / require_child`）。
   - 多数“权限不对”问题都要从这里看。

5. **`backend/app/api/routes/bindings.py`**
   - 绑定码生成、请求、审批，业务规则最集中。
   - 包含 Redis 限流与事件推送调用，是家长/儿童双端联调核心。

6. **`backend/app/api/routes/chat.py` + `backend/app/api/routes/ws.py` + `backend/app/services/redis_client.py`**
   - 聊天 REST 与 WebSocket 实时通知组合。
   - 理解 Pub/Sub channel 设计（`user:{id}`）后，前后端实时联调会快很多。

7. **`backend/app/models/user.py` 与 `backend/app/models/child_profile.py`**
   - 这次发生过 relationship 歧义，重点理解双外键关系建模。

---

## 四、报错修复总结

1. **前端报 CORS / ERR_FAILED，不一定真是 CORS**
   - 后端内部 500 时，浏览器常表现为 CORS/网络层错误。
   - 先看后端日志，再判断是否真跨域配置问题。

2. **`AmbiguousForeignKeysError`（已修复）**
   - 原因：`child_profiles` 同时有 `user_id` 和 `parent_user_id` 指向 `users`。
   - 修复：在 `User.child_profile` 明确 `foreign_keys="ChildProfile.user_id"`。

3. **注册时报 `password cannot be longer than 72 bytes`（已修复）**
   - 原因：`bcrypt` 5.x 与 passlib 路径下的兼容性问题触发。
   - 修复：`requirements.txt` 增加 `bcrypt<5`，并在 venv 中降级到 4.3.0。

4. **本地联调 CORS 建议**
   - 采用固定端口联调，`.env` 中显式配置：
     - `CORS_ORIGINS=http://localhost:49873,http://127.0.0.1:49873`
   - Flutter Web 使用固定端口运行，减少随机端口导致的跨域问题。

---

## 五、当前可复用的本地启动流程（后端）

1. `cd backend`
2. `python -m venv .venv`
3. `.\.venv\Scripts\Activate.ps1`
4. `pip install -r requirements.txt`
5. `alembic upgrade head`
6. `uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload`
7. 打开 `http://127.0.0.1:8000/health`，返回 `{"status":"ok"}` 即正常

---

## 六、补充

- 当前已确认：使用 6 位密码注册可正常通过，后端主链路可用。
- 后续如果要提升，可以将“密码长度策略（schema）”与hash算法限制进一步对齐，并在前端增加同规则校验，减少 422/500 排查成本。
