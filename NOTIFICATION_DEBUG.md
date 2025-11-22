# 通知功能调试指南

## 已实现的功能

1. ✅ 创建了 `NotificationManager.swift` - 管理本地通知
2. ✅ 在应用启动时请求通知权限
3. ✅ 在倒计时结束时发送通知
4. ✅ 支持前台和后台通知显示

## 排查步骤

### 1. 检查通知权限

在 Xcode 控制台查看日志：
- 应用启动时应该看到：`✅ 通知权限已授予` 或 `❌ 通知权限被拒绝`
- 如果看到"被拒绝"，需要在设置中手动开启

**手动开启通知权限：**
1. 打开 iPhone 设置
2. 找到 Focus 应用
3. 点击"通知"
4. 开启"允许通知"

### 2. 测试通知功能

在代码中任意位置调用测试方法：
```swift
NotificationManager.shared.sendTestNotification()
```

建议在 HomeView 的某个按钮中添加测试：
```swift
Button("测试通知") {
    NotificationManager.shared.sendTestNotification()
}
```

### 3. 检查控制台日志

倒计时结束时应该看到以下日志：
```
✅ 计时完成
📋 通知权限状态: 2  // 2 = authorized
✅ 通知已成功添加到通知中心
📬 前台显示通知  // 如果应用在前台
```

### 4. 常见问题

**问题1：应用在前台时看不到通知**
- ✅ 已解决：实现了 `UNUserNotificationCenterDelegate`
- 前台通知会以 banner 形式显示在屏幕顶部

**问题2：通知权限被拒绝**
- 解决方法：删除应用重新安装，或在设置中手动开启

**问题3：模拟器上通知不显示**
- 模拟器有时会有问题，建议在真机上测试

**问题4：通知延迟**
- 通知设置为 1 秒后触发，这是正常的
- 可以改为 0.1 秒：`timeInterval: 0.1`

### 5. 验证通知是否发送

在倒计时结束后，检查：
1. 控制台是否有 `✅ 通知已成功添加到通知中心`
2. 如果应用在前台，屏幕顶部是否有 banner
3. 如果应用在后台，通知中心是否有通知

### 6. 调试代码位置

通知发送的位置：
- `BackgroundTimerManager.swift` 第 100 行：`handleTimerCompletion()`
- `BackgroundTimerManager.swift` 第 180 行：后台计时完成

### 7. 快速测试

为了快速测试，可以将倒计时改为 10 秒：
1. 在 HomeView 中设置 `selectedMinutes = 0` (实际上是秒数/60)
2. 或者直接修改 `focusTime = 10` (10秒)

## 当前实现的通知内容

```
标题：Focus
内容：A new pal has joined your collection!
声音：系统默认声音
```

## 需要进一步帮助？

如果通知仍然不工作，请提供：
1. Xcode 控制台的完整日志
2. 设备类型（真机/模拟器）
3. iOS 版本
4. 通知权限状态（设置 > Focus > 通知）
