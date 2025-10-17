# Google登录配置快速修复指南

## 问题
错误信息: "No active configuration. Make sure GIDClientID is set in Info.plist."

## 已完成的修复
✅ **Info.plist已更新** - 添加了GIDClientID配置
✅ **GoogleService-Info.plist已创建** - 示例配置文件
✅ **代码已优化** - 支持从两个配置文件读取客户端ID

## 需要你完成的步骤

### 1. 获取真实的Google客户端ID

#### 方法A: 从Google Cloud Console获取
1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建或选择项目
3. 启用 Google Sign-In API
4. 创建 OAuth 2.0 客户端ID (iOS类型)
5. 输入你的Bundle ID
6. 下载 GoogleService-Info.plist

#### 方法B: 如果你已有Google项目
1. 在Google Cloud Console中找到你的项目
2. 导航到 "APIs & Services" > "Credentials"
3. 找到你的iOS OAuth客户端
4. 下载配置文件

### 2. 更新配置文件

#### 选项1: 使用GoogleService-Info.plist (推荐)
1. 用你从Google下载的真实文件替换 `Focus/GoogleService-Info.plist`
2. 确保文件被添加到Xcode项目target中

#### 选项2: 只更新Info.plist
如果你不想使用GoogleService-Info.plist，只需更新Info.plist中的GIDClientID:

```xml
<key>GIDClientID</key>
<string>你的真实客户端ID.apps.googleusercontent.com</string>
```

### 3. 验证Bundle ID
确保以下位置的Bundle ID一致:
- Xcode项目设置
- Google Cloud Console OAuth配置
- GoogleService-Info.plist (如果使用)

### 4. 测试配置

运行应用后，查看控制台输出:
- ✅ 成功: "✅ Google Sign-In配置成功，客户端ID: xxx..."
- ❌ 失败: "❌ 无法获取Google客户端ID"

## 当前配置状态

### Info.plist
```xml
<key>GIDClientID</key>
<string>873632466405-22l74g6uonlv4gcev4v2h4k0p2hl5f6o.apps.googleusercontent.com</string>
```

### URL Schemes
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.873632466405-22l74g6uonlv4gcev4v2h4k0p2hl5f6o</string>
</array>
```

## 注意事项

1. **示例ID**: 当前使用的是示例客户端ID，你需要替换为你自己的
2. **Bundle ID**: 确保Google配置中的Bundle ID与你的项目匹配
3. **真机测试**: Google登录只能在真机上测试
4. **网络连接**: 确保设备有网络连接

## 如果仍有问题

### 检查清单
- [ ] Google Cloud Console项目已创建
- [ ] OAuth 2.0客户端ID已配置
- [ ] Bundle ID在所有地方都一致
- [ ] GoogleService-Info.plist已正确添加到项目
- [ ] 或者Info.plist中的GIDClientID已正确配置
- [ ] URL Schemes已配置
- [ ] 在真机上测试

### 调试步骤
1. 检查控制台输出的配置信息
2. 验证客户端ID格式正确
3. 确认网络连接正常
4. 检查Xcode项目的Bundle ID设置

完成这些步骤后，Google登录应该可以正常工作了！