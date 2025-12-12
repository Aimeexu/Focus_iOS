# Instagram 分享配置指南

## 🚀 快速开始

### 步骤 1: 配置 Info.plist ⚠️ 重要！

在你的 `Info.plist` 文件中添加以下内容：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>instagram</string>
    <string>instagram-stories</string>
    <string>fb</string>
    <string>fbapi</string>
    <string>fbauth2</string>
</array>
```

**为什么需要这个？**
- iOS 需要声明要查询的 URL Schemes
- 否则 `canOpenURL` 会返回 false
- 这是 iOS 9+ 的安全要求

### 步骤 2: 测试 Instagram 是否安装

在真机上测试（模拟器可能没有 Instagram）：

```swift
// 检查 Instagram Stories
if let url = URL(string: "instagram-stories://share"),
   UIApplication.shared.canOpenURL(url) {
    print("✅ Instagram Stories 可用")
} else {
    print("❌ Instagram Stories 不可用")
}

// 检查 Instagram App
if let url = URL(string: "instagram://app"),
   UIApplication.shared.canOpenURL(url) {
    print("✅ Instagram App 已安装")
} else {
    print("❌ Instagram App 未安装")
}
```

### 步骤 3: 添加 Instagram Logo

你需要添加 Instagram 的 logo 图片到 Assets：

1. 在 `Assets.xcassets` 中创建新的 Image Set
2. 命名为 `instagram_logo`
3. 添加 Instagram 图标（建议使用白色图标）

**或者使用 SF Symbols**：
```swift
Image(systemName: "camera.circle.fill")  // 临时替代
```

## 📱 使用方式

### 用户操作流程

1. **点击成就卡片** → 打开分享视图
2. **点击 Instagram 按钮** → 开始分享流程
3. **自动打开 Instagram Stories** → 成就图片作为贴纸
4. **用户编辑** → 添加文字、滤镜等
5. **发布** → 完成分享

### 如果 Instagram 未安装

- 自动回退到系统分享面板
- 用户可以选择其他应用
- 或者保存图片后手动分享

## 🎨 自定义配置

### 修改背景颜色

在 `shareToInstagramStories` 方法中：

```swift
let pasteboardItems: [[String: Any]] = [
    [
        "com.instagram.sharedSticker.stickerImage": imageData,
        "com.instagram.sharedSticker.backgroundTopColor": "#你的颜色",  // 修改这里
        "com.instagram.sharedSticker.backgroundBottomColor": "#你的颜色"  // 修改这里
    ]
]
```

**推荐颜色组合**：
- 品牌色渐变
- 成就类别对应的颜色
- 季节主题颜色

### 修改按钮样式

在 `shareButtonsSection` 中：

```swift
ShareAchievementButton(
    icon: "instagram_logo",
    title: "Instagram",
    color: Color(red: 193/255, green: 53/255, blue: 132/255),  // Instagram 粉色
    isLoading: isSharing
) {
    shareToInstagram()
}
```

### 修改分享文案

在 `shareToInstagramFeed` 方法中：

```swift
documentController.annotation = [
    "InstagramCaption": "🎉 自定义你的文案！"
]
```

## 🧪 测试建议

### 测试场景 1: Instagram 已安装

1. 在真机上安装 Instagram
2. 运行应用
3. 点击成就 → Instagram 按钮
4. 应该自动打开 Instagram Stories
5. 验证图片显示正确
6. 验证背景颜色正确

### 测试场景 2: Instagram 未安装

1. 卸载 Instagram
2. 运行应用
3. 点击成就 → Instagram 按钮
4. 应该显示系统分享面板
5. 验证图片和文字都包含

### 测试场景 3: 不同图片类型

1. 测试远程图片
2. 测试本地图片
3. 测试大图片
4. 测试小图片

## ⚠️ 注意事项

### 1. Info.plist 配置是必需的

如果没有配置 `LSApplicationQueriesSchemes`：
- `canOpenURL` 会返回 false
- Instagram 分享不会工作
- 会直接回退到系统分享

### 2. 只能在真机上测试

- 模拟器可能没有 Instagram
- URL Scheme 在模拟器上可能不工作
- 建议使用真机测试

### 3. Instagram 版本要求

- Instagram Stories 分享需要 Instagram 9.0+
- 旧版本可能不支持
- 会自动回退到系统分享

### 4. 图片格式

- 推荐使用 PNG 或 JPEG
- 避免使用 HEIC 格式
- 图片大小建议 < 5MB

## 🔍 调试技巧

### 检查 URL Scheme 配置

```swift
// 在 AppDelegate 或 SceneDelegate 中添加
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("📱 打开 URL: \(url)")
    return true
}
```

### 检查粘贴板数据

```swift
// 在分享后检查
if let items = UIPasteboard.general.items.first {
    print("📋 粘贴板数据: \(items.keys)")
}
```

### 检查临时文件

```swift
// 检查图片是否保存成功
let tempDir = FileManager.default.temporaryDirectory
let imageURL = tempDir.appendingPathComponent("share_image.igo")
print("📁 临时文件: \(imageURL)")
print("📁 文件存在: \(FileManager.default.fileExists(atPath: imageURL.path))")
```

## 📊 性能优化

### 1. 图片压缩

```swift
// 压缩图片以提高性能
let imageData = image.jpegData(compressionQuality: 0.8)  // 80% 质量
```

### 2. 异步加载

```swift
// 已经实现了异步加载
loadImageForFacebookShare { image in
    // 在后台加载图片
}
```

### 3. 缓存图片

```swift
// 可以添加图片缓存
@State private var cachedImage: UIImage?

.onAppear {
    if cachedImage == nil {
        loadImage()
    }
}
```

## 🎯 完整的 Info.plist 示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 其他配置 -->
    
    <!-- URL Schemes 查询白名单 -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <!-- Instagram -->
        <string>instagram</string>
        <string>instagram-stories</string>
        
        <!-- Facebook -->
        <string>fb</string>
        <string>fbapi</string>
        <string>fbauth2</string>
        <string>fbshareextension</string>
        
        <!-- 其他社交平台（可选） -->
        <string>twitter</string>
        <string>twitterauth</string>
        <string>whatsapp</string>
        <string>line</string>
    </array>
    
    <!-- Facebook App ID（如果使用 Facebook SDK） -->
    <key>FacebookAppID</key>
    <string>你的Facebook App ID</string>
    
    <key>FacebookDisplayName</key>
    <string>Focus</string>
    
    <!-- 其他配置 -->
</dict>
</plist>
```

## ✅ 配置检查清单

- [ ] Info.plist 中添加了 `LSApplicationQueriesSchemes`
- [ ] 包含 `instagram` 和 `instagram-stories`
- [ ] 添加了 Instagram logo 图片
- [ ] 在真机上测试
- [ ] 验证 Instagram 已安装的情况
- [ ] 验证 Instagram 未安装的情况
- [ ] 测试远程图片分享
- [ ] 测试本地图片分享
- [ ] 检查控制台日志
- [ ] 验证用户体验流畅

## 🚀 现在可以使用了！

完成以上配置后：

1. 运行应用
2. 点击任意成就
3. 点击 Instagram 按钮
4. 享受原生 Instagram 分享体验！

---

**重要提示**: 记得在 Info.plist 中添加 URL Schemes，否则 Instagram 分享不会工作！
