//
//  PostingView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/15.
//

import SwiftUI

struct PostingView: View {
    // 发布数据
    let posts = [
        Post(id: 1, title: "Morning Focus", description: "Completed 2 hours of deep work", image: "owl", category: .morningFocus, badgeNumber: 3),
        Post(id: 2, title: "Study Session", description: "Finished reading chapter 5", image: "hedgehog", category: .morningFocus, badgeNumber: 8),
        Post(id: 3, title: "Evening Meditation", description: "30 minutes of mindfulness", image: "question", category: .eveningCalm, badgeNumber: nil),
        Post(id: 4, title: "Night Reading", description: "Read before sleep", image: "question", category: .eveningCalm, badgeNumber: nil),
        Post(id: 5, title: "Weekend Project", description: "Worked on personal project", image: "question", category: .weekendVibes, badgeNumber: nil),
        Post(id: 6, title: "Creative Time", description: "Drawing and sketching", image: "question", category: .weekendVibes, badgeNumber: nil)
    ]
    
    var body: some View {
        // 发布分类列表
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 30) {
                ForEach(PostCategory.allCases, id: \.self) { category in
                    PostSection(category: category, posts: posts.filter { $0.category == category })
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 120) // 为TabBar留出空间
        }
    }
}

struct Post: Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String
    let category: PostCategory
    let badgeNumber: Int?
}

enum PostCategory: CaseIterable {
    case morningFocus
    case eveningCalm
    case weekendVibes
    
    var sideLabel: String {
        switch self {
        case .morningFocus:
            return "Morning Focus"
        case .eveningCalm:
            return "Evening Calm"
        case .weekendVibes:
            return "Weekend Vibes"
        }
    }
    
    var sideLabelColor: Color {
        switch self {
        case .morningFocus:
            return AppColors.Brand.primary
        case .eveningCalm:
            return AppColors.Semantic.oliveGreen
        case .weekendVibes:
            return AppColors.Semantic.beige
        }
    }
}

struct PostSection: View {
    let category: PostCategory
    let posts: [Post]
    
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
            
            // 右侧可滚动的发布卡片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(posts) { post in
                        PostCard(post: post)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PostCard: View {
    let post: Post
    
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
                        if post.image != "question" {
                            // 有内容的发布显示图片
                            Image(post.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 96, height: 100)
                                .offset(x: 16, y: 24)
                        } else {
                        
                        }
                    }
                )
            
            // 徽章数字（左上角）
            if let badgeNumber = post.badgeNumber {
                VStack {
                    HStack {
                        Circle()
                            .fill(AppColors.Semantic.error)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("\(badgeNumber)")
                                    .font(.appNumber(size: 14))
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
