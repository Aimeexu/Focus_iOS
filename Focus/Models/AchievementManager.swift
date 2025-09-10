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
    
    // 保存当前用户数据的引用
    var currentUserData: AchievementUser?

    private init() {}

    /// 获取所有宠物（从登录数据中提取）
    var allPets: [AchievementUserStuff] {
        guard let userData = currentUserData,
              let petStuffs = userData.userStuffs.pet else {
            return []
        }
        
        var allPets: [AchievementUserStuff] = []
        
        // 收集所有场景的宠物
        if let calmFieldsPets = petStuffs.calmFields {
            allPets.append(contentsOf: calmFieldsPets.compactMap { $0 })
        }
        
        if let iceSandsPets = petStuffs.iceSands {
            allPets.append(contentsOf: iceSandsPets.compactMap { $0 })
        }
        
        if let tropicalPets = petStuffs.tropicalWilds {
            allPets.append(contentsOf: tropicalPets.compactMap { $0 })
        }
        
        return allPets
    }

    /// 解析登录响应数据并生成成就
    func parseLoginDataAndGenerateAchievements(_ loginJsonString: String) {
        isLoading = true

        guard let data = loginJsonString.data(using: .utf8) else {
            print("❌ 无法将登录数据转换为Data")
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
            }
        } catch {
            print("❌ 解析登录数据失败: \(error)")
        }

        isLoading = false
    }

    /// 从用户管理器的当前用户生成成就
    func generateAchievementsFromCurrentUser() {
        isLoading = true

        // 优先使用已保存的完整登录数据
        if let userData = currentUserData {
            print("🎯 使用已保存的完整用户数据生成成就...")
            generateAchievementsFromLoginData(userData)
        }

        isLoading = false
    }
    
    /// 检查是否有完整的用户数据
    var hasCompleteUserData: Bool {
        return currentUserData != nil
    }
    
    /// 强制重新从登录数据生成成就（用于调试）
    func forceRegenerateFromLoginData() {
        guard let userData = currentUserData else {
            print("❌ 没有完整的登录数据可用于重新生成")
            return
        }
        
        print("🔄 强制重新从登录数据生成成就...")
        generateAchievementsFromLoginData(userData)
    }

    /// 从登录数据的用户信息生成成就
    private func generateAchievementsFromLoginData(_ user: AchievementUser) {
        print("🎯 开始从登录数据生成成就...")
        
        // 保存用户数据的引用
        self.currentUserData = user
        
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
                        badgeNumber: pet.amount,
                        isRemoteImage: true,
                        tab: .friends
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
                        badgeNumber: pet.amount,
                        isRemoteImage: true,
                        tab: .friends
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
                        badgeNumber: pet.amount,
                        isRemoteImage: true,
                        tab: .friends
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
                        badgeNumber: poster.amount,
                        isRemoteImage: true,
                        tab: .posting
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
                        badgeNumber: poster.amount,
                        isRemoteImage: true,
                        tab: .posting
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
                        badgeNumber: poster.amount,
                        isRemoteImage: true,
                        tab: .posting
                    )
                    generatedAchievements.append(achievement)
                    achievementId += 1
                }
            }
        }

        // 添加未解锁的成就占位符
//        generatedAchievements.append(contentsOf: generatePlaceholderAchievements(startingId: achievementId))

        DispatchQueue.main.async {
            self.achievements = generatedAchievements
        }

        print("✅ 从登录数据生成了 \(generatedAchievements.count) 个成就")
    }


//    /// 生成占位符成就
//    private func generatePlaceholderAchievements(startingId: Int) -> [Achievement] {
//        var placeholders: [Achievement] = []
//        var id = startingId
//
//        // 为每个分类添加一些未解锁的成就
//        let categories: [(AchievementCategory, String)] = [
//            (.calmFields, "CalmFields"),
//            (.iceSands, "IceSands"),
//            (.tropicalWilds, "TropicalWilds")
//        ]
//
//        for (category, name) in categories {
//            // 只为没有成就的分类添加占位符
//            let existingAchievements = achievements.filter { $0.category == category && $0.isUnlocked }
//            if existingAchievements.isEmpty {
//                for i in 1...2 {
//                    let achievement = Achievement(
//                        id: id,
//                        title: "未解锁成就 \(i)",
//                        description: "在 \(name) 场景中获得更多物品来解锁",
//                        image: "question",
//                        isUnlocked: false,
//                        category: category,
//                        badgeNumber: nil,
//                        isRemoteImage: false
//                    )
//                    placeholders.append(achievement)
//                    id += 1
//                }
//            }
//        }
//
//        return placeholders
//    }

    /// 根据物品信息获取对应的图片URL
    private func getImageForStuff(_ stuffBase: AchievementUserStuffBase) -> String {
        // 直接返回后台提供的完整图片URL
        let baseURL = "http://www.cdbolv.com/assets/file/fp/"

        // 如果icon已经是完整URL，直接返回
        if stuffBase.icon.hasPrefix("http") {
            return stuffBase.icon
        }

        // 否则拼接基础URL
        return baseURL + stuffBase.icon + ".png"
    }
    
    /// 获取所有海报（从登录数据中提取）
    var allPosters: [AchievementUserStuff] {
        guard let userData = currentUserData,
              let posterStuffs = userData.userStuffs.poster else {
            return []
        }
        
        var allPosters: [AchievementUserStuff] = []
        
        // 收集所有场景的海报
        if let calmFieldsPosters = posterStuffs.calmFields {
            allPosters.append(contentsOf: calmFieldsPosters.compactMap { $0 })
        }
        
        if let iceSandsPosters = posterStuffs.iceSands {
            allPosters.append(contentsOf: iceSandsPosters.compactMap { $0 })
        }
        
        if let tropicalPosters = posterStuffs.tropicalWilds {
            allPosters.append(contentsOf: tropicalPosters.compactMap { $0 })
        }
        
        return allPosters
    }
    
    /// 根据场景获取宠物
    func getPets(for scene: String) -> [AchievementUserStuff] {
        guard let userData = currentUserData,
              let petStuffs = userData.userStuffs.pet else {
            return []
        }
        
        switch scene {
        case "CalmFields":
            return petStuffs.calmFields?.compactMap { $0 } ?? []
        case "IceSands":
            return petStuffs.iceSands?.compactMap { $0 } ?? []
        case "TropicalWilds":
            return petStuffs.tropicalWilds?.compactMap { $0 } ?? []
        default:
            return []
        }
    }
    
    /// 根据场景获取海报
    func getPosters(for scene: String) -> [AchievementUserStuff] {
        guard let userData = currentUserData,
              let posterStuffs = userData.userStuffs.poster else {
            return []
        }
        
        switch scene {
        case "CalmFields":
            return posterStuffs.calmFields?.compactMap { $0 } ?? []
        case "IceSands":
            return posterStuffs.iceSands?.compactMap { $0 } ?? []
        case "TropicalWilds":
            return posterStuffs.tropicalWilds?.compactMap { $0 } ?? []
        default:
            return []
        }
    }
    
    /// 获取用户数据统计信息
    var userStatsInfo: (totalPets: Int, totalPosters: Int, totalScenes: Int) {
        let pets = allPets
        let posters = allPosters
        
        // 计算涉及的场景数量
        var scenes = Set<String>()
        pets.forEach { scenes.insert($0.userStuffBase.userStuffScene) }
        posters.forEach { scenes.insert($0.userStuffBase.userStuffScene) }
        
        return (totalPets: pets.count, totalPosters: posters.count, totalScenes: scenes.count)
    }
    
    /// 生成海报数据（供 PosterManager 使用）
    func generatePostersForPosterManager() -> [Poster] {
        guard let userData = currentUserData else { return [] }
        
        var generatedPosters: [Poster] = []
        var posterId = 1
        
        // 处理海报数据
        if let posterStuffs = userData.userStuffs.poster {
            // Calm Fields 海报
            if let calmFieldsPosters = posterStuffs.calmFields {
                let validPosters = calmFieldsPosters.compactMap { $0 }
                for posterStuff in validPosters {
                    let poster = Poster(
                        id: posterId,
                        title: posterStuff.userStuffBase.name,
                        description: posterStuff.userStuffBase.description,
                        image: getImageForStuff(posterStuff.userStuffBase),
                        isUnlocked: true,
                        category: .calmFields,
                        badgeNumber: posterStuff.amount > 1 ? posterStuff.amount : nil
                    )
                    generatedPosters.append(poster)
                    posterId += 1
                }
            }
            
            // Ice Sands 海报
            if let iceSandsPosters = posterStuffs.iceSands {
                let validPosters = iceSandsPosters.compactMap { $0 }
                for posterStuff in validPosters {
                    let poster = Poster(
                        id: posterId,
                        title: posterStuff.userStuffBase.name,
                        description: posterStuff.userStuffBase.description,
                        image: getImageForStuff(posterStuff.userStuffBase),
                        isUnlocked: true,
                        category: .iceSands,
                        badgeNumber: posterStuff.amount > 1 ? posterStuff.amount : nil
                    )
                    generatedPosters.append(poster)
                    posterId += 1
                }
            }
            
            // Tropical Wilds 海报
            if let tropicalPosters = posterStuffs.tropicalWilds {
                let validPosters = tropicalPosters.compactMap { $0 }
                for posterStuff in validPosters {
                    let poster = Poster(
                        id: posterId,
                        title: posterStuff.userStuffBase.name,
                        description: posterStuff.userStuffBase.description,
                        image: getImageForStuff(posterStuff.userStuffBase),
                        isUnlocked: true,
                        category: .tropicalWilds,
                        badgeNumber: posterStuff.amount > 1 ? posterStuff.amount : nil
                    )
                    generatedPosters.append(poster)
                    posterId += 1
                }
            }
        }
        
        return generatedPosters
    }
    
    /// 测试用的解析登录数据方法
    func testParseLoginData() {
        print("🧪 开始测试解析登录数据...")
        
        // 测试完成后打印统计信息
        defer {
            let stats = userStatsInfo
            print("📊 数据统计:")
            print("   - 总宠物数: \(stats.totalPets)")
            print("   - 总海报数: \(stats.totalPosters)")
            print("   - 涉及场景数: \(stats.totalScenes)")
            
            print("🐾 所有宠物:")
            for (index, pet) in allPets.enumerated() {
                print("   \(index + 1). \(pet.userStuffBase.name) (\(pet.userStuffBase.userStuffScene)) - 数量: \(pet.amount)")
                print("      图标: \(pet.userStuffBase.icon)")
            }
        }
        
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
                            "TropicalWilds": [
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
                                        "userStuffType": "PET",
                                        "userStuffScene": "TropicalWilds",
                                        "uuid": "test-pet-uuid",
                                        "description": "可爱的热带小鸟",
                                        "icon": "bird",
                                        "name": "热带小鸟"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-02 11:17:57",
                                    "uuid": "test-pet-instance-uuid"
                                }
                            ],
                            "CalmFields": [
                                {
                                    "amount": 2,
                                    "userStuffBase": {
                                        "attachment": null,
                                        "stuffPrices": [
                                            {
                                                "stuffId": "test-stuff-id-2",
                                                "amount": 4
                                            }
                                        ],
                                        "userStuffType": "PET",
                                        "userStuffScene": "CalmFields",
                                        "uuid": "test-hedgehog-uuid",
                                        "description": "温顺的小刺猬",
                                        "icon": "hedgehog",
                                        "name": "田野刺猬"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-02 11:17:57",
                                    "uuid": "test-hedgehog-instance-uuid"
                                }
                            ],
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
                                        "description": "宁静田野的美丽海报",
                                        "icon": "poster1",
                                        "name": "田野风光"
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
                                        "description": "冰雪世界的壮丽景色",
                                        "icon": "poster2",
                                        "name": "冰雪奇景"
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
        
        parseLoginDataAndGenerateAchievements(testLoginJson)
    }

}
