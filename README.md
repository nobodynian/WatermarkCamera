# WatermarkCamera (水印相机)

一款简洁的 iOS 水印相机应用，拍照后自动叠加日期时间水印，支持自定义修改时间和地点备注。

## 功能

- 拍照并自动添加日期时间水印
- 支持修改水印时间（日期和时间均可调整）
- 支持输入自定义地点信息
- 支持添加备注文字
- 实时预览水印效果
- 一键保存到相册

## 要求

- Xcode 15+
- iOS 16.0+
- Swift 5.0

## GitHub Actions 自动构建 IPA

本项目配置了 GitHub Actions 工作流，可以通过 GitHub 远程构建 IPA，无需本地 Mac。

### 方式一：未签名 IPA（无需 Apple 开发者账号）

1. 将代码推送到 GitHub
2. 进入仓库 → **Actions** → **Build iOS IPA**
3. 点击 **Run workflow**
4. 构建类型选择 `unsigned`
5. 等待构建完成（约 5-10 分钟）
6. 在构建结果中下载 `WatermarkCamera-IPA` 压缩包

> 未签名 IPA 无法直接安装到 iPhone。需要通过 **AltStore** 或 **Sideloadly** 等工具用你的 Apple ID 签名后安装。签名有效期 7 天，最多同时 3 个 app。

### 方式二：签名 IPA（需要 Apple 开发者账号）

1. 在仓库 → **Settings** → **Secrets and variables** → **Actions** 中添加以下密钥：
   - `APPLE_TEAM_ID` - Apple 开发者团队 ID
   - `APPLE_API_KEY_ID` - App Store Connect API 密钥 ID
   - `APPLE_API_ISSUER_ID` - App Store Connect API 发行者 ID
   - `APPLE_API_KEY_PATH` - API 密钥文件路径（需上传 p8 文件）
2. 进入 **Actions** → **Build iOS IPA** → **Run workflow**
3. 构建类型选择 `signed`，填入 Team ID
4. 构建完成后下载签名 IPA

## 本地 Xcode 打包

如果你有 Mac，也可以用 Xcode 手动打包：

1. 用 Xcode 打开 `WatermarkCamera.xcodeproj`
2. 选择 `Any iOS Device (arm64)` 作为目标设备
3. `Product` → `Archive`
4. 选择 `Distribute App` → `Ad Hoc` 或 `Development`
5. 导出 IPA 文件

## 项目结构

```
WatermarkCamera/
├── .github/workflows/
│   └── build.yml                  # GitHub Actions 自动构建工作流
├── WatermarkCamera.xcodeproj      # Xcode 项目文件
└── WatermarkCamera/
    ├── App/
    │   └── WatermarkCameraApp.swift    # 应用入口
    ├── Views/
    │   ├── MainView.swift              # 主界面
    │   ├── CameraView.swift            # 相机视图
    │   └── PhotoPreviewView.swift      # 照片预览和水印编辑
    ├── Assets/
    │   ├── Assets.xcassets             # 资源目录
    │   └── AppIcon.appiconset          # 应用图标
    └── Info.plist                      # 应用配置
```

## License

MIT License
