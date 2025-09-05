//
//  MyPostersView.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI

/// 我的海报视图
struct MyPostersView: View {
    @StateObject private var posterManager = PosterManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: PosterCategory? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分类选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            title: "全部",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(PosterCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.sideLabel,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                
                // 海报列表
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if filteredPosters.isEmpty {
                            EmptyPostersView(selectedCategory: selectedCategory)
                        } else {
                            // 统计信息
                            PosterStatsCard()
                            
                            // 海报网格
                            PosterGridSection(posters: filteredPosters)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("我的海报")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("刷新") {
                        // 先生成成就系统的测试数据
                        achievementManager.testParseLoginData()
                        // 然后生成海报
                        posterManager.generatePostersFromCurrentUser()
                    }
                }
            }
            .onAppear {
                // 如果没有数据，尝试生成测试数据
                if posterManager.posters.isEmpty {
                    achievementManager.testParseLoginData()
                    posterManager.generatePostersFromCurrentUser()
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var filteredPosters: [Poster] {
        let allPosters = posterManager.posters
        
        if let category = selectedCategory {
            return allPosters.filter { $0.category == category }
        } else {
            return allPosters
        }
    }
}

/// 分类筛选按钮
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 海报统计卡片
struct PosterStatsCard: View {
    @StateObject private var posterManager = PosterManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        let stats = achievementManager.userStatsInfo
        let unlockedPosters = posterManager.posters.filter { $0.isUnlocked }.count
        let totalPosters = posterManager.posters.count
        
        HStack(spacing: 20) {
//            StatItem(title: "已解锁", count: unlockedPosters, icon: "checkmark.circle.fill", color: .green)
//            StatItem(title: "总数", count: totalPosters, icon: "photo.fill", color: .blue)
//            StatItem(title: "场景", count: stats.totalScenes, icon: "location.fill", color: .orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

/// 海报网格部分
struct PosterGridSection: View {
    let posters: [Poster]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(posters, id: \.id) { poster in
                SimplePosterCard(poster: poster)
            }
        }
    }
}

/// 简化的海报卡片
struct SimplePosterCard: View {
    let poster: Poster
    
    var body: some View {
        VStack(spacing: 8) {
            // 海报图片
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(poster.isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(height: 120)
                
                if poster.isUnlocked {
                    if poster.image.hasPrefix("http") {
                        AsyncImage(url: URL(string: poster.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        }
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(poster.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } else {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                // 徽章数字
                if let badgeNumber = poster.badgeNumber {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.red)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("\(badgeNumber)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                                .offset(x: -8, y: 8)
                        }
                        Spacer()
                    }
                }
            }
            
            // 海报信息
            VStack(spacing: 4) {
                Text(poster.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(poster.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // 分类标签
                Text(poster.category.sideLabel)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(poster.category.sideLabelColor.opacity(0.2))
                    .foregroundColor(poster.category.sideLabelColor)
                    .clipShape(Capsule())
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// 空状态视图
struct EmptyPostersView: View {
    let selectedCategory: PosterCategory?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(selectedCategory == nil ? "还没有海报" : "该分类暂无海报")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("完成专注任务来获得精美的海报吧！")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("生成测试数据") {
                AchievementManager.shared.testParseLoginData()
                PosterManager.shared.generatePostersFromCurrentUser()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPostersView()
}
