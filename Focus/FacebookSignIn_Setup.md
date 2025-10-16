# Facebook登录配置指南

## 🚀 快速开始

**当前配置：真实Facebook登录**
- ✅ 使用真实的Facebook登录流程
- ✅ Facebook SDK已通过SPM集成
- ⚠️ 需要完成下面的配置步骤才能正常使用

## 1. Facebook开发者账户配置

### 1.1 创建Facebook开发者账户
1. 访问 [https://developers.facebook.com](https://developers.facebook.com)
2. 使用Facebook账户登录
3. 点击"开始使用"并完成开发者注册
4. 验证手机号码（如果需要）

### 1.2 创建Facebook应用
1. 在Facebook开发者控制台中点击"创建应用"
2. 选择应用类型：**"消费者"**
3. 填写应用信息：
   - **应用名称**: Focus（或你的应用名称）
   - **应用联系邮箱**: 你的邮箱地址
4. 点击"创建应用"

### 1.3 配置iOS平台
1. 在应用控制台中，点击"添加产品"
2. 找到"Facebook登录"，点击"设置"
3. 选择"iOS"平台
4. 填写iOS配置：
   - **Bundle ID**: `com.yourname.focus`（与Xcode项目中的Bundle ID一致）
   - **iPhone商店ID**: 留空（开发阶段）
   - **iPad商店ID**: 留空（开发阶段）

### 1.4 获取应用ID和密钥
1. 在应用控制台的"设置" > "基本"中找到：
   - **应用编号（App ID）**: 记录这个数字
   - **应用密钥（App Secret）**: 点击"显示"并记录

## 2. Xcode项目配置

### 2.1 配置Info.plist
在你的`Info.plist`文件中添加以下配置：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string></string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fb{your-app-id}</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>
<string>{your-app-id}</string>

<key>FacebookClientToken</key>
<string>{your-client-token}</string>

<key>FacebookDisplayName</key>
<string>Focus</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fbapi20130214</string>
    <string>fbapi20130410</string>
    <string>fbapi20130702</string>
    <string>fbapi20131010</string>
    <string>fbapi20131219</string>
    <string>fbapi20140410</string>
    <string>fbapi20140116</string>
    <string>fbapi20150313</string>
    <string>fbapi20150629</string>
    <string>fbapi20160328</string>
    <string>fbauth</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
```

**注意**：将`{your-app-id}`替换为你的Facebook应用ID，将`{your-client-token}`替换为你的客户端令牌。

### 2.2 获取客户端令牌
1. 在Facebook开发者控制台中
2. 进入"设置" > "高级"
3. 在"安全"部分找到"客户端令牌"
4. 复制这个令牌到Info.plist中

### 2.3 配置URL Scheme
确保URL Scheme格式正确：`fb{your-app-id}`

例如，如果你的Facebook应用ID是`123456789012345`，那么URL Scheme应该是`fb123456789012345`。

## 3. Facebook应用设置

### 3.1 配置有效的OAuth重定向URI
1. 在Facebook开发者控制台中
2. 进入"Facebook登录" > "设置"
3. 在"有效的OAuth重定向URI"中添加：
   ```
   fb{your-app-id}://authorize
   ```

### 3.2 配置应用域名（可选）
如果你有网站，可以在"应用域名"中添加你的域名。

### 3.3 隐私政策URL（生产环境必需）
在应用上线前，需要在"设置" > "基本"中添加隐私政策URL。

## 4. 测试配置

### 4.1 开发模式测试
- 在开发模式下，只有应用管理员、开发者和测试用户可以登录
- 可以在"角色" > "测试用户"中创建测试账户

### 4.2 创建测试用户
1. 在Facebook开发者控制台中
2. 进入"角色" > "测试用户"
3. 点击"添加测试用户"
4. 设置测试用户的权限和信息

### 4.3 真机测试
Facebook登录需要在真机上测试：
1. 确保设备已安装Facebook应用（推荐）
2. 或者确保设备可以访问Facebook网站
3. 运行应用并测试登录流程

## 5. 应用审核（生产环境）

### 5.1 应用审核要求
要在生产环境中使用Facebook登录，需要通过Facebook应用审核：

1. **基本信息完整**：应用名称、描述、图标、隐私政策等
2. **权限申请**：说明为什么需要`email`权限
3. **使用说明**：提供应用的使用流程截图或视频

### 5.2 权限说明
当前应用申请的权限：
- `public_profile`：获取用户基本信息（姓名、头像等）
- `email`：获取用户邮箱地址

### 5.3 审核流程
1. 在开发者控制台中点击"应用审核"
2. 提交权限申请
3. 提供详细的使用说明
4. 等待Facebook审核（通常1-7个工作日）

## 6. 常见问题

### 6.1 登录失败
- 检查Bundle ID是否与Facebook应用配置一致
- 检查URL Scheme格式是否正确
- 检查Info.plist配置是否完整

### 6.2 权限被拒绝
- 用户可能拒绝了邮箱权限，应用应该优雅处理
- 可以只使用基本信息进行登录

### 6.3 网络错误
- 确保设备网络连接正常
- 确保可以访问Facebook服务

### 6.4 应用审核被拒绝
- 仔细阅读拒绝原因
- 完善应用信息和使用说明
- 重新提交审核

## 7. 安全最佳实践

### 7.1 保护应用密钥
- 不要在客户端代码中硬编码应用密钥
- 应用密钥只在服务器端使用

### 7.2 验证访问令牌
- 后端应该验证Facebook访问令牌的有效性
- 使用Facebook Graph API验证令牌

### 7.3 用户数据保护
- 遵守数据保护法规（如GDPR）
- 只收集必要的用户信息
- 提供用户数据删除功能

## 8. 配置示例

### 8.1 完整的Info.plist配置示例
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 其他配置... -->
    
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string></string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>fb123456789012345</string>
            </array>
        </dict>
    </array>
    
    <key>FacebookAppID</key>
    <string>123456789012345</string>
    
    <key>FacebookClientToken</key>
    <string>your-client-token-here</string>
    
    <key>FacebookDisplayName</key>
    <string>Focus</string>
    
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>fbapi</string>
        <string>fbapi20130214</string>
        <string>fbapi20130410</string>
        <string>fbapi20130702</string>
        <string>fbapi20131010</string>
        <string>fbapi20131219</string>
        <string>fbapi20140410</string>
        <string>fbapi20140116</string>
        <string>fbapi20150313</string>
        <string>fbapi20150629</string>
        <string>fbapi20160328</string>
        <string>fbauth</string>
        <string>fb-messenger-share-api</string>
        <string>fbauth2</string>
        <string>fbshareextension</string>
    </array>
</dict>
</plist>
```

## 9. 当前实现状态

✅ 已完成：
- Facebook SDK集成
- Facebook登录服务实现
- UI组件实现
- 错误处理机制
- 用户数据保存

⏳ 需要配置：
- Facebook开发者应用创建
- Info.plist配置
- 后端API实现（可选）

配置完成后，Facebook登录功能即可正常使用。