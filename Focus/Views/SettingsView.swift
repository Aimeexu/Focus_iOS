//
//  SettingsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct SettingsView: View {
    @State private var showLogoutAlert = false
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息部分
                Section {
                    let username = userManager.currentUser?.nickname ?? "未登录用户"
                    HStack {
                        // 头像
                        Circle()
                            .fill(AppColors.Brand.primary)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(String(username.prefix(1)).uppercased())
                                    .font(.appButton(size: 22))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(username)
                                .font(.appBody(size: 18))
                                .foregroundColor(AppColors.Text.primary)
                            
                            Text(userManager.currentUser?.account ?? "未登录")
                                .font(.appBody(size: 16))
                                .foregroundColor(AppColors.Text.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // 设置选项
                Section("通用") {
                    SettingsRow(
                        icon: "bell",
                        title: "通知设置",
                        action: {
                            // 通知设置逻辑
                        }
                    )
                    
                    SettingsRow(
                        icon: "moon",
                        title: "深色模式",
                        action: {
                            // 深色模式切换逻辑
                        }
                    )
                    
                    SettingsRow(
                        icon: "globe",
                        title: "语言设置",
                        action: {
                            // 语言设置逻辑
                        }
                    )
                }
                
                // 关于部分
                Section("关于") {
                    SettingsRow(
                        icon: "info.circle",
                        title: "关于应用",
                        action: {
                            // 关于应用逻辑
                        }
                    )
                    
                    SettingsRow(
                        icon: "doc.text",
                        title: "隐私政策",
                        action: {
                            // 隐私政策逻辑
                        }
                    )
                    
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "帮助与支持",
                        action: {
                            // 帮助支持逻辑
                        }
                    )
                }
                
                // 退出登录
                Section {
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.appBody(size: 16))
                                .foregroundColor(AppColors.Semantic.error)
                                .frame(width: 24)
                            
                            Text("退出登录")
                                .font(.appBody(size: 16))
                                .foregroundColor(AppColors.Semantic.error)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("设置")
            .alert("确认退出", isPresented: $showLogoutAlert) {
                Button("取消", role: .cancel) { }
                Button("退出", role: .destructive) {
                    logout()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
        }
    }
    
    private func logout() {
        // 使用 UserManager 清除用户数据
        userManager.clearUserData()
        
        print("用户已退出登录")
        
        // 发送退出登录通知
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Brand.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.appBody(size: 12))
                    .foregroundColor(AppColors.Text.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
