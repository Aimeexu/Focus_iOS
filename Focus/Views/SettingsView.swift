//
//  SettingsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct SettingsView: View {
    @State private var showLogoutAlert = false
    @State private var showClearCacheAlert = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false
    @State private var keepScreenOn = UserDefaults.standard.bool(forKey: "keepScreenOn")
    @State private var endOfFocusSounds = UserDefaults.standard.bool(forKey: "endOfFocusSounds")
    @State private var endOfFocusHaptics = UserDefaults.standard.bool(forKey: "endOfFocusHaptics")
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
                            // Keep Screen On
                            SettingsToggleRowCard(
                                title: "Keep Screen On",
                                isOn: $keepScreenOn
                            )
                            
                            // End-of-Focus Sounds
                            SettingsToggleRowCard(
                                title: "End-of-Focus Sounds",
                                isOn: $endOfFocusSounds
                            )
                            
                            // End-of-Focus Haptics
                            SettingsToggleRowCard(
                                title: "End-of-Focus Haptics",
                                isOn: $endOfFocusHaptics
                            )
                        }
                    }
                    
                    // Account & Data 部分
                    SettingsSectionView(title: "Account & Data") {
                        VStack(spacing: 0) {
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
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
                                    showPrivacyPolicy = true
                                }
                            )
                            
                            SettingsRowCard(
                                title: "Term of Use",
                                action: {
                                    showTermsOfUse = true
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
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
            .fullScreenCover(isPresented: $showPrivacyPolicy) {
                if let url = URL(string: "https://www.flowhaventech.com/privacy-policy.html") {
                    WebViewScreen(url: url, title: "Privacy Policy")
                }
            }
            .fullScreenCover(isPresented: $showTermsOfUse) {
                if let url = URL(string: "https://www.flowhaventech.com/terms-of-use.html") {
                    WebViewScreen(url: url, title: "Terms of Use")
                }
            }
            .onAppear {
                // 应用保存的屏幕常亮设置
                UIApplication.shared.isIdleTimerDisabled = keepScreenOn
            }
            .onChange(of: keepScreenOn) { newValue in
                // 当开关变化时，更新屏幕常亮状态并保存设置
                UIApplication.shared.isIdleTimerDisabled = newValue
                UserDefaults.standard.set(newValue, forKey: "keepScreenOn")
            }
            .onChange(of: endOfFocusSounds) { newValue in
                // 保存声音设置
                UserDefaults.standard.set(newValue, forKey: "endOfFocusSounds")
            }
            .onChange(of: endOfFocusHaptics) { newValue in
                // 保存震动设置
                UserDefaults.standard.set(newValue, forKey: "endOfFocusHaptics")
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
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

struct ClearCacheAlertView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let modalWidth = geometry.size.width * 0.811
            let modalHeight = geometry.size.height * 0.686
            
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Free up space by removing temporary files.")
                            .font(.appBody(size: 20))
                            .foregroundColor(AppColors.Brand.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Your progress and data are safe.")
                            .font(.appBody(size: 20))
                            .foregroundColor(AppColors.Brand.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 30)

                    Spacer()

                    HStack(spacing: 0) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cancel")
                                .font(.appButton(size: 24))
                                .foregroundColor(AppColors.Text.inverse)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(AppColors.Semantic.darkBrown)
                        }
                        
                        Button(action: {
                            onConfirm()
                            isPresented = false
                        }) {
                            Text("Confirm")
                                .font(.appButton(size: 24))
                                .foregroundColor(AppColors.Text.inverse)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(AppColors.Brand.primary)
                        }
                    }
                }
                .frame(width: modalWidth, height: modalHeight)
                .background(AppColors.Semantic.beige)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(AppColors.Semantic.darkBrown, lineWidth: 3)
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserManager.shared)
}
