//
//  ShareAchievementView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI
import Kingfisher

struct ShareAchievementView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { geometry in
            let modalWidth = geometry.size.width * 0.811
            let modalHeight = geometry.size.height * 0.686

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
                    Spacer()
                    VStack(spacing: 20) {
                        // 成就图片
                        KFImage(URL(string: achievement.image))
                            .placeholder {
                                ProgressView() // 占位视图（加载中）
                                    .frame(width: 160, height: 180)
                            }
                            .onFailureImage(UIImage(systemName: "xmark.octagon")) // 加载失败时的图
                            .resizable()
                            .frame(width: 160, height: 180)

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
                    .background(AppColors.Semantic.beige)

                    Spacer()

                    // 按钮区域
                    HStack(spacing: 0) {
                        // Quit按钮
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Quit")
                                .font(.appButton(size: 24))
                                .foregroundColor(AppColors.Text.inverse)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(AppColors.Semantic.darkBrown)
                        }

                        // Confirm按钮
                        Button(action: {
                            shareAchievement()
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
            badgeNumber: 6,
            tab: .friends
        ),
        isPresented: .constant(true)
    )
}
