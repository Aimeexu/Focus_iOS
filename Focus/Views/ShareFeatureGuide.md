# 成就分享功能说明

## 功能概述
在获取奖励（成就/海报）时，用户可以通过分享按钮将成就分享到 Facebook 或其他社交平台。

## 实现的功能

### 1. ShareAchievementView（分享视图）
- **位置**: `Focus/Views/ShareAchievementView.swift`
- **功能**:
  - 显示成就的详细信息（图片、标题、描述、徽章数量）
  - 提供 Facebook 分享按钮
  - 提供通用分享按钮（支持更多平台）
  - 支持远程图片和本地图片
  - 优雅的弹窗设计

### 2. 分享到 Facebook
- 使用 Facebook SDK 的 `ShareDialog`
- 支持分享图片和文字
- 自动生成分享内容：成就标题和描述

### 3. 分享到其他平台
- 使用 iOS 系统原生分享面板 (`UIActivityViewController`)
- 支持分享到：
  - 微信
  - Twitter
  - Instagram
  - 邮件
  - 短信
  - 等其他系统支持的应用

## 使用方式

### 在 AchievementsView 中
1. 点击已解锁的成就卡片
2. 弹出分享视图
3. 选择分享平台（Facebook 或 More）
4. 完成分享

### 在 PostingView 中
1. 点击已解锁的海报卡片
2. 弹出分享视图
3. 选择分享平台
4. 完成分享

## 技术细节

### 依赖项
- `UIKit`: 系统分享面板
- 无需额外的第三方 SDK

### 关键代码
```swift
// 在视图中添加分享 overlay
.overlay(shareOverlay)

// 分享 overlay 定义
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
```

### 分享内容格式
```
我在 Focus 应用中获得了成就：[成就标题]！
[成就描述]
```

## 注意事项

1. **Facebook 分享**:
   - 优先尝试打开 Facebook 应用
   - 如果未安装 Facebook 应用，使用系统分享面板
   - 用户可以在系统分享面板中选择 Facebook

2. **图片分享**:
   - 远程图片会先下载后分享
   - 本地图片直接从 Assets 读取
   - 下载失败时仍可分享文字内容

3. **iPad 支持**:
   - 系统分享面板在 iPad 上以 popover 形式显示
   - 已适配 iPad 的显示位置

## 未来改进建议

1. 添加分享成功/失败的反馈提示
2. 支持自定义分享文案
3. 添加分享统计功能
4. 支持生成分享海报图片
5. 添加更多社交平台的直接分享（如 Twitter、Instagram）
