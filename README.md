# 🌟 发光星球 (GlowStar)

**让相同兴趣的人，在地图上一起发光 ✨**

## 📱 项目简介

发光星球是一款基于地理位置的**教育交友**APP，结合学习帮扶和陌生人交友功能。

### 核心功能
- 🗺️ **地图展示** - 发现附近的同好/学友
- 🎯 **兴趣匹配** - 通过共同兴趣破冰
- 📚 **学习帮扶** - 连接想学习的初高中学生
- 💬 **聊天系统** - 实时消息和破冰建议
- 🤖 **AI 助手** - 智能答疑和学习指导
- 🔒 **安全保护** - 未成年人保护和内容审核

## 🛠️ 技术栈

### 前端（客户端）
- **Flutter** - 跨平台框架（iOS + Android）
- **Dart** - 编程语言
- **高德地图 SDK** - 地图展示
- **geolocator** - 定位服务
- **sqflite** - 本地数据库

### 后端（服务器）
- **Node.js** - API 服务器
- **SQLite** - 数据库
- **Nginx** - 反向代理
- **Docker** - 容器化部署

### AI 集成
- **通义千问 (Qwen)** - AI 答疑
- **智谱 AI (GLM-4)** - 备选方案

## 📁 项目结构

```
glowstar/
├── client/              # Flutter 客户端
│   ├── lib/
│   │   ├── screens/     # 页面
│   │   ├── model/       # 数据模型
│   │   ├── services/    # 服务
│   │   └── main.dart    # 入口文件
│   └── test/            # 测试
├── server/              # Java 后端
│   ├── src/
│   │   └── main/java/com/hood/server/
│   │       ├── api/     # API 端点
│   │       ├── model/   # 数据模型
│   │       └── service/ # 服务
│   └── test/            # 测试
├── ops/                 # 运维脚本
│   ├── docker-compose.yml
│   ├── nginx.conf
│   └── deploy.sh
└── README.md
```

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 2.1.0
- Java 11+
- Node.js 14+
- Docker

### 安装步骤

```bash
# 克隆项目
git clone https://github.com/yourusername/glowstar.git
cd glowstar

# 安装客户端依赖
cd client
flutter pub get

# 运行客户端
flutter run

# 安装服务器依赖
cd ../server
./gradlew build

# 运行服务器
./gradlew run
```

### 部署

```bash
# 使用部署脚本
cd ops
chmod +x deploy.sh
./deploy.sh
```

## 📊 当前进度

- ✅ 兴趣标签系统
- ✅ 匹配算法
- ✅ 聊天系统
- ✅ 地图界面
- ✅ 通知系统
- ✅ 学习小组
- ✅ AI 助手
- ✅ 安全服务
- ✅ 搜索系统
- ✅ 设置系统
- ✅ 服务器 API
- ✅ 部署配置
- ✅ 测试用例

**完成度：** ~95%

## 🤝 贡献

欢迎贡献！请提交 PR 或 Issue。

## 📄 许可证

MIT License

---

**品牌口号：** 让相同兴趣的人，在地图上一起发光 ✨
