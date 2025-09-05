//
//  PosterManager.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import Foundation
import SwiftUI

// MARK: - 海报管理器
class PosterManager: ObservableObject {
    static let shared = PosterManager()
    
    @Published var posters: [Poster] = []
    @Published var isLoading = false
    
    private init() {}
    
    /// 解析登录响应数据并生成海报
    func parseLoginDataAndGeneratePosters(_ loginJsonString: String) {
        isLoading = true
        
        guard let data = loginJsonString.data(using: .utf8) else {
            print("❌ 无法将登录数据转换为Data")
            generateDefaultPosters()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let loginResponse = try decoder.decode(AchievementLoginResponse.self, from: data)
            
            if loginResponse.status == "success", let loginData = loginResponse.data {
                print("✅ 成功解析登录数据中的海报信息")
                generatePostersFromLoginData(loginData.user)
            } else {
                print("❌ 登录状态不成功: \(loginResponse.status)")
                generateDefaultPosters()
            }
        } catch {
            print("❌ 解析登录数据失败: \(error)")
            generateDefaultPosters()
        }
        
        isLoading = false
    }
    
    /// 从用户管理器的当前用户生成海报
    func generatePostersFromCurrentUser() {
        isLoading = true
        
        // 优先使用 AchievementManager 中的数据
        if let userData = AchievementManager.shared.currentUserData {
            generatePostersFromLoginData(userData)
        } else if let user = UserManager.shared.currentUser {
            generatePostersFromUserInfo(user)
        } else {
            generateDefaultPosters()
        }
        
        isLoading = false
    }
    
    /// 从登录数据的用户信息生成海报
    private func generatePostersFromLoginData(_ user: AchievementUser) {
        // 直接使用 AchievementManager 的方法生成海报
        let generatedPosters = AchievementManager.shared.generatePostersForPosterManager()
        
        // 添加未解锁的海报占位符
        var allPosters = generatedPosters
        allPosters.append(contentsOf: generatePlaceholderPosters(startingId: generatedPosters.count + 1))
        
        DispatchQueue.main.async {
            self.posters = allPosters
        }
        
        print("✅ 从登录数据生成了 \(allPosters.count) 个海报")
    }
    
    /// 从 UserInfo 生成海报（兼容现有的用户管理器）
    private func generatePostersFromUserInfo(_ user: UserInfo) {
        var generatedPosters: [Poster] = []
        var posterId = 1
        
        // 根据用户物品生成海报（简化版本）
        for userStuff in user.userStuffs {
            let poster = Poster(
                id: posterId,
                title: "海报收集",
                description: "收集了物品",
                image: "poster", // 默认图标
                isUnlocked: true,
                category: .calmFields, // 默认分类
                badgeNumber: userStuff.amount
            )
            generatedPosters.append(poster)
            posterId += 1
        }
        
        // 添加未解锁的海报占位符
        generatedPosters.append(contentsOf: generatePlaceholderPosters(startingId: posterId))
        
        DispatchQueue.main.async {
            self.posters = generatedPosters
        }
        
        print("✅ 从用户信息生成了 \(generatedPosters.count) 个海报")
    }
    
    /// 生成默认海报
    private func generateDefaultPosters() {
        let defaultPosters = [
            Poster(id: 1, title: "第一张海报", description: "完成第一次专注获得", image: "poster", isUnlocked: false, category: .calmFields, badgeNumber: nil),
            Poster(id: 2, title: "专注海报", description: "专注10次获得", image: "poster", isUnlocked: false, category: .calmFields, badgeNumber: nil),
            Poster(id: 3, title: "冰雪海报", description: "在冰雪场景中专注", image: "question", isUnlocked: false, category: .iceSands, badgeNumber: nil),
            Poster(id: 4, title: "冰雪收藏", description: "收集冰雪主题海报", image: "question", isUnlocked: false, category: .iceSands, badgeNumber: nil),
            Poster(id: 5, title: "热带海报", description: "在热带场景中专注", image: "question", isUnlocked: false, category: .tropicalWilds, badgeNumber: nil),
            Poster(id: 6, title: "热带收藏", description: "收集热带主题海报", image: "question", isUnlocked: false, category: .tropicalWilds, badgeNumber: nil)
        ]
        
        DispatchQueue.main.async {
            self.posters = defaultPosters
        }
        
        print("✅ 生成了默认海报")
    }
    
    /// 生成占位符海报
    private func generatePlaceholderPosters(startingId: Int) -> [Poster] {
        var placeholders: [Poster] = []
        var id = startingId
        
        // 为每个分类添加一些未解锁的海报
        let categories: [(PosterCategory, String)] = [
            (.calmFields, "CalmFields"),
            (.iceSands, "IceSands"),
            (.tropicalWilds, "TropicalWilds")
        ]
        
        for (category, name) in categories {
            // 只为没有海报的分类添加占位符
            let existingPosters = posters.filter { $0.category == category && $0.isUnlocked }
            if existingPosters.isEmpty {
                for i in 1...2 {
                    let poster = Poster(
                        id: id,
                        title: "未解锁海报 \(i)",
                        description: "在 \(name) 场景中获得更多物品来解锁",
                        image: "question",
                        isUnlocked: false,
                        category: category,
                        badgeNumber: nil
                    )
                    placeholders.append(poster)
                    id += 1
                }
            }
        }
        
        return placeholders
    }
    

    
    /// 测试解析登录数据的方法
    func testParsePosterData() {
        print("🧪 开始测试解析海报数据...")
        
        let testLoginJson = """
        {
            "status": "success",
            "data": {
                "accessTokenName": "focus-pals-token",
                "refreshToken": "test-refresh-token",
                "accessToken": "test-access-token",
                "user": {
                    "account": "TEST-USER",
                    "phone": null,
                    "channel": {
                        "channelType": "TEST",
                        "description": "测试频道",
                        "uuid": "test-channel-uuid"
                    },
                    "nickname": "测试用户",
                    "userSettings": {
                        "backgroundMusic": "default"
                    },
                    "uuid": "test-user-uuid",
                    "userStuffs": {
                        "PET": {
                            "TropicalWilds": [null],
                            "CalmFields": [null],
                            "IceSands": [null]
                        },
                        "POSTER": {
                            "TropicalWilds": [null],
                            "CalmFields": [
                                {
                                    "amount": 1,
                                    "userStuffBase": {
                                        "attachment": null,
                                        "stuffPrices": [
                                            {
                                                "stuffId": "test-stuff-id",
                                                "amount": 4
                                            }
                                        ],
                                        "userStuffType": "POSTER",
                                        "userStuffScene": "CalmFields",
                                        "uuid": "test-poster-uuid",
                                        "description": "测试海报的描述",
                                        "icon": "poster1",
                                        "name": "测试海报"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-02 11:17:57",
                                    "uuid": "test-poster-instance-uuid"
                                }
                            ],
                            "IceSands": [
                                {
                                    "amount": 2,
                                    "userStuffBase": {
                                        "attachment": null,
                                        "stuffPrices": [
                                            {
                                                "stuffId": "test-ice-stuff-id",
                                                "amount": 4
                                            }
                                        ],
                                        "userStuffType": "POSTER",
                                        "userStuffScene": "IceSands",
                                        "uuid": "test-ice-poster-uuid",
                                        "description": "冰雪海报的描述",
                                        "icon": "poster2",
                                        "name": "冰雪海报"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-02 11:17:57",
                                    "uuid": "test-ice-poster-instance-uuid"
                                }
                            ]
                        }
                    },
                    "createTime": 1756469068538
                }
            },
            "code": "",
            "message": "",
            "errors": null
        }
        """
        
        parseLoginDataAndGeneratePosters(testLoginJson)
    }
}

// MARK: - 海报数据模型
struct Poster: Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String
    let isUnlocked: Bool
    let category: PosterCategory
    let badgeNumber: Int?
}

enum PosterCategory: String, CaseIterable {
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