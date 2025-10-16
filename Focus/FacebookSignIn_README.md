# Facebook登录功能说明

## 当前状态
✅ **真实Facebook登录已启用**
- 使用真实的Facebook登录API
- 无模拟数据，直接调用Facebook SDK
- 保持与Apple登录相同的规范和架构

## 使用前准备

### 必需配置
1. **Facebook开发者账户**（免费）
2. **Facebook应用配置**：创建Facebook应用并配置iOS平台
3. **Xcode项目配置**：添加URL Scheme和Info.plist配置
4. **Facebook SDK集成**：通过SPM已完成

### 配置步骤
详细配置步骤请参考 `FacebookSignIn_Setup.md` 文件。

## 功能特性

### ✅ 已实现
- 真实Facebook登录流程
- 用户信息获取（姓名、邮箱、用户ID）
- 登录状态管理
- 错误处理
- 自动保存用户信息
- 与Apple登录相同的UI规范

### 🔄 Fallback机制
如果后端API未实现，会自动使用Facebook提供的用户信息创建本地用户数据。

## 使用方法

在LoginPageView中点击Facebook图标按钮即可启动Facebook登录流程。

## 注意事项

1. **真机测试**：Facebook登录需要在真机上测试，模拟器可能有限制
2. **网络要求**：需要网络连接来验证Facebook凭证
3. **用户体验**：首次登录时Facebook会询问用户是否分享邮箱和基本信息
4. **权限申请**：当前申请`public_profile`和`email`权限

## 错误处理

常见错误及解决方案：
- **用户取消登录**：正常行为，不需要特殊处理
- **网络错误**：检查网络连接
- **配置错误**：检查Facebook应用配置和Xcode配置
- **权限被拒绝**：用户可能拒绝了某些权限，应用应该优雅处理

## 架构设计

### 服务层
- `FacebookSignInService`：核心登录服务，处理Facebook SDK交互
- 异步/await模式，与Apple登录保持一致

### UI层
- `FacebookIconButton`：社交登录区域的图标按钮
- `CustomFacebookSignInButton`：完整的Facebook登录按钮（备用）
- 与Apple登录按钮保持相同的设计规范

### 数据层
- 使用`AchievementLoginResponse`和`AchievementLoginData`模型
- 通过`UserManager.saveFacebookLoginData`保存登录信息
- 与Apple登录使用相同的数据结构

## API集成

### 后端接口
```
POST /app/user/login/facebook
Content-Type: application/json

{
    "accessToken": "facebook_access_token",
    "userID": "facebook_user_id",
    "email": "user@example.com",
    "name": "User Name",
    "state": "random_state",
    "deviceId": "device_uuid",
    "operateDate": "2025-10-10 12:00:00",
    "timeZone": "Asia/Shanghai"
}
```

### 响应格式
使用与Apple登录相同的`AchievementLoginResponse`格式。

## 安全考虑

1. **访问令牌验证**：后端应验证Facebook访问令牌的有效性
2. **用户信息验证**：确保用户信息来自可信源
3. **状态参数**：使用随机状态参数防止CSRF攻击
4. **设备标识**：记录设备信息用于安全审计

## 测试

### 开发测试
- 使用Facebook测试用户进行测试
- 在Facebook开发者控制台中可以创建测试用户

### 生产测试
- 需要Facebook应用审核通过
- 确保应用符合Facebook平台政策

## 当前实现状态

✅ 已实现的功能：
- Facebook登录UI组件
- Facebook登录服务类
- 错误处理机制
- 真实Facebook登录流程
- 用户数据保存和管理

⏳ 待配置的项目：
- Facebook开发者应用配置
- Xcode项目URL Scheme配置
- Info.plist Facebook配置
- 后端API实现（可选，有fallback机制）

## 使用方法

在LoginPageView中，Facebook登录按钮已经集成完毕：

```swift
FacebookIconButton(
    action: signInWithFacebook,
    isLoading: isFacebookLoading
)
```

当用户点击按钮时，会自动调用Facebook登录流程，成功后会保存用户信息并跳转到主界面。