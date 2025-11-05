//
//  SettingsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct SettingsView: View {
    @State private var showLogoutAlert = false
    @State private var showThemeSelector = false
    @State private var showClearCacheAlert = false
    @State private var focusMode = true
    @State private var keepScreenOn = true
    @State private var soundsAndHaptics = true
    @State private var cloudSync = true
    @State private var selectedTheme = "Follow System"
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 用户信息部分
                    SettingsCardView {
                        let username = userManager.currentUser?.nickname ?? "Hatchling"
                        HStack {
                            // 头像
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image("penguin")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(username)
                                    .font(.appBody(size: 18))
                                    .foregroundColor(AppColors.Text.primary)
                                
                                Text("Stage 1")
                                    .font(.appBody(size: 14))
                                    .foregroundColor(AppColors.Text.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                    }
                    
                    // General 部分
                    SettingsSectionView(title: "General") {
                        VStack(spacing: 0) {
                            // Theme
                            SettingsRowCardWithValue(
                                title: "Theme",
                                value: selectedTheme,
                                action: {
                                    showThemeSelector = true
                                }
                            )
                            
                            // Focus Mode
                            SettingsToggleRowCard(
                                title: "Focus Mode",
                                isOn: $focusMode
                            )
                            
                            // Keep Screen On
                            SettingsToggleRowCard(
                                title: "Keep Screen On",
                                isOn: $keepScreenOn
                            )
                            
                            // Sounds & Haptics
                            SettingsToggleRowCard(
                                title: "Sounds & Haptics",
                                isOn: $soundsAndHaptics
                            )
                        }
                    }
                    
                    // Account & Data 部分
                    SettingsSectionView(title: "Account & Data") {
                        VStack(spacing: 0) {
                            // Cloud Sync
                            SettingsToggleRowCard(
                                title: "Cloud Sync",
                                isOn: $cloudSync
                            )
                            
                            // Clear Cache
                            Button(action: {
                                showClearCacheAlert = true
                            }) {
                                HStack {
                                    Text("Clear Cache")
                                        .font(.appBody(size: 16))
                                        .foregroundColor(AppColors.Text.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.Text.tertiary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // About FocusPal 部分
                    SettingsSectionView(title: "About FocusPal") {
                        VStack(spacing: 0) {
                            SettingsRowCard(
                                title: "Privacy Policy",
                                action: {
                                    // 隐私政策逻辑
                                }
                            )
                            
                            SettingsRowCard(
                                title: "Term of Use",
                                action: {
                                    // 使用条款逻辑
                                }
                            )
                            
                            // App Version
                            HStack {
                                Text("App Version")
                                    .font(.appBody(size: 16))
                                    .foregroundColor(AppColors.Text.primary)
                                
                                Spacer()
                                
                                Text("1.0")
                                    .font(.appBody(size: 16))
                                    .foregroundColor(AppColors.Text.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // 退出登录部分
                    SettingsCardView {
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.appBody(size: 16))
                                    .foregroundColor(AppColors.Semantic.error)
                                    .frame(width: 24)
                                
                                Text("Logout")
                                    .font(.appBody(size: 16))
                                    .foregroundColor(AppColors.Semantic.error)
                                
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
            .safeAreaInset(edge: .bottom) {
                // 为自定义TabBar留出空间 (48 + 34 = 82)
                Color.clear.frame(height: 82)
            }
            .overlay(
                showThemeSelector ? 
                ThemeSelectorAlertView(
                    isPresented: $showThemeSelector,
                    selectedTheme: $selectedTheme
                ) : nil
            )
            .overlay(
                showClearCacheAlert ? 
                ClearCacheAlertView(
                    isPresented: $showClearCacheAlert,
                    onConfirm: clearCache
                ) : nil
            )
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    private func clearCache() {
        // 清除缓存逻辑
        userManager.clearUserData()
        print("缓存已清除")
    }
    
    private func logout() {
        // 使用 UserManager 清除用户数据但保留个人设置
        userManager.clearUserDataExceptSettings()
        
        print("用户已退出登录")
        
        // 发送退出登录通知
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
}

// MARK: - 自定义卡片组件
struct SettingsCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(AppColors.Semantic.lightGray)
            .cornerRadius(12)
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appBody(size: 14))
                .foregroundColor(AppColors.Text.secondary)
                .padding(.horizontal, 4)
            
            content
                .background(AppColors.Semantic.lightGray)
                .cornerRadius(12)
        }
    }
}

struct SettingsRowCard: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.tertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsRowCardWithValue: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.primary)
                
                Spacer()
                
                Text(value)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.tertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRowCard: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.appBody(size: 16))
                .foregroundColor(AppColors.Text.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppColors.Brand.primary))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - 原有组件（保留兼容性）
struct SettingsRow: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Text.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.appBody(size: 16))
                .foregroundColor(AppColors.Text.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppColors.Brand.primary))
        }
        .padding(.vertical, 4)
    }
}

struct ThemeSelectorAlertView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTheme: String
    
    let themes = ["Follow System", "Light", "Dark"]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 主题选择选项 - 三个选项作为整体有粉色圆角背景
                VStack(spacing: 0) {
                    ForEach(themes, id: \.self) { theme in
                        HStack {
                            // 选中状态指示器 - 红色圆形带白色勾选标记
                            ZStack {
                                Circle()
                                    .fill(selectedTheme == theme ? Color.red : Color.clear)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                if selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(theme)
                                .font(.appBody(size: 16))
                                .foregroundColor(AppColors.Text.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = theme
                        }
                    }
                }
                .background(Color(red: 0.98, green: 0.94, blue: 0.94)) // 整体粉红色背景
                .cornerRadius(12)
                .padding(.horizontal, 50)
                .padding(.top, 130)

                Spacer()

                // 按钮区域
                HStack(spacing: 12) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .font(.appBody(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(AppColors.Brand.primary)
                            .cornerRadius(22)
                    }

                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .background(AppColors.Semantic.cardBg)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.horizontal, 40)
            .padding(.top, 50)
            .padding(.bottom, 130)
        }
    }
}


struct ClearCacheAlertView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Text("Free up space by removing temporary files.")
                        .font(.appBody(size: 16))
                        .foregroundColor(AppColors.Brand.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your progress and data are safe.")
                        .font(.appBody(size: 16))
                        .foregroundColor(AppColors.Brand.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 200)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        onConfirm()
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .font(.appBody(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(AppColors.Brand.primary)
                            .cornerRadius(22)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.appBody(size: 16))
                            .foregroundColor(AppColors.Text.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(22)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)

            }
            .background(AppColors.Semantic.cardBg)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.horizontal, 40)
            .padding(.top, 50)
            .padding(.bottom, 130)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserManager.shared)
}
