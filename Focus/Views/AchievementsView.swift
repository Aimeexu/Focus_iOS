//
//  AchievementsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI
import SwiftyJSON

struct AchievementsView: View {
    @StateObject private var userManager = UserManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedTab: AchievementTab = .friends
    @State private var showShareView = false
    @State private var selectedAchievement: Achievement?
    @State private var canExchange: Bool = false
    @State private var showNewpopView = false

    enum AchievementTab: String, CaseIterable {
        case friends = "Friends"
        case posting = "Posting"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            userInfoHeader
            contentView
        }
        .background(AppColors.Background.primary)
        .overlay(shareOverlay)
        .onAppear {
            loadAchievementsFromUserData()
            Task {
                    do {
                        let response = try await NetworkManager.shared.checkPosterExchangeWithJSON()
                        print("🎫 海报兑换资格检查API请求返回 \(response.data.canExchange)")
                        self.canExchange = response.data.canExchange
                    } catch {
                        print("❌ 检查海报兑换资格失败: \(error)")
                    }
            }
        }
        .onChange(of: userManager.currentUser) { _ in
            loadAchievementsFromUserData()
        }
    }
    
    // MARK: - 子视图
    
    private var userInfoHeader: some View {
        VStack(spacing: 16) {
            userProfileSection
            tabSwitcher
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    private var userProfileSection: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppColors.Background.secondary)
                .frame(width: 60, height: 60)
                .overlay(
                    Image("penguin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(getUserDisplayName())
                    .font(.appLargeTitle(size: 24))
                    .foregroundColor(AppColors.Text.primary)
                
                Text(getUserLevel())
                    .font(.appBody(size: 16))
                    .foregroundColor(AppColors.Text.secondary)
            }
            
            Spacer()
        }
    }
    
    private var tabSwitcher: some View {
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
                        .cornerRadius(selectedTab == tab ? 12 : 0)
                }
            }
        }
        .background(AppColors.Background.secondary)
        .cornerRadius(12)
    }
    
    private var contentView: some View {
        Group {
            if selectedTab == .friends {
                achievementsContent
            } else {
                PostingView()
            }
        }
    }
    
    private var achievementsContent: some View {
        Group {
            if achievementManager.isLoading {
                loadingView
            } else {
                achievementsList
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("加载成就数据...")
                .font(.appBody())
                .foregroundColor(AppColors.Text.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var achievementsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 30) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    AchievementSection(
                        category: category,
                        canExchange: canExchange,
                        achievements: achievementManager.achievements.filter { $0.category == category && $0.tab == .friends},
                        onAchievementTap: handleAchievementTap,
                        onNewTap: handleNewTap
                    )
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 120)
        }
    }
    
    private var shareOverlay: some View {
        Group {
            if showShareView, let achievement = selectedAchievement {
                ShareAchievementView(
                    achievement: achievement,
                    isPresented: $showShareView
                )
            } else if showNewpopView {
                NewTagPopupView(isPresented: $showNewpopView)
            }
        }
    }
    
    private func handleAchievementTap(_ achievement: Achievement) {
        if achievement.isUnlocked {
            selectedAchievement = achievement
            showShareView = true
        }
    }

    private func handleNewTap() {
        showNewpopView = true
    }

    // MARK: - 辅助方法
    
    /// 获取用户显示名称
    private func getUserDisplayName() -> String {
        if let user = userManager.currentUser {
            return user.nickname.isEmpty ? user.account : user.nickname
        }
        return "Guest"
    }
    
    /// 获取用户等级
    private func getUserLevel() -> String {
        guard let user = userManager.currentUser else {
            return "New Bee"
        }
        
        // 根据用户拥有的物品数量计算等级
        let totalStuffs = user.userStuffs.count
        
        switch totalStuffs {
        case 0...2:
            return "New Bee"
        case 3...5:
            return "Focus Starter"
        case 6...10:
            return "Concentration Master"
        case 11...20:
            return "Zen Master"
        default:
            return "Focus Legend"
        }
    }
    
    /// 从用户数据加载成就
    private func loadAchievementsFromUserData() {
        // 使用 AchievementManager 来处理成就生成
        achievementManager.generateAchievementsFromCurrentUser()
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
    let isRemoteImage: Bool // 新增字段，标识是否为远程图片
    let tab : AchievementTab

    init(id: Int, title: String, description: String, image: String, isUnlocked: Bool, category: AchievementCategory, badgeNumber: Int?, isRemoteImage: Bool = false, tab: AchievementTab) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.isUnlocked = isUnlocked
        self.category = category
        self.badgeNumber = badgeNumber
        self.isRemoteImage = isRemoteImage
        self.tab = tab
    }
}

enum AchievementTab: String, CaseIterable {
    case friends = "Friends"
    case posting = "Posting"
}

enum AchievementCategory: String, CaseIterable {
    case calmFields = "CalmFields"
    case iceSands = "IceSands"
    case tropicalWilds = "TropicalWilds"

    var sideLabel: String {
        return self.rawValue
    }
    
    var sideLabelColor: Color {
        switch self {
        case .calmFields:
            return AppColors.Brand.primary
        case .iceSands:
            return AppColors.Semantic.oliveGreen
        case .tropicalWilds:
            return Color.orange
        }
    }
}

struct AchievementSection: View {
    let category: AchievementCategory
    let canExchange: Bool
    let achievements: [Achievement]
    let onAchievementTap: (Achievement) -> Void
    let onNewTap:() -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 左侧分类标题
            ZStack {
                // 背景和旋转文字
                ZStack {
                    category.sideLabelColor
                        .cornerRadius(12)

                    Text(category.sideLabel)
                        .font(.appButton(size: 16))
                        .foregroundColor(AppColors.Text.inverse)
                        .rotationEffect(.degrees(90))
                        .fixedSize()
                }
                .frame(minWidth: 46, maxWidth: 46, minHeight: 100, maxHeight: 120)
                .clipped()
                .cornerRadius(12)

                // NEW 标签 - 绝对定位在右上角
                if category == .calmFields && canExchange {
                    Text("new!")
                        .font(.appBody(size: 12))
                        .foregroundColor(AppColors.Text.inverse)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 2)
                        .background(AppColors.Semantic.error)
                        .cornerRadius(10)
                        .frame(height: 20)
                        .position(x: 46 - 10, y: 20) // x: 背景宽度减偏移, y: 顶部偏移
                        .onTapGesture {
                            onNewTap()
                        }
                }
            }
            .frame(width: 46)

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
                            if achievement.isRemoteImage {
                                // 显示远程图片
                                AsyncImage(url: URL(string: achievement.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 96, height: 100)
                                }
                                .frame(width: 96, height: 100)
                                .offset(x: 16, y: 24)
                            } else {
                                // 显示本地图片
                                Image(achievement.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 96, height: 100)
                                    .offset(x: 16, y: 24)
                            }
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
