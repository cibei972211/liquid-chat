# 液态聊天 (Liquid Chat) - iOS APP 打包安装教程

> 液态玻璃风格的 AI 聊天应用，支持连接本地 Ollama 模型和在线 OpenAI 兼容 API

---

## 📱 效果预览

- 液态玻璃 / 毛玻璃 UI 风格，蓝紫渐变配色
- 流式输出（AI 回复字一个一个蹦出来）
- 多会话管理，聊天记录本地保存
- 支持本地 Ollama 模型 + 在线 API
- 可自定义系统提示词、温度、最大 Token

---

## 🚀 快速开始：从零到装到手机上只需 5 步

### 第 1 步：注册账号（5 分钟）

你需要两个免费账号：

1. **GitHub**：https://github.com/signup
   - 用来存放代码，免费的
2. **Codemagic**：https://codemagic.io/signup
   - 用来云打包 IPA，免费额度每月 500 分钟，够用了
   - 注册时选 "Sign up with GitHub"，直接用 GitHub 账号登录

### 第 2 步：把代码上传到 GitHub（5 分钟）

1. 打开 GitHub，点右上角 `+` → `New repository`
2. Repository name 填 `liquid-chat`，选 `Public`，点 `Create repository`
3. 下载安装 GitHub Desktop：https://desktop.github.com/
4. 打开 GitHub Desktop，登录你的账号
5. 点 `File` → `Add Local Repository`，选择这个 `liquid_chat` 文件夹
6. 左下角填 commit 信息（比如 "first commit"），点 `Commit to main`
7. 点顶部 `Publish repository`，把代码推上去

### 第 3 步：Codemagic 云打包（10-15 分钟）

1. 打开 Codemagic：https://codemagic.io/apps
2. 点 `Add application`
3. 选 GitHub，找到你刚创建的 `liquid-chat` 仓库，点 `Next`
4. 构建类型选 `Flutter`（如果没自动识别的话）
5. 点 `Finish` → `Start new build`
6. 等待构建完成（第一次比较慢，大概 10-15 分钟）
7. 构建成功后，在 `Artifacts` 里下载 `LiquidChat.ipa`

> 💡 如果构建失败，把错误截图发给我，我帮你看

### 第 4 步：安装 AltStore（电脑端操作）

AltStore 是用来把 IPA 装到 iPhone 上的工具，免费，不用越狱。

**Windows 电脑：**
1. 下载 AltServer：https://altstore.io/ （点 Windows 图标下载）
2. 解压安装，安装时会让你装 iCloud 和 iTunes，按提示装就行
3. 打开 AltServer（会在系统托盘里，一个菱形图标）
4. 用数据线把 iPhone 连到电脑上
5. 手机上弹出"是否信任此电脑"，点信任

**Mac 电脑：**
1. 下载 AltServer for Mac
2. 把 AltServer 拖到 Applications，打开
3. 菜单栏会出现菱形图标
4. 用数据线连 iPhone

### 第 5 步：把 IPA 装到手机上（2 分钟）

1. 确保 iPhone 和电脑连同一个 WiFi
2. 电脑上点 AltServer 图标 → `Install AltStore` → 选你的 iPhone
3. 输入你的 Apple ID 和密码（免费账号就行，不用开发者账号）
4. 等 AltStore 装到手机上
5. 手机上打开 `设置` → `通用` → `VPN与设备管理`，信任你的 Apple ID 证书
6. 打开手机上的 AltStore，点底部 `My Apps`
7. 点左上角 `+` 号，选择你下载的 `LiquidChat.ipa`
8. 等待安装完成，桌面上就有"液态聊天"了！

> ⚠️ 免费证书 7 天过期，过期后 APP 会闪退。解决方法：手机和电脑连同一个 WiFi，打开 AltStore 点 `Refresh All` 就行，10 秒搞定。

---

## ⚙️ 配置 AI 模型

打开 APP 后，点右上角设置图标，填以下信息：

### 方案 A：连接电脑上的本地 Ollama 模型（推荐，免费）

**电脑上先装好 Ollama：**
1. 下载 Ollama：https://ollama.com/
2. 安装后打开命令行，输入：`ollama pull deepseek-r1:9b`（拉模型，等下载完）
3. 输入：`ollama serve`（启动服务，保持窗口开着）

**手机上填：**
- Base URL：`http://你电脑的IP:11434/v1`
  - 电脑 IP 怎么看：Windows 按 Win+R 输入 `cmd`，再输入 `ipconfig`，找 IPv4 地址（一般是 192.168.x.x）
- API 密钥：随便填，比如 `ollama`
- 模型名称：`deepseek-r1:9b`（你拉了啥模型就填啥）
- 点"测试连接"，成功就能用了

> ⚠️ 手机和电脑必须连同一个 WiFi！电脑防火墙要允许 Ollama 访问网络。

### 方案 B：连接在线 API

- Base URL：服务商提供的地址，比如 `https://api.openai.com/v1`
- API 密钥：你的 API Key
- 模型名称：比如 `gpt-3.5-turbo`、`gpt-4` 等

---

## ❓ 常见问题

### Q: Codemagic 构建失败怎么办？
A: 把构建日志里的红色错误截图发我，大概率是依赖版本问题，我帮你改。

### Q: 安装后 APP 闪退？
A: 证书过期了，打开 AltStore 点 Refresh All 续签一下。

### Q: 连不上本地模型？
A: 检查这几点：
1. 手机和电脑是不是同一个 WiFi
2. 电脑 IP 地址填对了没
3. Ollama 服务启动了没（命令行窗口开着没）
4. 电脑防火墙有没有拦
5. 试试电脑浏览器访问 `http://localhost:11434/v1/models` 能不能打开

### Q: 能不能不经过电脑直接装？
A: 不行，iOS 装第三方 APP 必须经过 AltStore 这种工具签名。7 天续签一次也需要电脑在同一个 WiFi 下。

### Q: 有没有永久签名的方法？
A: TrollStore 可以永久签，但只支持 iOS 14.0-16.6.1，你 iOS 27 用不了。

### Q: 聊天记录会丢吗？
A: 不会，存在手机本地。除非你卸载 APP。

### Q: 支持 Markdown 渲染吗？
A: 当前版本是纯文本，后续可以加。

---

## 📁 项目结构

```
liquid_chat/
├── lib/
│   ├── main.dart                 # 应用入口 + 启动页
│   ├── models/
│   │   ├── message.dart          # 消息模型
│   │   └── chat_session.dart     # 会话模型
│   ├── services/
│   │   ├── api_service.dart      # AI API 服务（支持流式）
│   │   └── storage_service.dart  # 本地存储服务
│   ├── screens/
│   │   ├── chat_list_screen.dart # 会话列表页
│   │   ├── chat_screen.dart      # 聊天窗口页
│   │   └── settings_screen.dart  # 设置页
│   ├── widgets/
│   │   ├── glass_container.dart  # 液态玻璃组件（容器/按钮/输入框）
│   │   └── message_bubble.dart   # 消息气泡组件
│   └── utils/
│       └── theme.dart            # 主题配色
├── ios/                          # iOS 平台配置
├── codemagic.yaml                # 云打包配置
├── pubspec.yaml                  # Flutter 依赖
└── README.md                     # 本文件
```

---

## 🎨 功能清单

- [x] 液态玻璃 UI 风格
- [x] 流式输出（打字机效果）
- [x] 多会话管理
- [x] 本地存储聊天记录
- [x] 支持 OpenAI 兼容 API
- [x] 支持本地 Ollama 模型
- [x] 可自定义系统提示词
- [x] 可调节温度和最大 Token
- [x] 连接测试功能
- [x] 删除会话（可撤销）
- [x] 停止生成功能
- [ ] Markdown 渲染（待加）
- [ ] 代码高亮（待加）
- [ ] 语音输入（待加）

---

有问题随时问我，祝你用得开心！🎉
