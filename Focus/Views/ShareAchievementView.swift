//
//  ShareAchievementView.swift
//  Focus
//
//  Created by Kiro on 2025/12/9.
//

import SwiftUI
import UIKit
import FBSDKShareKit
import FBSDKCoreKit

struct ShareAchievementView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    @State private var isSharing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var shareImage: UIImage?
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // 分享卡片
            VStack(spacing: 0) {
                // 成就展示区域
                achievementDisplaySection
                
                // 分享按钮区域
                shareButtonsSection
            }
            .background(AppColors.Background.primary)
            .cornerRadius(20)
            .padding(.horizontal, 40)
            .shadow(radius: 20)
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadShareImage()
        }
    }
    
    // MARK: - 成就展示区域
    private var achievementDisplaySection: some View {
        VStack(spacing: 16) {
            // 关闭按钮
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.Text.secondary)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            // 成就图片
            if achievement.isRemoteImage {
                AsyncImage(url: URL(string:achievement.shareImage ?? achievement.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 220)
                } placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 220)
                }
            } else {
                Image(achievement.shareImage ?? achievement.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 220)
            }
            
            // 成就标题
            Text(achievement.title)
                .font(.appLargeTitle(size: 24))
                .foregroundColor(AppColors.Text.primary)
                .multilineTextAlignment(.center)
            
            // 成就描述
            Text(achievement.description)
                .font(.appBody(size: 16))
                .foregroundColor(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // 徽章数量（如果有）
            if let badgeNumber = achievement.badgeNumber {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.Brand.primary)
                    Text("x \(badgeNumber)")
                        .font(.appNumber(size: 20))
                        .foregroundColor(AppColors.Text.primary)
                }
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - 分享按钮区域
    private var shareButtonsSection: some View {
        VStack(spacing: 16) {
            Text("分享你的成就")
                .font(.appButton(size: 18))
                .foregroundColor(AppColors.Text.primary)
            
            HStack(spacing: 20) {
                // Facebook 分享按钮
                ShareAchievementButton(
                    icon: "facebook_logo",
                    title: "Facebook",
                    color: Color(red: 24/255, green: 119/255, blue: 242/255),
                    isLoading: isSharing
                ) {
                    shareToFacebook()
                }
                
                // 更多分享选项
                ShareAchievementButton(
                    icon: "google_logo",
                    title: "More",
                    color: Color(red: 66/255, green: 133/255, blue: 244/255),
                    isLoading: isSharing
                ) {
                    shareToOthers()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 24)
        .background(AppColors.Background.secondary)
        .shareCornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
    
    // MARK: - 预加载分享图片
    private func loadShareImage() {
        if achievement.isRemoteImage, let imageURL = URL(string: achievement.shareImage ?? achievement.image) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            self.shareImage = image
                        }
                    }
                } catch {
                    print("❌ 预加载图片失败: \(error)")
                }
            }
        } else if !achievement.isRemoteImage {
            shareImage = UIImage(named: achievement.shareImage ?? achievement.image)
        }
    }
    
    // MARK: - 分享到 Facebook（使用 Facebook SDK）
    private func shareToFacebook() {
        guard !isSharing else { return }
        isSharing = true
        
        // 确保图片已加载
        guard let image = shareImage else {
            alertMessage = "图片加载中，请稍后再试"
            showAlert = true
            isSharing = false
            return
        }
        
        // 获取当前视图控制器
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "无法打开分享对话框"
            showAlert = true
            isSharing = false
            return
        }
        
        // 使用 Facebook SDK 分享图片
        let photo = SharePhoto(image: image, isUserGenerated: true)
        let content = SharePhotoContent()
        content.photos = [photo]
        
        let dialog = ShareDialog(viewController: viewController, content: content, delegate: nil)
        dialog.mode = .automatic
        
        // 验证并显示分享对话框
        do {
            try dialog.validate()
            dialog.show()
            print("✅ Facebook 分享对话框已显示")
            
            // 延迟关闭分享视图
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPresented = false
            }
        } catch {
            print("❌ Facebook 分享失败: \(error.localizedDescription)")
            // 回退到系统分享
            fallbackToSystemShare(image: image)
        }
        
        isSharing = false
    }
    
    // MARK: - 回退到系统分享
    private func fallbackToSystemShare(image: UIImage) {
        let shareText = getShareText()
        presentShareSheet(items: [shareText, image])
    }
    
    // MARK: - 获取分享文字
    private func getShareText() -> String {
        // 优先使用后台返回的 shareText
        if let shareText = achievement.shareText, !shareText.isEmpty {
            return shareText
        }
        // 否则使用默认格式
        return "🎉 我在 Focus 应用中获得了成就：\(achievement.title)！\n\n\(achievement.description)"
    }
    

    
    // MARK: - 分享到其他平台（使用系统分享）
    private func shareToOthers() {
        guard !isSharing else { return }
        isSharing = true
        
        let shareText = getShareText()
        
        // 使用预加载的图片
        if let image = shareImage {
            presentShareSheet(items: [shareText, image])
        } else {
            presentShareSheet(items: [shareText])
        }
        
        isSharing = false
    }
    
    // MARK: - 显示系统分享面板
    private func presentShareSheet(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "无法打开分享面板"
            showAlert = true
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(activityViewController, animated: true) {
            // 分享面板显示后关闭当前视图
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPresented = false
            }
        }
    }
}

// MARK: - 分享按钮组件
private struct ShareAchievementButton: View {
    let icon: String
    let title: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 60, height: 60)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                }
                
                Text(title)
                    .font(.appBody(size: 14))
                    .foregroundColor(AppColors.Text.primary)
            }
        }
        .disabled(isLoading)
    }
}

// MARK: - 圆角扩展
private extension View {
    func shareCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(ShareRoundedCorner(radius: radius, corners: corners))
    }
}

private struct ShareRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ShareAchievementView(
        achievement: Achievement(
            id: 1,
            title: "专注大师",
            description: "连续专注30天",
            image: "hedgehog",
            isUnlocked: true,
            category: .calmFields,
            badgeNumber: 5,
            isRemoteImage: false,
            tab: .friends
        ),
        isPresented: .constant(true)
    )
}
