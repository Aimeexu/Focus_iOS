//
//  PostingView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI

struct PostingView: View {
    @StateObject private var posterManager = PosterManager.shared
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        Group {
            if posterManager.isLoading {
                loadingView
            } else {
                postersList
            }
        }
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
                ForEach(PosterCategory.allCases, id: \.self) { category in
                    PosterSection(
                        category: category,
                        posters: posterManager.posters.filter { $0.category == category }
                    )
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 120) // 为TabBar留出空间
        }
    }
    
    /// 从用户数据加载海报
    private func loadPostersFromUserData() {
        posterManager.generatePostersFromCurrentUser()
    }
}

struct PosterSection: View {
    let category: PosterCategory
    let posters: [Poster]
    
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
            }
            .frame(width: 30)
            
            // 右侧可滚动的海报卡片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(posters) { poster in
                        PosterCard(poster: poster)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PosterCard: View {
    let poster: Poster
    
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
                        if poster.isUnlocked {
                            // 解锁的海报显示远程图片
                            if poster.image.hasPrefix("http") {
                                AsyncImage(url: URL(string: poster.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                }
                                .frame(width: 96, height: 100)
                                .offset(x: 16, y: 24)
                            } else {
                                // 本地图片
                                Image(poster.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 96, height: 100)
                                    .offset(x: 16, y: 24)
                            }
                        } else {
                            // 未解锁的海报显示问号
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                                .offset(x: 16, y: 24)
                        }
                    }
                )
            
            // 徽章数字（左上角）
            if let badgeNumber = poster.badgeNumber {
                VStack {
                    HStack {
                        Circle()
                            .fill(AppColors.Semantic.error)
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
    }
}

#Preview {
    PostingView()
}
