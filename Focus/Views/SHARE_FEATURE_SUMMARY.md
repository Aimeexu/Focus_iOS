# 分享功能快速参考

## 📦 新增文件
- `Focus/Views/ShareAchievementView.swift` - 分享视图组件

## 🔧 修改文件
- `Focus/Views/PostingView.swift` - 添加分享功能
- `Focus/Views/AchievementsView.swift` - 已有分享功能（无需修改）

## ✨ 主要功能

### 1. 分享到 Facebook
```swift
// 点击 Facebook 按钮
// → 尝试打开 Facebook 应用
// → 如果失败，显示系统分享面板
```

### 2. 分享到其他平台
```swift
// 点击 More 按钮
// → 显示 iOS 系统分享面板
// → 支持所有系统支持的应用
```

### 3. 分享内容
```
文字: "我在 Focus 应用中获得了成就：[标题]！\n[描述]"
图片: 成就/海报的图片（支持远程和本地）
```

## 🎯 使用位置

1. **成就页面** (AchievementsView)
   - Friends 标签页
   - 点击已解锁的成就卡片

2. **海报页面** (PostingView)
   - Posting 标签页
   - 点击已解锁的海报卡片

## 🎨 UI 设计

```
┌─────────────────────────────────┐
│  半透明黑色背景 (可点击关闭)      │
│                                 │
│  ┌───────────────────────┐     │
│  │  [X]                  │     │
│  │                       │     │
│  │    [成就图片]          │     │
│  │                       │     │
│  │    成就标题            │     │
│  │    成就描述            │     │
│  │    ⭐ x 5             │     │
│  │                       │     │
│  │  ┌─────────────────┐  │     │
│  │  │  分享你的成就    │  │     │
│  │  │                 │  │     │
│  │  │  [FB]  [More]   │  │     │
│  │  └─────────────────┘  │     │
│  └───────────────────────┘     │
└─────────────────────────────────┘
```

## 🔑 关键代码

### 在视图中添加分享功能
```swift
@State private var showShareView = false
@State private var selectedAchievement: Achievement?

var body: some View {
    // ... 你的视图内容
    .overlay(shareOverlay)
}

private var shareOverlay: some View {
    Group {
        if showShareView, let achievement = selectedAchievement {
            ShareAchievementView(
                achievement: achievement,
                isPresented: $showShareView
            )
        }
    }
}

private func handleAchievementTap(_ achievement: Achievement) {
    if achievement.isUnlocked {
        selectedAchievement = achievement
        showShareView = true
    }
}
```

## 📱 支持的平台

- ✅ Facebook (优先使用应用)
- ✅ 微信
- ✅ Twitter
- ✅ Instagram
- ✅ 邮件
- ✅ 短信
- ✅ 其他系统支持的应用

## ⚙️ 技术细节

- **依赖**: 仅使用 iOS 原生 API，无需第三方 SDK
- **图片处理**: 自动下载远程图片，支持本地图片
- **iPad 支持**: Popover 形式显示分享面板
- **错误处理**: 下载失败时仍可分享文字

## 🧪 测试清单

- [ ] 点击成就卡片显示分享视图
- [ ] 点击海报卡片显示分享视图
- [ ] Facebook 按钮工作正常
- [ ] More 按钮显示系统分享面板
- [ ] 远程图片正确下载和分享
- [ ] 本地图片正确分享
- [ ] 关闭按钮工作正常
- [ ] 点击背景关闭功能正常

## 📚 相关文档

- `ShareFeatureGuide.md` - 详细功能说明
- `ShareFeatureTest.md` - 测试指南
- `分享功能说明.md` - 中文使用说明

---
**状态**: ✅ 开发完成，可以测试
**版本**: 1.0
**日期**: 2025-12-09
