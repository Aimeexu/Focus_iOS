//
//  UserManagerTestView.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI

// MARK: - UserManager 测试视图
struct UserManagerTestView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var testAccount = "test@example.com"
    @State private var testPassword = "123456"
    @State private var isLoading = false
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 登录状态显示
                    VStack(spacing: 12) {
                        Text("登录状态")
                            .font(.headline)
                        
                        HStack {
                            Circle()
                                .fill(userManager.isLoggedIn ? Color.green : Color.red)
                                .frame(width: 12, height: 12)
                            
                            Text(userManager.isLoggedIn ? "已登录" : "未登录")
                                .font(.body)
                        }
                        
                        if let user = userManager.currentUser {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("当前用户: \(user.nickname)")
                                Text("账号: \(user.account)")
                                Text("UUID: \(user.uuid)")
                            }
                            .font(.caption)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // 测试登录
                    if !userManager.isLoggedIn {
                        VStack(spacing: 16) {
                            Text("测试登录")
                                .font(.headline)
                            
                            VStack(spacing: 12) {
                                TextField("账号", text: $testAccount)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                SecureField("密码", text: $testPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack(spacing: 12) {
                                Button("邮箱登录测试") {
                                    testEmailLogin()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isLoading)
                                
                                Button("Apple登录测试") {
                                    testAppleLogin()
                                }
                                .buttonStyle(.bordered)
                                .disabled(isLoading)
                            }
                            
                            Button("创建测试用户") {
                                createTestUser()
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    // 用户信息管理
                    if userManager.isLoggedIn {
                        VStack(spacing: 16) {
                            Text("用户信息管理")
                                .font(.headline)
                            
                            VStack(spacing: 12) {
                                Button("更新昵称") {
                                    let newNickname = "测试用户_\(Int.random(in: 1000...9999))"
                                    userManager.updateUserNickname(newNickname)
                                    message = "昵称已更新为: \(newNickname)"
                                }
                                .buttonStyle(.bordered)
                                
                                Button("更新背景音乐") {
                                    let musics = ["default", "rain", "wave", "forest", "silent"]
                                    let randomMusic = musics.randomElement() ?? "default"
                                    userManager.updateBackgroundMusic(randomMusic)
                                    message = "背景音乐已更新为: \(randomMusic)"
                                }
                                .buttonStyle(.bordered)
                                
                                Button("添加测试物品") {
                                    addTestUserStuff()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    // 调试功能
                    VStack(spacing: 16) {
                        Text("调试功能")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            Button("打印所有 UserDefaults") {
                                userManager.printAllUserDefaults()
                                message = "已打印到控制台"
                            }
                            .buttonStyle(.bordered)
                            
                            Button("检查登录状态") {
                                let status = userManager.checkLoginStatus()
                                message = "登录状态检查结果: \(status ? "有效" : "无效")"
                            }
                            .buttonStyle(.bordered)
                            
                            Button("重新加载用户数据") {
                                userManager.loadUserData()
                                message = "用户数据已重新加载"
                            }
                            .buttonStyle(.bordered)
                            
                            if userManager.isLoggedIn {
                                Button("清除用户数据") {
                                    userManager.clearUserData()
                                    message = "用户数据已清除"
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // 消息显示
                    if !message.isEmpty {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if isLoading {
                        ProgressView("处理中...")
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("UserManager 测试")
        }
    }
    
    // MARK: - 测试方法
    
    private func testEmailLogin() {
        isLoading = true
        message = ""
        
        Task {
            do {
                let response = try await AuthService.shared.login(
                    account: testAccount,
                    password: testPassword
                )
                
                await MainActor.run {
                    if response.success {
                        message = "邮箱登录成功！"
                    } else {
                        message = "邮箱登录失败: \(response.message)"
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    message = "邮箱登录错误: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func testAppleLogin() {
        isLoading = true
        message = ""
        
        Task {
            do {
                let response = try await AppleSignInService.shared.signInWithApple()
                
                await MainActor.run {
                    if response.success {
                        message = "Apple登录成功！"
                    } else {
                        message = "Apple登录失败: \(response.message)"
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    message = "Apple登录错误: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func createTestUser() {
        // 创建一个测试用户数据
        let testChannel = Channel(
            channelType: "TEST",
            description: "测试频道",
            uuid: "test_channel_\(UUID().uuidString)"
        )
        
        let testUserSettings = UserSettings(
            backgroundMusic: "default"
        )
        
        let testUserInfo = UserInfo(
            account: testAccount,
            phone: nil,
            channel: testChannel,
            nickname: "测试用户",
            userSettings: testUserSettings,
            uuid: "test_user_\(UUID().uuidString)",
            userStuffs: [],
            createTime: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        let testAuthData = AuthData(
            token: "test_token_\(Date().timeIntervalSince1970)",
            user: testUserInfo,
            expiresIn: 3600
        )
        
        userManager.saveLoginData(testAuthData, loginMethod: "test")
        message = "测试用户已创建并登录"
    }
    
    private func addTestUserStuff() {
        var currentStuffs = userManager.getUserStuffs()
        
        let newStuff = UserStuff(
            amount: Int.random(in: 1...10),
            createTime: DateFormatter().string(from: Date()),
            updateTime: DateFormatter().string(from: Date())
        )
        
        currentStuffs.append(newStuff)
        userManager.updateUserStuffs(currentStuffs)
        
        message = "已添加测试物品，数量: \(newStuff.amount)"
    }
}

// MARK: - 预览
struct UserManagerTestView_Previews: PreviewProvider {
    static var previews: some View {
        UserManagerTestView()
    }
}
