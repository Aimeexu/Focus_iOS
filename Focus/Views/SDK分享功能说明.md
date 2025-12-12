# 使用 SDK 的专业分享功能说明

## 🎯 功能概述

现在你的 Focus 应用已经集成了 **Facebook SDK** 和 **Google SDK**，分享功能已升级为专业版本！

## ✨ 新功能特点

### 1. Facebook 原生分享 ⭐⭐⭐⭐⭐

使用 Facebook SDK 的 `ShareDialog`，提供原生 Facebook 分享体验：

#### 分享图片
```swift
let photo = SharePhoto(image: image, userGenerated: true)
let content = SharePhotoContent()
content.photos = [photo]

let dialog = ShareDialog(viewController: vc, content: content, delegate: nil)
dialog.show()
```

#### 分享链接
```swift
let content = ShareLinkContent()
content.contentURL = URL(string: "https://www.focusapp.com")!
content.quote = "成就文案"

let dialog = ShareDialog(viewController: vc, content: content, delegate: nil)
dialog.show()
```

### 2. 智能回退机制

如果 Facebook 分享失败，自动回退到系统分享面板：

```
尝试 Facebook SDK 分享
    ↓ 失败
使用系统分享面板
```

### 3. 多平台支持

- ✅ Facebook（原生 SDK）
- ✅ 微信（系统分享）
- ✅ Twitter（系统分享）
- ✅ Instagram（系统分享）
- ✅ 邮件（系统分享）
- ✅ 短信（系统分享）

## 📱 用户体验流程

### Facebook 分享流程

1. 用户点击 "Facebook" 按钮
2. 应用加载成就图片
3. 显示 Facebook 原生分享对话框
4. 用户可以：
   - 添加评论
   - 选择分享到时间线/故事
   - 选择隐私设置
   - 标记朋友
5. 分享完成

### More 分享流程

1. 用户点击 "More" 按钮
2. 显示 iOS 系统分享面板
3. 用户选择任意应用分享
4. 分享完成

## 🔧 技术实现

### 已集成的 SDK

#### Facebook SDK
```swift
import FBSDKShareKit
import FBSDKCoreKit
```

**功能**：
- `ShareDialog` - 分享对话框
- `SharePhotoContent` - 图片分享
- `ShareLinkContent` - 链接分享
- `SharePhoto` - 图片对象

#### Google SDK
```swift
import GoogleSignIn
```

**当前用途**：登录功能
**未来可用于**：Google+ 分享（如果需要）

### 分享模式

Facebook SDK 支持三种分享模式：

1. **Automatic（推荐）** ✅
   - 自动选择最佳方式
   - 优先使用 Facebook 应用
   - 回退到浏览器

2. **Native**
   - 仅使用 Facebook 应用
   - 如果未安装会失败

3. **Browser**
   - 仅使用浏览器
   - 需要用户登录

我们使用 `automatic` 模式，提供最佳用户体验。

## 📊 对比：SDK vs 系统分享

### Facebook SDK 分享

**优点**：
- ✅ 原生 Facebook 界面
- ✅ 更好的用户体验
- ✅ 支持更多 Facebook 功能
- ✅ 可以获取分享统计
- ✅ 支持标记朋友
- ✅ 支持选择隐私设置

**缺点**：
- ❌ 需要集成 SDK
- ❌ 文件体积稍大
- ❌ 需要维护

### 系统分享面板

**优点**：
- ✅ 无需 SDK
- ✅ 支持所有应用
- ✅ 用户熟悉
- ✅ 维护成本低

**缺点**：
- ❌ 无法自定义界面
- ❌ 无法获取统计数据
- ❌ 功能有限

## 🎨 分享内容格式

### 文字内容
```
🎉 我在 Focus 应用中获得了成就：[成就名称]！

[成就描述]
```

### 包含内容
- ✅ Emoji（🎉）
- ✅ 成就名称
- ✅ 成就描述
- ✅ 成就图片
- ✅ 应用链接（可选）

## 🔐 隐私和权限

### Facebook 分享权限

Facebook SDK 分享**不需要**额外的登录权限：
- ✅ 无需 `publish_actions` 权限
- ✅ 用户通过 Facebook 应用授权
- ✅ 符合 Facebook 最新政策

### 系统分享权限

系统分享面板会根据目标应用请求权限：
- 照片访问（如果分享到相册）
- 联系人访问（如果分享到短信）

## 📈 未来增强功能

### 1. 分享统计
```swift
activityViewController.completionWithItemsHandler = { activity, success, _, _ in
    if success {
        // 记录分享成功
        Analytics.logEvent("share_success", parameters: [
            "platform": activity?.rawValue ?? "unknown",
            "achievement_id": achievement.id
        ])
    }
}
```

### 2. 自定义分享内容
```swift
// 根据不同平台自定义内容
class CustomActivityItemSource: NSObject, UIActivityItemSource {
    func activityViewController(_ activityViewController: UIActivityViewController, 
                               itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        switch activityType {
        case .postToFacebook:
            return "Facebook 专用文案"
        case .postToTwitter:
            return "Twitter 专用文案 #FocusApp"
        default:
            return "通用文案"
        }
    }
}
```

### 3. 生成分享海报
```swift
// 生成精美的分享图片
func generateSharePoster() -> UIImage {
    // 使用 UIGraphicsImageRenderer 生成海报
    // 包含：成就图片 + 标题 + 描述 + Logo
}
```

### 4. Deep Link 支持
```swift
// 分享链接可以直接打开应用
content.contentURL = URL(string: "focusapp://achievement/\(achievement.id)")
```

## 🐛 故障排查

### 问题 1: Facebook 分享对话框不显示

**可能原因**：
- Facebook 应用未安装
- Facebook SDK 配置错误
- 分享内容验证失败

**解决方案**：
1. 检查 Facebook 应用是否安装
2. 检查 Info.plist 中的 Facebook 配置
3. 查看控制台日志
4. 会自动回退到系统分享

### 问题 2: 图片分享失败

**可能原因**：
- 图片下载失败
- 图片格式不支持
- 图片太大

**解决方案**：
1. 检查网络连接
2. 压缩图片大小
3. 转换图片格式为 JPEG/PNG
4. 会自动回退到文字分享

### 问题 3: 中国区 Facebook 应用

**说明**：
- 中国区的 Facebook 可能使用不同的 URL Scheme
- Facebook SDK 会自动处理
- 如果失败，会回退到系统分享

## 📚 相关文档

- [Facebook SDK 文档](https://developers.facebook.com/docs/sharing/ios)
- [Google Sign-In 文档](https://developers.google.com/identity/sign-in/ios)
- [Apple 分享指南](https://developer.apple.com/design/human-interface-guidelines/sharing)

## 🎯 最佳实践

### 1. 预加载图片
```swift
// 在视图出现时预加载图片
.onAppear {
    loadShareImage()
}
```

### 2. 错误处理
```swift
do {
    try dialog.validate()
    dialog.show()
} catch {
    // 回退到系统分享
    shareWithSystemSheet()
}
```

### 3. 用户反馈
```swift
// 显示加载状态
@State private var isSharing = false

// 显示错误提示
@State private var showAlert = false
@State private var alertMessage = ""
```

## ✅ 测试清单

- [ ] Facebook 应用已安装 - 测试原生分享
- [ ] Facebook 应用未安装 - 测试回退机制
- [ ] 远程图片分享 - 测试图片下载
- [ ] 本地图片分享 - 测试本地资源
- [ ] 系统分享面板 - 测试 More 按钮
- [ ] 中国区 Facebook - 测试兼容性
- [ ] iPad 设备 - 测试 Popover 显示
- [ ] 网络断开 - 测试错误处理

---

**状态**: ✅ 已完成 Facebook SDK 集成
**版本**: 2.0 Pro
**日期**: 2025-12-09
