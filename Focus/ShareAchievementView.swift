//
//  ShareAchievementView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI

struct ShareAchievementView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // 分享卡片
            VStack(spacing: 0) {
                // 分享图片区域
                VStack(spacing: 20) {
                    // 成就图片
                    Image(achievement.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    
                    // 成就标题
                    Text(achievement.title)
                        .font(.appLargeTitle(size: 24))
                        .foregroundColor(AppColors.Text.primary)
                    
                    // 成就描述
                    Text(achievement.description)
                        .font(.appBody(size: 16))
                        .foregroundColor(AppColors.Text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // 分享文案
                    Text("🎉 Achievement Unlocked! 🎉")
                        .font(.appButton(size: 18))
                        .foregroundColor(AppColors.Brand.primary)
                        .padding(.top, 10)
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                .background(AppColors.Background.card)
                
                // 按钮区域
                HStack(spacing: 0) {
                    // Quit按钮
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Quit")
                            .font(.appButton(size: 18))
                            .foregroundColor(AppColors.Text.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(AppColors.Background.secondary)
                    }
                    
                    // Confirm按钮
                    Button(action: {
                        shareAchievement()
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .font(.appButton(size: 18))
                            .foregroundColor(AppColors.Text.inverse)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(AppColors.Brand.primary)
                    }
                }
            }
            .frame(width: 300)
            .background(AppColors.Background.card)
            .cornerRadius(20)
            .shadow(color: AppColors.Neutral.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
    
    private func shareAchievement() {
        // 分享逻辑
        print("分享成就: \(achievement.title)")
        // 这里可以添加实际的分享功能，比如调用系统分享面板
    }
}

#Preview {
    ShareAchievementView(
        achievement: Achievement(
            id: 1,
            title: "Calm Fields",
            description: "Complete 10 focus sessions",
            image: "hedgehog",
            isUnlocked: true,
            category: .calmFields,
            badgeNumber: 6
        ),
        isPresented: .constant(true)
    )
}