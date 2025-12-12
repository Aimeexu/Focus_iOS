//
//  PostingView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI

struct PostingView: View {
    @StateObject private var posterManager = AchievementManager.shared
    @StateObject private var userManager = UserManager.shared

    @State private var showShareView = false
    @State private var selectedAchievement: Achievement?

    var body: some View {
        Group {
            if posterManager.isLoading {
                loadingView
            } else {
                postersList
            }
        }
        .overlay(shareOverlay)
        .onAppear {
            loadPostersFromUserData()
        }
        .onChange(of: userManager.currentUser) { _ in
            loadPostersFromUserData()
        }
    }
    
    // MARK: - 子视图
    
    private var loadingView: some View {
        VStack {
            ProgressView("加载海报数据...")
                .font(.appBody())
                .foregroundColor(AppColors.Text.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var postersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 30) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    PosterSection(
                        category: category,
                        achievements: posterManager.achievements.filter { $0.category == category && $0.tab == .posting },
                        onAchievementTap: handleAchievementTap
                    )
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 120) // 为TabBar留出空间
        }
    }
    
    /// 从用户数据加载海报
    private func loadPostersFromUserData() {
        posterManager.generateAchievementsFromCurrentUser()
    }

    private func handleAchievementTap(_ achievement: Achievement) {
        if achievement.isUnlocked {
            selectedAchievement = achievement
            showShareView = true
        }
    }
    
    private var shareOverlay: some View {
        Group {
            if showShareView, let achievement = selectedAchievement {
                ShareAchievementView(
                    achievement: achievement,
                    isPresented: $showShareView
                )
            }
        }
    }
}

struct PosterSection: View {
    let category: AchievementCategory
    let achievements: [Achievement]
    let onAchievementTap: (Achievement) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 左侧分类标题
            VStack {
                ZStack {
                    category.sideLabelColor
                        .cornerRadius(12)

                    Text(category.sideLabel)
                        .font(.appButton(size: 16))
                        .foregroundColor(AppColors.Text.inverse)
                        .rotationEffect(.degrees(90))
                        .fixedSize() // 让文字按照内容显示，不被压缩
                        .offset(x: 0, y: 0) // 调整文字位置，可根据需要微调
                }
                .frame(minWidth: 46, maxWidth: 46, minHeight: 100, maxHeight: 120)// 背景固定大小
                .clipped() // 超出的部分裁剪掉
                .cornerRadius(12)
            }
            .frame(width: 30)

            // 右侧可滚动的成就卡片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(achievements) { achievement in
                        PosterCard(
                            achievement: achievement,
                            onTap: {
                                onAchievementTap(achievement)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PosterCard: View {
    let achievement: Achievement
    let onTap: () -> Void

    var body: some View {
        ZStack {
            // 主卡片 - 使用背景图片
            // 主卡片
            if achievement.isRemoteImage, achievement.isUnlocked {
                AsyncImage(url: URL(string: achievement.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                        .frame(width: 146, height: 160)
                }
                .frame(width: 146, height: 160)
                .clipped()
                .cornerRadius(16)
                .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 250/255, green: 242/255, blue: 232/255), lineWidth: 1)
                    )
            } else {
                Image(achievement.isUnlocked ? achievement.image : "posting_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 146, height: 160)
                    .clipped()
                    .cornerRadius(16)
            }

//            // 徽章数字（左上角）
//            if let badgeNumber = achievement.badgeNumber {
//                VStack {
//                    HStack {
//                        Circle()
//                            .fill(AppColors.Brand.primary)
//                            .frame(width: 28, height: 28)
//                            .overlay(
//                                Text("\(badgeNumber)")
//                                    .font(.appButton(size: 14))
//                                    .foregroundColor(AppColors.Text.inverse)
//                            )
//                            .offset(x: 22, y: 14)
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    PostingView()
}
