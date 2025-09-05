//
//  AchievementUsageExample.swift
//  Focus
//
//  Created by Kiro on 2025/9/5.
//

import SwiftUI

/// 展示如何在 AchievementsView 中使用登录返回的数据
struct AchievementUsageExample: View {
    @StateObject private var userManager = UserManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("成就系统使用示例")
                .font(.appLargeTitle())
                .padding()
            
            // 模拟登录按钮
            Button("模拟登录并加载成就") {
                simulateLoginAndLoadAchievements()
            }
            .buttonStyle(.borderedProminent)
            
            // 显示当前用户信息
            if let user = userManager.currentUser {
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前用户信息:")
                        .font(.appHeadline())
                    
                    Text("账号: \(user.account)")
                    Text("昵称: \(user.nickname)")
                    Text("物品数量: \(user.userStuffs.count)")
                    Text("频道类型: \(user.channel.channelType ?? "未知")")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            // 显示成就信息
            VStack(alignment: .leading, spacing: 8) {
                Text("成就信息:")
                    .font(.appHeadline())
                
                Text("总成就数: \(achievementManager.achievements.count)")
                Text("已解锁: \(achievementManager.achievements.filter { $0.isUnlocked }.count)")
                Text("未解锁: \(achievementManager.achievements.filter { !$0.isUnlocked }.count)")
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // 跳转到成就页面
            NavigationLink("查看成就页面") {
                AchievementsView()
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
        .navigationTitle("成就系统示例")
    }
    
    /// 模拟登录并加载成就数据
    private func simulateLoginAndLoadAchievements() {
        // 使用你提供的登录返回数据格式
        let loginResponseJson = """
        {
            "status": "success",
            "data": {
                "accessTokenName": "focus-pals-token",
                "refreshToken": "eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiJiYzQ5OWM4My05NDg3LTRmYzgtYjgyMC05NGYzMTg2YzMwNWUiLCJpYXQiOjE3NTcwNDU0NjIsImV4cCI6MTc1NzY1MDI2Mn0.KonP1ZbbCwwGARuJPs3wpyTG8--waQjqdemcRnB4zuwrscpmgY29qAKnllEN4rHxFXC1gouRcQrRFfdpbbaSuh16NxLzOT4Jbwvw6P8nGbaCzSuhhkbIUtwvojSLQ5fI8g4edUYpf5Z7-eLf-h0Z2OyGVyD3SdnZsFa_rPJtoR-5bz77oX8udYr6oejYUcVTx0PHXJEp8RD6wYzhIdAju2gomBdEYqvXApBMwtnUXFKNBiNDQ4t3jgiuOEp9yMpf-1I8Jr9jPvXYjr2-hI3eIcZl6EU9iUE0d899os9MH8wBx3WQLfzlIKJVP6m-ecMU-7B0FyQ8MZbr_83JaehnPg",
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
                            "TropicalWilds": [
                                {
                                    "amount": 3,
                                    "userStuffBase": {
                                        "attachment": {
                                            "child": "http://www.cdbolv.com/assets/file/fp/tropical_pet_child.json",
                                            "adult": "http://www.cdbolv.com/assets/file/fp/tropical_pet_adult.json",
                                            "sleep": "http://www.cdbolv.com/assets/file/fp/tropical_pet_sleep.json"
                                        },
                                        "stuffPrices": [
                                            {
                                                "stuffId": "tropical-pet-id",
                                                "amount": 1
                                            }
                                        ],
                                        "userStuffType": "PET",
                                        "userStuffScene": "TropicalWilds",
                                        "uuid": "tropical-pet-uuid",
                                        "description": "热带宠物的描述",
                                        "icon": "tropical_pet",
                                        "name": "热带宠物"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-05 12:01:26",
                                    "uuid": "tropical-pet-instance-uuid"
                                }
                            ],
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
                                },
                                {
                                    "amount": 5,
                                    "userStuffBase": {
                                        "attachment": {
                                            "child": "http://www.cdbolv.com/assets/file/fp/owl_child.json",
                                            "adult": "http://www.cdbolv.com/assets/file/fp/owl_adult.json",
                                            "sleep": "http://www.cdbolv.com/assets/file/fp/owl_sleep.json"
                                        },
                                        "stuffPrices": [
                                            {
                                                "stuffId": "639a15cb-c828-4ea7-bacc-ff6e6ace41d7",
                                                "amount": 1
                                            }
                                        ],
                                        "userStuffType": "PET",
                                        "userStuffScene": "CalmFields",
                                        "uuid": "94164b90-7e14-4541-b9b4-599345abf8a0",
                                        "description": "宠物1的描述",
                                        "icon": "pet1",
                                        "name": "宠物1"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2023-08-13 18:22:56",
                                    "uuid": "af82964f-d67a-4461-be08-81ae0a126fbb"
                                }
                            ],
                            "IceSands": [
                                {
                                    "amount": 2,
                                    "userStuffBase": {
                                        "attachment": {
                                            "child": "http://www.cdbolv.com/assets/file/fp/ice_pet_child.json",
                                            "adult": "http://www.cdbolv.com/assets/file/fp/ice_pet_adult.json",
                                            "sleep": "http://www.cdbolv.com/assets/file/fp/ice_pet_sleep.json"
                                        },
                                        "stuffPrices": [
                                            {
                                                "stuffId": "ice-pet-id",
                                                "amount": 1
                                            }
                                        ],
                                        "userStuffType": "PET",
                                        "userStuffScene": "IceSands",
                                        "uuid": "ice-pet-uuid",
                                        "description": "冰雪宠物的描述",
                                        "icon": "ice_pet",
                                        "name": "冰雪宠物"
                                    },
                                    "createTime": "2025-09-02 11:17:57",
                                    "updateTime": "2025-09-05 12:01:26",
                                    "uuid": "ice-pet-instance-uuid"
                                }
                            ]
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
                                            },
                                            {
                                                "stuffId": "639a15cb-c828-4ea7-bacc-ff6e6ace41d7",
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
                                            },
                                            {
                                                "stuffId": "dcedd84f-123a-4ec5-9862-ff6457a54802",
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
        
        // 使用 UserManager 保存登录数据并生成成就
        userManager.saveAchievementLoginData(loginResponseJson)
        
        print("✅ 模拟登录完成，成就数据已加载")
    }
}

#Preview {
    NavigationView {
        AchievementUsageExample()
    }
}