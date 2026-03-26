
根据当前仓库里的配置，**需要你亲自填的「地址 / 连接串」**大致如下。

---

## Flutter 端（唯一和「API 根 URL」直接相关）

在 [`lib/config/api_config.dart`](d:\Codefield\Social_APP\lib\config\api_config.dart) 里，**只有编译期变量 `API_BASE_URL`** 需要你按环境自己设：

- **不设或空字符串**：走本地 SQLite，不调远端。
- **设成后端地址**：例如 `http://127.0.0.1:8000`。  
  代码会自动：
  - REST：`{baseUrl}/api/v1/...`
  - WebSocket：把 `http`→`ws`、`https`→`wss`，路径为 `/ws?token=...`（token 由客户端拼好，**不是**你要单独配置的「另一个 URL 参数」）。

典型写法（文档里已有）：

`flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000`  

真机/模拟器若本机不是 `127.0.0.1`，要改成你电脑在局域网里的 IP 或 Android 模拟器常用的 `http://10.0.2.2:8000` 等。

**结论：Flutter 里需要你自己配的「URL」本质上就是这一个 `API_BASE_URL`。**

---

## 后端（`.env`，不全是 URL，但都和「连哪儿」有关）

[`backend/.env.example`](d:\Codefield\Social_APP\backend\.env.example) 与 [`backend/app/core/config.py`](d:\Codefield\Social_APP\backend\app\core\config.py) 对应，你需要按部署环境改的是：

| 变量 | 含义 |
|------|------|
| **`DATABASE_URL`** | MySQL 连接串（含主机、端口、库名、账号密码），必须与你的数据库一致。 |
| **`REDIS_URL`** | Redis 地址，例如 `redis://127.0.0.1:6379/0`。 |
| **`CORS_ORIGINS`** | 允许跨域的来源（如前端 Web 或特定域名）；`*` 表示全开，生产环境通常会改成具体域名。 |

下面这些**不是**「一个统一的 API 根 URL」，而是**对象存储（预签名上传）**相关，只有你要用 COS 预签名时才需要填：

| 变量 | 含义 |
|------|------|
| `COS_REGION` / `COS_BUCKET` | 地域与桶名。 |
| **`COS_DOMAIN`** | 访问桶/文件的域名类配置（文档里说明留空可关闭预签名相关能力）。 |

`JWT_SECRET` 等是密钥/过期时间，**不是 URL**。

---

## 小结

- **App 连后端**：主要配置 **`API_BASE_URL`（Flutter `--dart-define`）**。  
- **后端连数据库/缓存**：配置 **`DATABASE_URL`、`REDIS_URL`**；按需配置 **`CORS_ORIGINS`**。  
- **若启用腾讯云 COS 上传**：在 `.env` 里配置 **COS 相关项（含 `COS_DOMAIN`）**。  

没有另一套「很多个分散的 URL 参数」要逐个在代码里写死；REST 路径统一挂在 `/api/v1` 下，由 `ApiConfig.restBase` 拼出来。