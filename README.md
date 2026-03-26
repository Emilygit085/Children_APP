# 环境搭建
vscode 安装 flutter dart 插件

# dart 语法, flutter 快速入门
1. 旦夕教程
https://github.com/DanXi-Dev/QuickStart/blob/main/Flutter%20%E6%8A%80%E6%9C%AF%E6%A0%88%E5%BF%AB%E9%80%9F%E4%B8%8A%E6%89%8B.md
（我们不需要Android Studio，只用vscode就可以了）
2. 中文社区教程
https://docs.flutter.cn/install

3. flutter 英文社区教程
https://docs.flutter.dev/learn/pathway/tutorial/create-an-app

4. 不懂的可以问GPT / Google， 或者群里讨论

5. 代码多问问AI， Cursor之类的平台写这种demo很方便

# 项目结构

```
lib/
├── main.dart                    # 应用入口和路由配置
├── models/
│   ├── user.dart               # 用户数据模型
│   └── activity.dart           # 活动数据模型
├── widgets/
│   └── chat_bubble.dart        # 聊天气泡组件
└── pages/
    ├── login_page.dart         # 登录/注册页面
    ├── home_page.dart          # 首页（好友列表 + 兴趣匹配）
    ├── chat_page.dart          # 聊天页面
    ├── activity_page.dart      # 活动列表页面
    ├── create_activity_page.dart # 发起活动页面
    └── profile_page.dart       # 个人主页
```

# 运行方式
1. 安装 Flutter SDK
2. 在项目目录运行 
```bash
flutter pub get
flutter run
```

所有页面使用假数据，可直接运行。页面间通过 Navigator.pushNamed 跳转，路由配置在 main.dart 中统一管理

# 报错信息

1. flutter pub get 需要很多时间运行
可以在终端当中设置自己的代理环境变量 / 用国内的flutter 源

e.g.

```bash
PS D:\Codefield\Social_APP> $env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
PS D:\Codefield\Social_APP> $env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

2. flutter run 没找到支持的运行平台
例如下面
```
Flutter assets will be downloaded from https://storage.flutter-io.cn. Make
sure you trust this source!
No supported devices connected.

The following devices were found, but are not supported by this project:     
Windows (desktop) • windows • windows-x64    • Microsoft Windows [版本       
10.0.22631.6199]
Chrome (web)      • chrome  • web-javascript • Google Chrome 145.0.7632.119  
Edge (web)        • edge    • web-javascript • Microsoft Edge 145.0.3800.82 
```

运行下面命令即可
```bash
flutter create .
```

# 页面层级结构
```
登录页 (LoginPage)
  ↓ (pushReplacementNamed)
主页面层 (HomePage / ActivityPage / ProfilePage)
  ├─ 通过底部导航栏切换 (pushReplacementNamed)
  └─ 子页面层
      ├─ ChatPage (pushNamed → pop)
      ├─ ProfilePage (查看其他用户) (pushNamed → pop)
      └─ CreateActivityPage (pushNamed → pop)
```

# 家长系统
1. 活动审批流程图与家长端绑定逻辑 (by dzk) 
[![](https://mermaid.ink/img/pako:eNqFVu1PE0kc_lc2a0wg12Jb-m7uEkW9mJiLQe4uuZYPaztt9yy7vd2tyjUkxRMtLVwR8EQsVpQC4kHVU15axP_l0pndfvL-hJvd2d1OC2o_kHaY5_k9v_fJsTExDtgwm5S4TIoZuRAVGPw5fZqBO8utg2n0bA8elslhLM3J8gWQYLIykJgEn06HTwF3wpcADlmRxBsgfMrl9gVC182fzlt8XEmFPZnbZ3sIMpwEBMWkSCQSg8BlUwC_z-1yfZVCHpcVMGZRDAJfwmdTeDm3Nxg7RmEdxDk5xUkSNx5mfIzvGLEiSlwSWP4FEz4Qspnd133Ac6I4wnJN4SSlrw8e5uFGqb-fcTq_Y4ZSIHbjPC_Ec-hFHlVraKkO59bh3lu1-QAHGe7sth9-_HRYnSAUdgKcTifTXtpFO-9b-_lPh8vkOno_qW6WmD5U2SIHanEX5Sd1U04Cte3hIwZbMkRclUTsELiKPYv8V114w8C7H9VXNfVVHTO39rdajUZrfxt-_GOUkFD3iRNpnpBG1DsH8H6TocWbGPuOgdC_dMy1V9-3V55jW2cIhMBHaZfl7HVShDqSF5JYQgzIMhOhg4Aqf8PK6_bULKwfqM8mu2j0T5yXQEzhRYEZOd85tbQYwr4HwhCu-Yi6WEWFOcbPtD7MtpfLqNLAhNGo0DoqwfU72JY3OBjyuClyE2mwXEuJtwwatHSkrjXQw9dw-xEmYL5hYH5e21lFj3YpqHWdYG_xSiw1LKZBDhbuo9nn2sa8Nv0WHS5ipokOiILbCJJNo3-oZJKYGsk0A6zt7MNynVLQwRgUl4VMVjEc0I4W4FTNDikFse8YiJ-AxCfGr4hJPpZrb81o9cl2vqkdPdBD1nyBkXDmALMwnVLu9oHCG5W59kZ7V7NjeVGSRCmCynM4BO3Fx1q93hM940K39M9y47zCYpVwczfBFTHGpXGk5o8YeO8xdpZUEekcLJ-Xz4tZIf6tImUBbdWC2vV8LRvTSzLyb2XKbABiicg2oUCI02VN4brHwefbvTFjNOUyLK6i0joqbFlNbw-NLzc9njCGqXNGJ4xIfDIJpIi2sQ7LD9DDMrpbRQuzrQ8V7DosPoO1D7BcOqN_w5F514TFzTPaZBGuvTy5PS8LCpBiIKNz9_aooVy7v4U5iPKvtmaXRhIgCXAKGAa_RWDhCWw2iK9afQ-9uaMr3l7COuG9Kf1L4ZG2uknZsLF2XY2InKyYdYW14QjiILTzk2bLrO5oO2s9lWZADIKfOV45l8lI4k08Lran4dEUxI09fTAwMHBysikA1ahGcno6FS8CtVLSGYtPR78w-ad10YZRswjslNsJIQa59LGBSbC6QcLw1WRQcg35V3hZwcGUzSFn-38s7tZFs8JFUQYksTlin9TbiWOBvk021gy6Wyb5A1Yw8doxqgA9eYf-eo3dss5HP0-ESvNqc8UiGga_YoePE1nnoyeO3Y4Ag-cHUcFjZijFp-ORdn5ZrdbsNcr8eJmBhT1MOtqFt_h78SeWD_lL3TJQl3iBSw8DOZtWcqiSV5sFtbmAnlrhpP7dGz8ydkhIjKGFpje01Rn4Z2cAoGINzs2SMWa2vf56mbPGbw87FdRLHJ-2qFdmGMKoPX_VfvkPfNJd011CDPBFId7Xp7uxUu3vNy3ZfNYN61Wlv0Ybi-ri5rHXKP1OcVhb3tFZdY6u8eKg61t_xNJvP2u7O6hd4rDniYMqBQedVvIO7SLq7A3zLXmWdeD3NR9nwwkuLQMHOwakMU7_zeZ0YJRVUmAMRNkw_hoHCQ4HO8pGhQmMy3DCL6I4xob15eRgJTGbTNk82Uwcy7vAc3gQdK7gogLSEN5oChsOel0GBxvOsbfZsNvlHvCG_N7BwGAg6PF5gkEHO86GnT7vQMDlD3hCoZDH7w64gr4JB_u7Ydc1EAphmN8b8Li9fhfGTPwPiscdnQ?type=png)](https://mermaid-live.nodejs.cn/edit#pako:eNqFVu1PE0kc_lc2a0wg12Jb-m7uEkW9mJiLQe4uuZYPaztt9yy7vd2tyjUkxRMtLVwR8EQsVpQC4kHVU15axP_l0pndfvL-hJvd2d1OC2o_kHaY5_k9v_fJsTExDtgwm5S4TIoZuRAVGPw5fZqBO8utg2n0bA8elslhLM3J8gWQYLIykJgEn06HTwF3wpcADlmRxBsgfMrl9gVC182fzlt8XEmFPZnbZ3sIMpwEBMWkSCQSg8BlUwC_z-1yfZVCHpcVMGZRDAJfwmdTeDm3Nxg7RmEdxDk5xUkSNx5mfIzvGLEiSlwSWP4FEz4Qspnd133Ac6I4wnJN4SSlrw8e5uFGqb-fcTq_Y4ZSIHbjPC_Ec-hFHlVraKkO59bh3lu1-QAHGe7sth9-_HRYnSAUdgKcTifTXtpFO-9b-_lPh8vkOno_qW6WmD5U2SIHanEX5Sd1U04Cte3hIwZbMkRclUTsELiKPYv8V114w8C7H9VXNfVVHTO39rdajUZrfxt-_GOUkFD3iRNpnpBG1DsH8H6TocWbGPuOgdC_dMy1V9-3V55jW2cIhMBHaZfl7HVShDqSF5JYQgzIMhOhg4Aqf8PK6_bULKwfqM8mu2j0T5yXQEzhRYEZOd85tbQYwr4HwhCu-Yi6WEWFOcbPtD7MtpfLqNLAhNGo0DoqwfU72JY3OBjyuClyE2mwXEuJtwwatHSkrjXQw9dw-xEmYL5hYH5e21lFj3YpqHWdYG_xSiw1LKZBDhbuo9nn2sa8Nv0WHS5ipokOiILbCJJNo3-oZJKYGsk0A6zt7MNynVLQwRgUl4VMVjEc0I4W4FTNDikFse8YiJ-AxCfGr4hJPpZrb81o9cl2vqkdPdBD1nyBkXDmALMwnVLu9oHCG5W59kZ7V7NjeVGSRCmCynM4BO3Fx1q93hM940K39M9y47zCYpVwczfBFTHGpXGk5o8YeO8xdpZUEekcLJ-Xz4tZIf6tImUBbdWC2vV8LRvTSzLyb2XKbABiicg2oUCI02VN4brHwefbvTFjNOUyLK6i0joqbFlNbw-NLzc9njCGqXNGJ4xIfDIJpIi2sQ7LD9DDMrpbRQuzrQ8V7DosPoO1D7BcOqN_w5F514TFzTPaZBGuvTy5PS8LCpBiIKNz9_aooVy7v4U5iPKvtmaXRhIgCXAKGAa_RWDhCWw2iK9afQ-9uaMr3l7COuG9Kf1L4ZG2uknZsLF2XY2InKyYdYW14QjiILTzk2bLrO5oO2s9lWZADIKfOV45l8lI4k08Lran4dEUxI09fTAwMHBysikA1ahGcno6FS8CtVLSGYtPR78w-ad10YZRswjslNsJIQa59LGBSbC6QcLw1WRQcg35V3hZwcGUzSFn-38s7tZFs8JFUQYksTlin9TbiWOBvk021gy6Wyb5A1Yw8doxqgA9eYf-eo3dss5HP0-ESvNqc8UiGga_YoePE1nnoyeO3Y4Ag-cHUcFjZijFp-ORdn5ZrdbsNcr8eJmBhT1MOtqFt_h78SeWD_lL3TJQl3iBSw8DOZtWcqiSV5sFtbmAnlrhpP7dGz8ydkhIjKGFpje01Rn4Z2cAoGINzs2SMWa2vf56mbPGbw87FdRLHJ-2qFdmGMKoPX_VfvkPfNJd011CDPBFId7Xp7uxUu3vNy3ZfNYN61Wlv0Ybi-ri5rHXKP1OcVhb3tFZdY6u8eKg61t_xNJvP2u7O6hd4rDniYMqBQedVvIO7SLq7A3zLXmWdeD3NR9nwwkuLQMHOwakMU7_zeZ0YJRVUmAMRNkw_hoHCQ4HO8pGhQmMy3DCL6I4xob15eRgJTGbTNk82Uwcy7vAc3gQdK7gogLSEN5oChsOel0GBxvOsbfZsNvlHvCG_N7BwGAg6PF5gkEHO86GnT7vQMDlD3hCoZDH7w64gr4JB_u7Ydc1EAphmN8b8Li9fhfGTPwPiscdnQ)

# 文件夹说明
`lib/` 存放了所有的工作代码
`working_record/` 存放了大家提交PR时写的工作记录文档

# 后端

## 启用后端
```bash
cd backend

# 创建并激活venv
python -m venv .venv

.\.venv\Scripts\Activate.ps1

# 安装依赖
pip install -r requirements.txt

# 数据库迁移
alembic upgrade head

# 启动后端服务
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

# 启动成功后运行下面的flutter run命令
flutter run -d edge --web-port 49873 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

远程调试示例：`flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000`（Android 模拟器常用 `http://10.0.2.2:8000`）。未设置 API_BASE_URL 时仍为仅本地 SQLite 行为。