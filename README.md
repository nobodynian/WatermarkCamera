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

## 使用方法

1. 用 Xcode 打开 `WatermarkCamera.xcodeproj`
2. 选择你的开发者团队（Signing & Capabilities）
3. 选择模拟器或真机运行
4. 打包 IPA：Product → Archive → Distribute App

## 打包 IPA

1. 在 Xcode 中打开项目
2. 选择 `Any iOS Device (arm64)` 作为目标设备
3. `Product` → `Archive`
4. Archive 完成后选择 `Distribute App`
5. 选择 `Ad Hoc` 或 `Development` 签名方式
6. 导出 IPA 文件

## 项目结构

```
WatermarkCamera/
├── WatermarkCamera.xcodeproj    # Xcode 项目文件
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
