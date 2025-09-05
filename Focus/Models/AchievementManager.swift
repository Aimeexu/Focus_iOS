//
//  AchievementManager.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import Foundation
import SwiftUI

// MARK: - 成就管理器
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    
    private init() {}
    
    /// 解析登录响应数据并生成成就
    func parseLoginDataAndGenerateAchievements(_ loginJsonString: String) {
        isLoading = true
        
        guard let data = loginJsonString.data(using: .utf8) else {
            print("❌ 无法将登录数据转换为Data")
            generateDefaultAchievements()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let loginResponse = try decoder.decode(AchievementLoginResponse.self, from: data)
            
            if loginResponse.status == "success", let loginData = loginResponse.data {
                print("✅ 成功解析登录数据")
                generateAchievementsFromLoginData(loginData.user)
            } else {
                print("❌ 登录状态不成功: \(loginResponse.status)")
                generateDefaultAchievements()
            }
        } catch {
            print("❌ 解析登录数据失败: \(error)")
            generateDefaultAchievements()
        }
        
        isLoading = false
    }
    
    /// 从用户管理器的当前用户生成成就
    func generateAchievementsFromCurrentUser() {
        isLoading = true
        
        guard let user = UserManager.shared.currentUser else {
            generateDefaultAchievements()
            return
        }
        
        generateAchievementsFromUserInfo(user)
        isLoading = false
    }
    
    /// 从登录数据的用户信息生成成就
    private func generateAchievementsFromLoginData(_ user: AchievementUser) {
        var generatedAchievements: [Achievement] = []
        var achievementId = 1
        
        // 处理宠物成就
        if let petStuffs = user.userStuffs.pet {
            // Calm Fields 宠物成就
            if let calmFieldsPets = petStuffs.calmFields {
                let validPets = calmFieldsPets.compactMap { $0 }
                for pet in validPets {
                    let achievement = Achievement(
                        id: achievementId,
                        title: pet.userStuffBase.name,
                        description: pet.userStuffBase.description,
                        image: getImageForStuff(pet.userStuffBase),
                        isUnlocked: true,
                        category: .calmFields,
                        badgeNumber: pet.amount
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
            
            // Ice Sands 宠物成就
            if let iceSandsPets = petStuffs.iceSands {
                let validPets = iceSandsPets.compactMap { $0 }
                for pet in validPets {
                    let achievement = Achievement(
                        id: achievementId,
                        title: pet.userStuffBase.name,
                        description: pet.userStuffBase.description,
                        image: getImageForStuff(pet.userStuffBase),
                        isUnlocked: true,
                        category: .iceSands,
                        badgeNumber: pet.amount
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
            
            // Tropical Wilds 宠物成就
            if let tropicalPets = petStuffs.tropicalWilds {
                let validPets = tropicalPets.compactMap { $0 }
                for pet in validPets {
                    let achievement = Achievement(
                        id: achievementId,
                        title: pet.userStuffBase.name,
                        description: pet.userStuffBase.description,
                        image: getImageForStuff(pet.userStuffBase),
                        isUnlocked: true,
                        category: .tropicalWilds,
                        badgeNumber: pet.amount
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
        }
        
        // 处理海报成就
        if let posterStuffs = user.userStuffs.poster {
            // Calm Fields 海报成就
            if let calmFieldsPosters = posterStuffs.calmFields {
                let validPosters = calmFieldsPosters.compactMap { $0 }
                for poster in validPosters {
                    let achievement = Achievement(
                        id: achievementId,
                        title: "\(poster.userStuffBase.name) 收集者",
                        description: "收集了 \(poster.userStuffBase.name)",
                        image: getImageForStuff(poster.userStuffBase),
                        isUnlocked: true,
                        category: .calmFields,
                        badgeNumber: poster.amount
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
            
            // Ice Sands 海报成就
            if let iceSandsPosters = posterStuffs.iceSands {
                let validPosters = iceSandsPosters.compactMap { $0 }
                for poster in validPosters {
                    let achievement = Achievement(
                        id: achievementId,
                        title: "\(poster.userStuffBase.name) 收集者",
                        description: "收集了 \(poster.userStuffBase.name)",
                        image: getImageForStuff(poster.userStuffBase),
                        isUnlocked: true,
                        category: .iceSands,
                        badgeNumber: poster.amount
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
            
            // Tropical Wilds 海报成就
            if let tropicalPosters = posterStuffs.tropicalWilds {
                let validPosters = tropicalPosters.compactMap { $0 }
                for poster in validPosters {
                    let achievement = Achievement(
                        id: achievementId,
                        title: "\(poster.userStuffBase.name) 收集者",
                        description: "收集了 \(poster.userStuffBase.name)",
                        image: getImageForStuff(poster.userStuffBase),
                        isUnlocked: true,
                        category: .tropicalWilds,
                        badgeNumber: poster.amount
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
        }
        
        // 添加未解锁的成就占位符
        generatedAchievements.append(contentsOf: generatePlaceholderAchievements(startingId: achievementId))
        
        DispatchQueue.main.async {
            self.achievements = generatedAchievements
        }
        
        print("✅ 从登录数据生成了 \(generatedAchievements.count) 个成就")
    }
    
    /// 从 UserInfo 生成成就（兼容现有的用户管理器）
    private func generateAchievementsFromUserInfo(_ user: UserInfo) {
        var generatedAchievements: [Achievement] = []
        var achievementId = 1
        
        // 根据用户物品生成成就
        for userStuff in user.userStuffs {
            let achievement = Achievement(
                id: achievementId,
                title: "物品收集者",
                description: "收集了物品",
                image: "hedgehog", // 默认图标
                isUnlocked: true,
                category: .calmFields, // 默认分类
                badgeNumber: userStuff.amount
            )
            generatedAchievements.append(achievement)
            achievementId += 1
        }
        
        // 添加未解锁的成就占位符
        generatedAchievements.append(contentsOf: generatePlaceholderAchievements(startingId: achievementId))
        
        DispatchQueue.main.async {
            self.achievements = generatedAchievements
        }
        
        print("✅ 从用户信息生成了 \(generatedAchievements.count) 个成就")
    }
    
    /// 生成默认成就
    private func generateDefaultAchievements() {
        let defaultAchievements = [
            Achievement(id: 1, title: "开始专注", description: "完成第一次专注", image: "hedgehog", isUnlocked: false, category: .calmFields, badgeNumber: nil),
            Achievement(id: 2, title: "专注新手", description: "完成10次专注", image: "owl", isUnlocked: false, category: .calmFields, badgeNumber: nil),
            Achievement(id: 3, title: "冰雪精灵", description: "在冰雪场景中专注", image: "question", isUnlocked: false, category: .iceSands, badgeNumber: nil),
            Achievement(id: 4, title: "冰雪大师", description: "完成冰雪挑战", image: "question", isUnlocked: false, category: .iceSands, badgeNumber: nil),
            Achievement(id: 5, title: "热带探险者", description: "在热带场景中专注", image: "question", isUnlocked: false, category: .tropicalWilds, badgeNumber: nil),
            Achievement(id: 6, title: "热带大师", description: "完成热带挑战", image: "question", isUnlocked: false, category: .tropicalWilds, badgeNumber: nil)
        ]
        
        DispatchQueue.main.async {
            self.achievements = defaultAchievements
        }
        
        print("✅ 生成了默认成就")
    }
    
    /// 生成占位符成就
    private func generatePlaceholderAchievements(startingId: Int) -> [Achievement] {
        var placeholders: [Achievement] = []
        var id = startingId
        
        // 为每个分类添加一些未解锁的成就
        let categories: [(AchievementCategory, String)] = [
            (.calmFields, "CalmFields"),
            (.iceSands, "IceSands"),
            (.tropicalWilds, "TropicalWilds")
        ]
        
        for (category, name) in categories {
            // 只为没有成就的分类添加占位符
            let existingAchievements = achievements.filter { $0.category == category && $0.isUnlocked }
            if existingAchievements.isEmpty {
                for i in 1...2 {
                    let achievement = Achievement(
                        id: id,
                        title: "未解锁成就 \(i)",
                        description: "在 \(name) 场景中获得更多物品来解锁",
                        image: "question",
                        isUnlocked: false,
                        category: category,
                        badgeNumber: nil
                    )
                    placeholders.append(achievement)
                    id += 1
                }
            }
        }
        
        return placeholders
    }
    
    /// 根据物品信息获取对应的图片名称
    private func getImageForStuff(_ stuffBase: AchievementUserStuffBase) -> String {
        // 根据物品图标或名称映射到本地图片资源
        switch stuffBase.icon.lowercased() {
        case "pet1":
            return "hedgehog"
        case "pet2":
            return "owl"
        case "poster1", "poster2":
            return "poster"
        default:
            // 根据物品类型返回默认图标
            switch stuffBase.userStuffType {
            case "PET":
                return "hedgehog"
            case "POSTER":
                return "poster"
            default:
                return "question"
            }
        }
    }
    
    /// 测试解析登录数据的方法
    func testParseLoginData() {
        print("🧪 开始测试解析登录数据，使用真实的场景分类...")
        let testLoginJson = """
        {
            "status": "success",
            "data": {
                "accessTokenName": "focus-pals-token",
                "refreshToken": "eyJhbGciOiJSUzI1NiJ9...",
                "accessToken": "bfd6f9d0-b650-4207-9a64-73cebf0c2cea",
                "user": {
                    "account": "APPLE-BIPPlPDG",
                    "phone": null,
                    "channel": {
                        "channelType": "APPLE",
                        "description": "11111",
                        "uuid": "1385d076-333f-4bb1-ab40-dcc9f0d2cdf0"
                    },
                    "nickname": null,
                    "userSettings": {
                        "backgroundMusic": "default"
                    },
                    "uuid": "bc499c83-9487-4fc8-b820-94f3186c305e",
                    "userStuffs": {
                        "PET": {
                            "TropicalWilds": [null, null],
                            "CalmFields": [
                                {
                                    "amount": 4,
                                    "userStuffBase": {
                                        "attachment": {
                                            "child": "http://www.cdbolv.com/assets/file/fp/owl_child.json",
                                            "adult": "http://www.cdbolv.com/assets/file/fp/owl_adult.json",
                                            "sleep": "http://www.cdbolv.com/assets/file/fp/owl_sleep.json"
                                        },
                                        "stuffPrices": [
                                            {
                                                "stuffId": "94164b90-7e14-4541-b9b4-599345abf8a0",
                                                "amount": 1
                                            }
                                        ],
                                        "userStuffType": "PET",
                                        "userStuffScene": "CalmFields",
                                        "uuid": "639a15cb-c828-4ea7-bacc-ff6e6ace41d7",
                                        "description": "宠物2的描述",
                                        "icon": "pet2",
                                        "name": "宠物2"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-05 12:01:26",
                                    "uuid": "07ad8e4b-829b-46d2-95ba-6b64ec7a3766"
                                }
                            ],
                            "IceSands": [null, null]
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
                                                "stuffId": "94164b90-7e14-4541-b9b4-599345abf8a0",
                                                "amount": 4
                                            }
                                        ],
                                        "userStuffType": "POSTER",
                                        "userStuffScene": "CalmFields",
                                        "uuid": "390d71dc-ed7c-45b2-a4ae-81beea557884",
                                        "description": "海报1的描述",
                                        "icon": "poster1",
                                        "name": "海报1"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-02 11:17:57",
                                    "uuid": "8c782053-86c7-4887-bf20-e880b73c17f5"
                                }
                            ],
                            "IceSands": [
                                {
                                    "amount": 1,
                                    "userStuffBase": {
                                        "attachment": null,
                                        "stuffPrices": [
                                            {
                                                "stuffId": "3f010ce1-77e6-403d-a1e3-32bf1117eba3",
                                                "amount": 4
                                            }
                                        ],
                                        "userStuffType": "POSTER",
                                        "userStuffScene": "IceSands",
                                        "uuid": "3e5b0426-4c91-4471-bfdf-33a67006f908",
                                        "description": "海报2的描述",
                                        "icon": "poster2",
                                        "name": "海报2"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-02 11:17:57",
                                    "uuid": "e3e2d466-bbae-47cc-b09c-9d4e93ab8593"
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
        
        print("🧪 开始测试解析登录数据...")
        parseLoginDataAndGenerateAchievements(testLoginJson)
    }
}