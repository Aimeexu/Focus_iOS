# Apple登录配置指南

## 🚀 快速开始

**当前配置：真实Apple登录**
- ✅ 使用真实的Apple登录流程
- ⚠️ 需要完成下面的配置步骤才能正常使用

## 1. Apple Developer账户要求

### 1.1 账户类型
- **免费Apple ID**：❌ 无法使用Sign in with Apple
- **付费Developer账户**：✅ 可以使用所有功能（$99/年）

### 1.2 如何获取付费账户
1. 访问 [https://developer.apple.com/programs/](https://developer.apple.com/programs/)
2. 点击"Enroll"
3. 选择个人或公司账户类型
4. 完成支付（$99/年）
5. 等待审核通过（通常1-2个工作日）

## 2. Xcode项目配置

### 1.1 添加Sign in with Apple能力
1. 在Xcode中打开项目
2. 选择项目目标（Target）
3. 点击"Signing & Capabilities"标签
4. 点击"+ Capability"按钮
5. 搜索并添加"Sign in with Apple"

### 1.2 配置Bundle Identifier
确保你的Bundle Identifier是唯一的，例如：`com.yourcompany.focus`

## 3. Apple Developer网站配置

### 3.1 登录开发者网站
1. 打开 [https://developer.apple.com](https://developer.apple.com)
2. 点击右上角"Account"
3. 使用你的付费开发者账户登录

### 3.2 创建App ID
1. 点击"Certificates, Identifiers & Profiles"
2. 选择左侧"Identifiers"
3. 点击"+"创建新的App ID
4. 选择"App IDs"类型
5. 填写以下信息：
   - **Description**: Focus App（或你的应用名称）
   - **Bundle ID**: `com.yourname.focus`（必须唯一）
   - **Platform**: iOS

### 3.3 启用Sign in with Apple
1. 在"Capabilities"部分找到"Sign In with Apple"
2. 勾选启用
3. 点击"Continue" → "Register"保存

### 3.4 配置截图示例
```
App Services 部分应该显示：
☑️ Sign In with Apple
```

## 3. 后端API配置

### 3.1 验证Apple ID Token
后端需要实现验证Apple ID Token的接口：

```
POST /app/user/apple-signin
Content-Type: application/json

{
    "identity_token": "eyJ...",
    "authorization_code": "c...",
    "user_identifier": "001234.abc...",
    "email": "user@example.com",
    "full_name": {
        "given_name": "John",
        "family_name": "Doe"
    }
}
```

### 3.2 响应格式
```json
{
    "status": "success",
    "data": {
        "accessTokenName": "token_name",
        "refreshToken": "refresh_token_value",
        "accessToken": "access_token_value",
        "user": {
            "account": "user@example.com",
            "phone": null,
            "channel": {
                "channelType": "apple",
                "description": "Apple登录频道",
                "uuid": "channel_uuid"
            },
            "nickname": "John Doe",
            "userSettings": {
                "backgroundMusic": "default"
            },
            "uuid": "user_uuid",
            "userStuffs": [],
            "createTime": 1693228800000
        }
    },
    "code": "200",
    "message": "登录成功",
    "errors": null
}
```

## 4. 测试

### 4.1 模拟器测试
- 在iOS模拟器中，Apple登录会使用测试账户
- 可以在设置 > Apple ID中配置测试账户

### 4.2 真机测试
- 需要使用真实的Apple ID
- 确保设备已登录Apple ID

## 5. 注意事项

### 5.1 隐私要求
- 如果使用Apple登录，必须将其作为主要登录选项
- 不能要求用户提供Apple已经提供的信息
- 必须遵守Apple的隐私准则

### 5.2 用户体验
- Apple登录按钮应该使用Apple提供的标准样式
- 按钮文字应该使用Apple推荐的文案

### 5.3 错误处理
- 处理用户取消登录的情况
- 处理网络错误和服务器错误
- 提供清晰的错误信息给用户

## 6. 当前实现状态

✅ 已实现的功能：
- Apple登录UI组件
- Apple登录服务类
- 错误处理机制
- 真实Apple登录流程

⏳ 待配置的项目：
- Xcode项目中的Sign in with Apple能力
- Apple Developer账户配置
- 后端API实现（可选，有fallback机制）

## 7. 使用方法

在LoginPageView中，Apple登录按钮已经集成完毕：

```swift
CustomAppleSignInButton(
    action: signInWithApple,
    isLoading: isLoading
)
```

当用户点击按钮时，会自动调用Apple登录流程，成功后会保存用户信息并跳转到主界面。