# Apple登录功能说明

## 当前状态
✅ **真实Apple登录已启用**
- 使用真实的Apple登录API
- 无模拟数据，直接调用系统Apple登录

## 使用前准备

### 必需配置
1. **付费Apple Developer账户** ($99/年)
2. **Xcode项目配置**：添加"Sign in with Apple"能力
3. **Apple Developer网站配置**：启用App ID的Apple登录功能

### 配置步骤
详细配置步骤请参考 `AppleSignIn_Setup.md` 文件。

## 功能特性

### ✅ 已实现
- 真实Apple登录流程
- 用户信息获取（姓名、邮箱）
- 登录状态管理
- 错误处理
- 自动保存用户信息

### 🔄 Fallback机制
如果后端API未实现，会自动使用Apple提供的用户信息创建本地用户数据。

## 使用方法

在LoginPageView中点击"Continue with Apple"按钮即可启动Apple登录流程。

## 注意事项

1. **真机测试**：Apple登录需要在真机上测试，模拟器可能有限制
2. **网络要求**：需要网络连接来验证Apple凭证
3. **用户体验**：首次登录时Apple会询问用户是否分享邮箱和姓名信息

## 错误处理

常见错误及解决方案：
- **用户取消登录**：正常行为，不需要特殊处理
- **网络错误**：检查网络连接
- **配置错误**：检查Xcode和Apple Developer配置
- **凭证无效**：可能是配置问题，检查Bundle ID和能力设置