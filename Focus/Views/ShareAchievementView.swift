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
                AsyncImage(url: URL(string: achievement.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 220)
                } placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 220)
                }
            } else {
                Image(achievement.image)
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
            
            HStack(spacing: 16) {
                // Facebook 分享按钮
                ShareAchievementButton(
                    icon: "facebook_logo",
                    title: "Facebook",
                    color: Color(red: 24/255, green: 119/255, blue: 242/255),
                    isLoading: isSharing
                ) {
                    shareToFacebook()
                }
                
                // Instagram 分享按钮
                ShareAchievementButton(
                    icon: "instagram_logo",
                    title: "Instagram",
                    color: Color(red: 193/255, green: 53/255, blue: 132/255),
                    isLoading: isSharing
                ) {
                    shareToInstagram()
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
    
    // MARK: - 分享到 Facebook（使用 Facebook SDK）
    private func shareToFacebook() {
        guard !isSharing else { return }
        isSharing = true
        
        // 获取当前视图控制器
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            // 如果无法获取视图控制器，回退到系统分享
            let shareText = "🎉 我在 Focus 应用中获得了成就：\(achievement.title)！\n\n\(achievement.description)"
            shareWithSystemSheet(text: shareText)
            return
        }
        
        // 先尝试加载图片
        loadImageForFacebookShare { image in
            if let image = image {
                // 使用 SharePhotoContent 分享图片
                let photo = SharePhoto(image: UIImage(), isUserGenerated: true)
                photo.image = image
                photo.isUserGenerated = true
                let content = SharePhotoContent()
                content.photos = [photo]
                
                let dialog = ShareDialog(
                    viewController: viewController,
                    content: content,
                    delegate: nil
                )
                
                dialog.mode = .automatic // 自动选择最佳模式
                
                do {
                    try dialog.validate()
                    dialog.show()
                    print("✅ Facebook 图片分享对话框已显示")
                } catch {
                    print("❌ Facebook 分享验证失败: \(error)")
                    // 回退到系统分享
                    let shareText = "🎉 我在 Focus 应用中获得了成就：\(self.achievement.title)！\n\n\(self.achievement.description)"
                    self.shareWithSystemSheet(text: shareText)
                }
            } else {
                // 如果没有图片，使用链接分享
                let content = ShareLinkContent()
                content.contentURL = URL(string: "https://www.focusapp.com")! // 替换为你的应用链接
                content.quote = "🎉 我在 Focus 应用中获得了成就：\(self.achievement.title)！\n\n\(self.achievement.description)"
                
                let dialog = ShareDialog(
                    viewController: viewController,
                    content: content,
                    delegate: nil
                )
                
                dialog.mode = .automatic
                
                do {
                    try dialog.validate()
                    dialog.show()
                    print("✅ Facebook 链接分享对话框已显示")
                } catch {
                    print("❌ Facebook 分享验证失败: \(error)")
                    // 回退到系统分享
                    let shareText = "🎉 我在 Focus 应用中获得了成就：\(self.achievement.title)！\n\n\(self.achievement.description)"
                    self.shareWithSystemSheet(text: shareText)
                }
            }
            
            self.isSharing = false
            
            // 延迟关闭分享视图
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isPresented = false
            }
        }
    }
    
    // MARK: - 加载图片用于 Facebook 分享
    private func loadImageForFacebookShare(completion: @escaping (UIImage?) -> Void) {
        if achievement.isRemoteImage, let imageURL = URL(string: achievement.image) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                    if let image = UIImage(data: data) {
                        // 在图片上添加文字
                        let composedImage = composeImageWithText(image: image)
                        await MainActor.run {
                            completion(composedImage)
                        }
                    } else {
                        await MainActor.run {
                            completion(nil)
                        }
                    }
                } catch {
                    print("❌ 下载图片失败: \(error)")
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        } else if !achievement.isRemoteImage {
            // 本地图片 TODO
            if let image = UIImage(named: achievement.image) {
                let composedImage = composeImageWithText(image: image)
                completion(composedImage)
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    // MARK: - 在图片上合成文字
    private func composeImageWithText(image: UIImage) -> UIImage? {
        // 使用后台返回的文字，如果没有则使用默认文字
        let shareText = achievement.shareText ?? "We've been together\ncompleting 4 focus sessions\nGuess when I first met this little one?"
        
        return ImageTextComposer.composeImage(
            image: image,
            text: shareText,
            textColor: .white,
            fontSize: 8, // 自动根据图片大小计算
            position: .bottom,
            backgroundColor: UIColor.black.withAlphaComponent(0),
            padding: 20
        )
    }
    
    // MARK: - 使用系统分享面板
    private func shareWithSystemSheet(text: String) {
        var itemsToShare: [Any] = [text]
        
        // 如果有远程图片，先下载图片
        if achievement.isRemoteImage, let imageURL = URL(string: achievement.image) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            itemsToShare.append(image)
                            presentShareSheet(items: itemsToShare)
                        }
                    } else {
                        await MainActor.run {
                            presentShareSheet(items: itemsToShare)
                        }
                    }
                } catch {
                    print("❌ 下载图片失败: \(error)")
                    await MainActor.run {
                        presentShareSheet(items: itemsToShare)
                    }
                }
            }
        } else if !achievement.isRemoteImage {
            // 本地图片
            if let image = UIImage(named: achievement.image) {
                itemsToShare.append(image)
            }
            presentShareSheet(items: itemsToShare)
        } else {
            presentShareSheet(items: itemsToShare)
        }
    }
    
    // MARK: - 分享到 Instagram
    private func shareToInstagram() {
        guard !isSharing else { return }
        isSharing = true
        
        // 先加载图片
        loadImageForFacebookShare { image in
            guard let image = image else {
                // 如果没有图片，回退到系统分享
                let shareText = "🎉 我在 Focus 应用中获得了成就：\(self.achievement.title)！\n\n\(self.achievement.description)"
                self.shareWithSystemSheet(text: shareText)
                self.isSharing = false
                return
            }
            
            // Instagram Stories 分享
            if self.shareToInstagramStories(image: image) {
                print("✅ Instagram Stories 分享成功")
            } else {
                // 如果 Instagram Stories 失败，尝试 Instagram Feed
                if self.shareToInstagramFeed(image: image) {
                    print("✅ Instagram Feed 分享成功")
                } else {
                    // 如果都失败，使用系统分享
                    print("⚠️ Instagram 未安装，使用系统分享")
                    let shareText = "🎉 我在 Focus 应用中获得了成就：\(self.achievement.title)！\n\n\(self.achievement.description)"
                    var items: [Any] = [shareText, image]
                    self.presentShareSheet(items: items)
                }
            }
            
            self.isSharing = false
            
            // 延迟关闭分享视图
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isPresented = false
            }
        }
    }
    
    // MARK: - 分享到 Instagram Stories
    private func shareToInstagramStories(image: UIImage) -> Bool {
        // 检查是否安装了 Instagram
        guard let instagramURL = URL(string: "instagram-stories://share"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            return false
        }
        
        // 准备分享数据
        guard let imageData = image.pngData() else {
            return false
        }
        
        // 创建粘贴板项目
        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.stickerImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#6A5446",
                "com.instagram.sharedSticker.backgroundBottomColor": "#F2E9DA"
            ]
        ]
        
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5) // 5分钟过期
        ]
        
        // 设置粘贴板
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        
        // 打开 Instagram
        UIApplication.shared.open(instagramURL, options: [:]) { success in
            if success {
                print("✅ 成功打开 Instagram Stories")
            }
        }
        
        return true
    }
    
    // MARK: - 分享到 Instagram Feed
    private func shareToInstagramFeed(image: UIImage) -> Bool {
        // 检查是否安装了 Instagram
        guard let instagramURL = URL(string: "instagram://app"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            return false
        }
        
        // 保存图片到临时目录
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            return false
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("share_image.igo")
        
        do {
            try imageData.write(to: imageURL)
            
            // 使用 Document Interaction Controller
            let documentController = UIDocumentInteractionController(url: imageURL)
            documentController.uti = "com.instagram.exclusivegram"
            documentController.annotation = [
                "InstagramCaption": "🎉 我在 Focus 应用中获得了成就：\(achievement.title)！\n\n\(achievement.description)"
            ]
            
            // 获取当前视图控制器
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let viewController = windowScene.windows.first?.rootViewController else {
                return false
            }
            
            // 显示分享菜单
            documentController.presentOpenInMenu(
                from: viewController.view.bounds,
                in: viewController.view,
                animated: true
            )
            
            return true
        } catch {
            print("❌ 保存图片失败: \(error)")
            return false
        }
    }
    
    // MARK: - 分享到其他平台（使用系统分享）
    private func shareToOthers() {
        guard !isSharing else { return }
        isSharing = true
        
        let shareText = "我在 Focus 应用中获得了成就：\(achievement.title)！\n\(achievement.description)"
        
        var itemsToShare: [Any] = [shareText]
        
        // 如果有远程图片，先下载图片
        if achievement.isRemoteImage, let imageURL = URL(string: achievement.image) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            itemsToShare.append(image)
                            presentShareSheet(items: itemsToShare)
                        }
                    } else {
                        await MainActor.run {
                            presentShareSheet(items: itemsToShare)
                        }
                    }
                } catch {
                    print("❌ 下载图片失败: \(error)")
                    await MainActor.run {
                        presentShareSheet(items: itemsToShare)
                    }
                }
                isSharing = false
            }
        } else if !achievement.isRemoteImage {
            // 本地图片
            if let image = UIImage(named: achievement.image) {
                itemsToShare.append(image)
            }
            presentShareSheet(items: itemsToShare)
            isSharing = false
        } else {
            presentShareSheet(items: itemsToShare)
            isSharing = false
        }
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
