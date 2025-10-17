# Google登录配置指南

## 前置条件

1. **Google Cloud Console项目**
2. **iOS应用Bundle ID**
3. **Xcode项目配置**

## 配置步骤

### 1. Google Cloud Console配置

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 启用 Google Sign-In API：
   - 导航到 "APIs & Services" > "Library"
   - 搜索 "Google Sign-In API"
   - 点击启用

### 2. 创建OAuth 2.0客户端ID

1. 在Google Cloud Console中，导航到 "APIs & Services" > "Credentials"
2. 点击 "Create Credentials" > "OAuth client ID"
3. 选择 "iOS" 作为应用类型
4. 输入以下信息：
   - **Name**: 你的应用名称
   - **Bundle ID**: 你的iOS应用Bundle ID（例如：com.yourcompany.yourapp）

### 3. 下载配置文件

1. 创建完成后，下载 `GoogleService-Info.plist` 文件
2. 将此文件添加到你的Xcode项目根目录
3. 确保文件被添加到项目target中

### 4. 配置Info.plist

在你的 `Info.plist` 文件中添加以下配置：

```xml
<!-- Google客户端ID -->
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID_HERE</string>

<!-- URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>GoogleSignIn</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- 这里填入你的REVERSED_CLIENT_ID -->
            <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>
```

**注意**: 
- `YOUR_CLIENT_ID_HERE` 替换为你的Google客户端ID
- `YOUR_REVERSED_CLIENT_ID_HERE` 替换为你的反向客户端ID（在GoogleService-Info.plist中可以找到）

### 5. SPM依赖配置

你已经添加了Google Sign-In SDK：
```
https://github.com/google/GoogleSignIn-iOS
```

### 6. 应用委托配置

在你的 `AppDelegate.swift` 或 `App.swift` 中添加：

```swift
import GoogleSignIn

// 在应用启动时配置
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 从GoogleService-Info.plist获取配置
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let clientId = plist["CLIENT_ID"] as? String else {
        fatalError("无法找到GoogleService-Info.plist或CLIENT_ID")
    }
    
    guard let config = GIDConfiguration(clientID: clientId) else {
        fatalError("无法创建Google配置")
    }
    
    GIDSignIn.sharedInstance.configuration = config
    
    return true
}

// 处理URL回调
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
```

### 7. SwiftUI应用配置

如果你使用SwiftUI的App结构，在你的主App文件中：

```swift
import SwiftUI
import GoogleSignIn

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
```

## 测试配置

1. **真机测试**: Google登录需要在真机上测试
2. **网络连接**: 确保设备有网络连接
3. **Bundle ID匹配**: 确保Xcode项目的Bundle ID与Google Console中配置的一致

## 常见问题

### 1. "无法获取Google客户端ID"
- 检查 `GoogleService-Info.plist` 是否正确添加到项目中
- 确认 `Info.plist` 中的 `GIDClientID` 配置正确

### 2. "URL Scheme错误"
- 检查 `Info.plist` 中的 `CFBundleURLSchemes` 配置
- 确认使用的是 `REVERSED_CLIENT_ID`，不是 `CLIENT_ID`

### 3. "登录失败"
- 检查网络连接
- 确认Bundle ID匹配
- 检查Google Cloud Console中的OAuth配置

### 4. "无法获取根视图控制器"
- 这通常在SwiftUI应用中出现
- 确保正确配置了 `onOpenURL` 处理器

## 安全注意事项

1. **不要在代码中硬编码客户端密钥**
2. **使用HTTPS进行所有网络请求**
3. **验证服务器端的ID Token**
4. **定期轮换客户端密钥**

## 后端集成

确保你的后端API支持Google登录验证：
- 验证ID Token的有效性
- 从Google获取用户信息
- 创建或更新用户账户
- 返回应用所需的认证令牌

## 调试技巧

1. **启用详细日志**:
   ```swift
   // 在开发环境中启用
   #if DEBUG
   GIDSignIn.sharedInstance.configuration?.serverClientID = "your-server-client-id"
   #endif
   ```

2. **检查配置**:
   ```swift
   print("Google配置: \(GIDSignIn.sharedInstance.configuration?.clientID ?? "未配置")")
   ```

3. **监控网络请求**: 使用网络调试工具查看API调用

配置完成后，你就可以使用Google登录功能了！