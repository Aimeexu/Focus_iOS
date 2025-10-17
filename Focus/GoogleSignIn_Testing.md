# Google登录功能测试指南

## 测试前准备

### 1. 确认配置完成
- [ ] Google Cloud Console项目已创建
- [ ] OAuth 2.0客户端ID已配置
- [ ] GoogleService-Info.plist已添加到项目
- [ ] Info.plist中的GIDClientID已配置
- [ ] URL Schemes已正确设置
- [ ] SPM依赖已添加

### 2. 检查代码集成
- [ ] GoogleSignInService.swift已创建
- [ ] GoogleSignInButton.swift已创建
- [ ] UserManager中saveGoogleLoginData方法已添加
- [ ] LoginPageView已更新
- [ ] FocusApp.swift已配置Google Sign-In

## 测试步骤

### 1. 基础配置测试

#### 检查Google配置
1. 运行应用
2. 查看控制台输出
3. 应该看到: `✅ Google Sign-In配置成功`
4. 如果看到错误信息，检查Info.plist配置

#### 检查UI集成
1. 导航到登录页面
2. 确认Google登录按钮显示正常
3. 按钮应该显示Google图标
4. 按钮应该可以点击

### 2. 登录流程测试

#### 正常登录流程
1. **点击Google登录按钮**
   - 按钮应该显示加载状态
   - 应该弹出Google登录页面

2. **Google认证页面**
   - 选择或输入Google账户
   - 完成认证流程
   - 授权应用访问基本信息

3. **登录成功处理**
   - 应用应该返回到登录页面
   - 控制台应该显示: `✅ Google登录成功`
   - 应该自动跳转到主界面

#### 用户取消登录
1. 点击Google登录按钮
2. 在Google认证页面点击取消
3. 应该返回登录页面
4. 显示适当的错误信息

#### 网络错误测试
1. 断开网络连接
2. 点击Google登录按钮
3. 应该显示网络错误信息
4. 恢复网络后重试应该正常

### 3. 数据验证测试

#### 用户信息保存
登录成功后，检查以下数据是否正确保存：

```swift
// 在控制台或调试器中检查
let userDefaults = UserDefaults.standard
print("Token: \(userDefaults.string(forKey: "auth_token") ?? "nil")")
print("用户UUID: \(userDefaults.string(forKey: "user_uuid") ?? "nil")")
print("用户账户: \(userDefaults.string(forKey: "user_account") ?? "nil")")
print("登录方式: \(userDefaults.string(forKey: "login_method") ?? "nil")")
```

#### 登录状态持久化
1. 成功登录后关闭应用
2. 重新打开应用
3. 应该自动保持登录状态
4. 不需要重新登录

### 4. 错误处理测试

#### 配置错误
1. 临时修改Info.plist中的GIDClientID为无效值
2. 重新运行应用
3. 应该看到配置错误信息
4. Google登录按钮应该仍然显示但点击会失败

#### 服务器错误
1. 临时修改GoogleSignInService中的API端点
2. 尝试登录
3. 应该显示服务器错误信息
4. 不应该崩溃

## 预期结果

### 成功场景
- ✅ Google登录页面正常弹出
- ✅ 用户信息正确获取和保存
- ✅ 登录状态正确更新
- ✅ 自动跳转到主界面
- ✅ 控制台显示成功日志

### 错误场景
- ✅ 用户取消时显示适当信息
- ✅ 网络错误时显示错误信息
- ✅ 配置错误时显示警告信息
- ✅ 应用不会崩溃

## 调试技巧

### 1. 启用详细日志
在GoogleSignInService中添加更多日志输出：

```swift
print("🔍 Google登录开始")
print("🔍 获取到ID Token: \(idToken.prefix(20))...")
print("🔍 发送请求到服务器...")
print("🔍 服务器响应: \(response)")
```

### 2. 检查网络请求
使用网络调试工具（如Charles或Proxyman）监控：
- Google OAuth请求
- 应用服务器API请求
- 响应数据格式

### 3. 验证Token
可以使用Google的Token验证工具验证ID Token：
```
https://oauth2.googleapis.com/tokeninfo?id_token=YOUR_ID_TOKEN
```

## 常见问题排查

### 1. "无法获取Google客户端ID"
- 检查GoogleService-Info.plist是否在项目中
- 检查Info.plist中的GIDClientID配置
- 确认文件被正确添加到target

### 2. "Google登录页面不弹出"
- 检查URL Schemes配置
- 确认Bundle ID匹配
- 检查网络连接

### 3. "登录成功但数据未保存"
- 检查UserManager.saveGoogleLoginData方法
- 验证服务器响应格式
- 检查数据转换逻辑

### 4. "应用崩溃"
- 检查强制解包的地方
- 验证异步代码的错误处理
- 检查UI更新是否在主线程

## 性能测试

### 1. 登录速度
- 记录从点击按钮到登录完成的时间
- 正常情况下应该在3-10秒内完成

### 2. 内存使用
- 监控登录过程中的内存使用
- 确认没有内存泄漏

### 3. 网络使用
- 监控网络请求的大小和频率
- 确认没有不必要的重复请求

完成所有测试后，Google登录功能应该可以稳定运行！