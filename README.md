# ✨ GlowStar (发光星球)

> 大学生兴趣社交平台 — 发现志同道合的朋友

## 📱 功能

| 模块 | 说明 |
|------|------|
| 🌍 **发现** | 基于地图的兴趣匹配，发现附近同好 |
| 📰 **动态广场** | 推荐/关注/附近/学习 四栏内容流 |
| 🎤 **语音房** | 创建/加入语音房间，实时聊天 |
| 💬 **即时通讯** | 私信对话，WebSocket 实时通信 |
| 🧑‍🤝‍🧑 **学习小组** | 组队学习，进度追踪 |
| 🏆 **等级成就** | 20 个成就，XP 经验系统 |
| 🌙 **深夜模式** | 情绪匹配 + 深夜话题 |
| 🤖 **AI 助手** | 智能对话与推荐 |
| 🔐 **安全认证** | 微信/手机号/Google/Facebook 登录 |

## 🛠 技术栈

**客户端 (Flutter/Dart)**
- Flutter 3.x + Dart
- Riverpod 状态管理
- WebSocket 实时通信

**服务端 (Java)**
- JAX-RS + Jersey
- SQLite 数据库（开发环境）
- JWT 认证 + RESTful API

## 🚀 快速开始

### 客户端
```bash
cd client
flutter pub get
flutter run
```

### 服务端
```bash
cd server
mvn clean install
java -jar target/glowstar-server.jar
```

## 📁 项目结构
```
glowstar/
├── client/                    # Flutter 客户端
│   └── lib/
│       ├── screens/          # 23 个页面
│       ├── models/           # 数据模型
│       └── services/         # 服务层
├── server/                    # Java 服务端
│   └── src/main/java/com/glowstar/server/
│       ├── api/              # 12 个 REST API
│       ├── model/            # 7 个数据模型
│       └── services/         # 3 个服务
├── ops/                       # 部署配置
│   ├── docker-compose.yml
│   └── nginx.conf
└── .github/workflows/        # CI/CD
```

## 📊 数据库
20 张表覆盖用户、帖子、语音房、成就、评分等核心模块。

## License
MIT
