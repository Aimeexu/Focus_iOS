//
//  AchievementsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI

struct AchievementsView: View {
    @State private var selectedTab: AchievementTab = .friends
    @State private var showShareView = false
    @State private var selectedAchievement: Achievement?
    
    enum AchievementTab: String, CaseIterable {
        case friends = "Friends"
        case posting = "Posting"
    }
    
    // 成就数据
    let achievements = [
        Achievement(id: 1, title: "Calm Fields", description: "Complete 10 focus sessions", image: "hedgehog", isUnlocked: true, category: .calmFields, badgeNumber: 6),
        Achievement(id: 2, title: "Owl Master", description: "Focus for 100 hours", image: "owl", isUnlocked: true, category: .calmFields, badgeNumber: 1),
        Achievement(id: 3, title: "Ice Spirits", description: "Focus in winter", image: "question", isUnlocked: false, category: .iceSpirits, badgeNumber: nil),
        Achievement(id: 4, title: "Ice Spirits", description: "Focus in winter", image: "question", isUnlocked: false, category: .iceSpirits, badgeNumber: nil),
        Achievement(id: 5, title: "Ice Spirits", description: "Focus in winter", image: "question", isUnlocked: false, category: .iceSpirits, badgeNumber: nil),
        Achievement(id: 6, title: "Ice Master", description: "Complete ice challenge", image: "question", isUnlocked: false, category: .iceSpirits, badgeNumber: nil),
        Achievement(id: 7, title: "Vibes", description: "Focus in summer", image: "question", isUnlocked: false, category: .tropicalVibes, badgeNumber: nil),
        Achievement(id: 8, title: "Master", description: "Complete tropical challenge", image: "question", isUnlocked: false, category: .tropicalVibes, badgeNumber: nil),
        Achievement(id: 9, title: "Master", description: "Complete tropical challenge", image: "question", isUnlocked: false, category: .Vibes, badgeNumber: nil),
        Achievement(id: 10, title: "Master", description: "Complete tropical challenge", image: "question", isUnlocked: false, category: .Vibes, badgeNumber: nil),
        Achievement(id: 11, title: "Master", description: "Complete tropical challenge", image: "question", isUnlocked: false, category: .Vibes, badgeNumber: nil),
        Achievement(id: 12, title: "Master", description: "Complete tropical challenge", image: "question", isUnlocked: false, category: .bees, badgeNumber: nil),
        Achievement(id: 13, title: "Master", description: "Complete tropical challenge", image: "question", isUnlocked: false, category: .bees, badgeNumber: nil)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部用户信息
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // 用户头像
                    Circle()
                        .fill(AppColors.Background.secondary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image("penguin") // 企鹅头像
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jessica")
                            .font(.appLargeTitle(size: 24))
                            .foregroundColor(AppColors.Text.primary)
                        
                        Text("New Bee")
                            .font(.appBody(size: 16))
                            .foregroundColor(AppColors.Text.secondary)
                    }
                    
                    Spacer()
                }
                
                // Tab切换按钮
                HStack(spacing: 0) {
                    ForEach(AchievementTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.appButton(size: 16))
                                .foregroundColor(selectedTab == tab ? AppColors.Text.inverse : AppColors.Text.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(selectedTab == tab ? AppColors.Brand.primary : AppColors.Background.secondary)
                                .cornerRadius(selectedTab == tab ? 22 : 0)
                        }
                    }
                }
                .background(AppColors.Background.secondary)
                .cornerRadius(22)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            // 根据选中的标签显示不同内容
            if selectedTab == .friends {
                // Friends标签页 - 显示成就
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            AchievementSection(
                                category: category, 
                                achievements: achievements.filter { $0.category == category },
                                onAchievementTap: { achievement in
                                    if achievement.isUnlocked {
                                        selectedAchievement = achievement
                                        showShareView = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 120) // 为TabBar留出空间
                }
            } else {
                // Posting标签页 - 显示发布内容
                PostingView()
            }
        }
        .background(AppColors.Background.primary)
        .overlay(
            // 分享弹窗
            Group {
                if showShareView, let achievement = selectedAchievement {
                    ShareAchievementView(
                        achievement: achievement,
                        isPresented: $showShareView
                    )
                }
            }
        )
    }
}

struct Achievement: Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String
    let isUnlocked: Bool
    let category: AchievementCategory
    let badgeNumber: Int?
}

enum AchievementCategory: CaseIterable {
    case calmFields
    case iceSpirits  
    case tropicalVibes
    case Vibes
    case bees

    var sideLabel: String {
        switch self {
        case .calmFields:
            return "Calm Fields"
        case .iceSpirits:
            return "Ice Spirits"
        case .tropicalVibes:
            return "Tropical Vibes"
        case .Vibes:
            return "Tropical Vibes"
        case .bees:
            return "Tropical Vibes"
        }
    }
    
    var sideLabelColor: Color {
        switch self {
        case .calmFields:
            return AppColors.Brand.primary
        case .iceSpirits:
            return AppColors.Semantic.oliveGreen
        case .tropicalVibes:
            return AppColors.Semantic.oliveGreen
        case .Vibes:
            return AppColors.Semantic.oliveGreen
        case .bees:
            return AppColors.Semantic.oliveGreen
        }
    }
}

struct AchievementSection: View {
    let category: AchievementCategory
    let achievements: [Achievement]
    let onAchievementTap: (Achievement) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 左侧分类标题
            VStack {
                Text(category.sideLabel)
                    .font(.appButton(size: 16))
                    .foregroundColor(AppColors.Text.inverse)
                    .rotationEffect(.degrees(90))
                    .frame(width: 46, height: 100)
                    .background(category.sideLabelColor)
                    .cornerRadius(12)
                    .padding(4)

//                // 如果是第一个分类，显示new标签
//                if category == .calmFields {
//                    Text("new!")
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(AppColors.Text.inverse)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(AppColors.Semantic.error)
//                        .cornerRadius(8)
//                        .rotationEffect(.degrees(-15))
//                        .offset(y: -10)
//                }
            }
            .frame(width: 30)
            
            // 右侧可滚动的成就卡片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(achievements) { achievement in
                        AchievementCard(
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

struct AchievementCard: View {
    let achievement: Achievement
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // 主卡片 - 使用背景图片
            Image("achieve_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 146, height: 160)
                .clipped()
                .cornerRadius(16)
                .overlay(
                    VStack {
                        if achievement.isUnlocked {
                            // 解锁的成就显示图片
                            Image(achievement.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 96, height: 100)
                                .offset(x: 16, y: 24)
                        } else {
                        }
                    }
                )
            
            // 徽章数字（左上角）
            if let badgeNumber = achievement.badgeNumber {
                VStack {
                    HStack {
                        Circle()
                            .fill(AppColors.Brand.primary)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("\(badgeNumber)")
                                    .font(.appButton(size: 14))
                                    .foregroundColor(AppColors.Text.inverse)
                            )
                            .offset(x: 22, y: 14)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    AchievementsView()
}
