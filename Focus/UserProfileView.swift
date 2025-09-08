//
//  UserProfileView.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI

// MARK: - 用户资料视图
struct UserProfileView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var showingLogoutAlert = false
    @State private var newNickname = ""
    @State private var isEditingNickname = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if userManager.isLoggedIn, let user = userManager.currentUser {
                        // 用户头像区域
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(String(user.nickname.prefix(1)).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                )

                                HStack {
                                    Text(user.nickname)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Button(action: {
                                        newNickname = user.nickname
                                        isEditingNickname = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                }

                            Text(user.account)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // 用户信息卡片
                        VStack(alignment: .leading, spacing: 16) {
                            Text("基本信息")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                InfoRow(title: "用户ID", value: user.uuid)
                                InfoRow(title: "账号", value: user.account)
                                InfoRow(title: "手机号", value: user.phone ?? "未绑定")
                                InfoRow(title: "注册时间", value: formatCreateTime(user.createTime))
                                InfoRow(title: "登录方式", value: getLoginMethodDisplay())
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        }
                        
                        // 登出按钮
                        Button("登出") {
                            showingLogoutAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.red)
                        
                    } else {
                        // 未登录状态
                        VStack(spacing: 20) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            Text("未登录")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("请先登录以查看个人信息")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("去登录") {
                                // 这里可以导航到登录页面
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("个人资料")
            .onAppear {
                userManager.loadUserData()
            }
            .alert("确认登出", isPresented: $showingLogoutAlert) {
                Button("取消", role: .cancel) { }
                Button("登出", role: .destructive) {
                    userManager.clearUserData()
                }
            } message: {
                Text("登出后需要重新登录才能使用完整功能")
            }
        }
    }
    
    private func getLoginMethodDisplay() -> String {
        switch userManager.getLoginMethod() {
        case "apple":
            return "Apple 登录"
        case "email":
            return "邮箱登录"
        default:
            return "未知"
        }
    }
    
    private func formatCreateTime(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 信息行组件
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - 预览
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
