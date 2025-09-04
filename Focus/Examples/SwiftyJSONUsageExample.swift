//
//  SwiftyJSONUsageExample.swift
//  Focus
//
//  SwiftyJSON使用示例
//

import Foundation
import SwiftyJSON

// MARK: - SwiftyJSON使用示例
class SwiftyJSONUsageExample {
    
    /// 示例：使用SwiftyJSON获取物品列表
    func getStuffListExample() async {
        do {
            let json = try await NetworkManager.shared.getUserStuffBaseListWithJSON()
            
            // 使用SwiftyJSON轻松访问数据
            print("📦 物品列表响应:")
            print("状态码: \(json["code"].intValue)")
            print("消息: \(json["message"].stringValue)")
            
            // 访问数据数组
            let dataArray = json["data"].arrayValue
            print("物品数量: \(dataArray.count)")
            
            // 遍历物品列表
            for (index, item) in dataArray.enumerated() {
                print("物品 \(index + 1):")
                print("  ID: \(item["id"].stringValue)")
                print("  名称: \(item["name"].stringValue)")
                print("  类型: \(item["type"].stringValue)")
                print("  数量: \(item["count"].intValue)")
                
                // 安全访问可能不存在的字段
                if let description = item["description"].string {
                    print("  描述: \(description)")
                }
            }
            
        } catch {
            print("❌ 获取物品列表失败: \(error)")
        }
    }
    
    /// 示例：使用SwiftyJSON开始专注计时
    func startConcentrationExample() async {
        do {
            let json = try await NetworkManager.shared.startConcentrationWithJSON(
                duration: 25,
                concentrationPlanTag: "work"
            )
            
            print("🎯 专注计时开始响应:")
            print("状态码: \(json["code"].intValue)")
            print("消息: \(json["message"].stringValue)")
            
            // 访问返回的专注计划数据
            let data = json["data"]
            if data.exists() {
                print("专注计划ID: \(data["id"].stringValue)")
                print("开始时间: \(data["startTime"].stringValue)")
                print("持续时间: \(data["duration"].intValue)分钟")
                
                // 检查是否有奖励信息
                let rewards = data["rewards"].arrayValue
                if !rewards.isEmpty {
                    print("奖励列表:")
                    for reward in rewards {
                        print("  - \(reward["name"].stringValue): \(reward["amount"].intValue)")
                    }
                }
            }
            
        } catch {
            print("❌ 开始专注计时失败: \(error)")
        }
    }
    
    /// 示例：使用SwiftyJSON进行Apple登录
    func appleLoginExample() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let operateDate = dateFormatter.string(from: Date())
        let timeZone = TimeZone.current.identifier
        let identityToken = "example_token" // 实际使用时从Apple Sign In获取
        
        do {
            let json = try await NetworkManager.shared.appleLoginWithJSON(
                operateDate: operateDate,
                timeZone: timeZone,
                identityToken: identityToken
            )
            
            print("🍎 Apple登录响应:")
            print("状态码: \(json["code"].intValue)")
            print("消息: \(json["message"].stringValue)")
            
            // 访问用户数据
            let userData = json["data"]["user"]
            if userData.exists() {
                print("用户信息:")
                print("  ID: \(userData["id"].stringValue)")
                print("  昵称: \(userData["nickname"].stringValue)")
                print("  头像: \(userData["avatar"].stringValue)")
                
                // 检查VIP状态
                if userData["isVip"].boolValue {
                    print("  VIP状态: 是")
                    print("  VIP到期时间: \(userData["vipExpireTime"].stringValue)")
                } else {
                    print("  VIP状态: 否")
                }
            }
            
            // 访问认证信息
            let authData = json["data"]["auth"]
            if authData.exists() {
                print("认证信息:")
                print("  Token: \(authData["token"].stringValue)")
                print("  过期时间: \(authData["expireTime"].stringValue)")
            }
            
        } catch {
            print("❌ Apple登录失败: \(error)")
        }
    }
    
    /// 示例：处理复杂的嵌套JSON数据
    func handleComplexJSONExample() async {
        do {
            // 假设这是一个复杂的API响应
            let json = try await NetworkManager.shared.getJSON(
                url: "http://ds2.tapgame.cn/app/user/dashboard",
                headers: NetworkManager.shared.getAuthHeaders()
            )
            
            print("📊 仪表板数据:")
            
            // 处理用户统计数据
            let stats = json["data"]["statistics"]
            if stats.exists() {
                print("统计数据:")
                print("  总专注时长: \(stats["totalFocusTime"].intValue)分钟")
                print("  今日专注: \(stats["todayFocusTime"].intValue)分钟")
                print("  连续天数: \(stats["streakDays"].intValue)天")
                
                // 处理成就数据
                let achievements = stats["achievements"].arrayValue
                print("  成就数量: \(achievements.count)")
                for achievement in achievements {
                    print("    - \(achievement["name"].stringValue): \(achievement["progress"].doubleValue)%")
                }
            }
            
            // 处理物品背包数据
            let inventory = json["data"]["inventory"]
            if inventory.exists() {
                print("背包信息:")
                print("  容量: \(inventory["capacity"].intValue)")
                print("  已使用: \(inventory["used"].intValue)")
                
                // 按类别分组显示物品
                let items = inventory["items"].arrayValue
                var itemsByCategory: [String: [JSON]] = [:]
                
                for item in items {
                    let category = item["category"].stringValue
                    if itemsByCategory[category] == nil {
                        itemsByCategory[category] = []
                    }
                    itemsByCategory[category]?.append(item)
                }
                
                for (category, categoryItems) in itemsByCategory {
                    print("  \(category)类物品:")
                    for item in categoryItems {
                        print("    - \(item["name"].stringValue) x\(item["count"].intValue)")
                    }
                }
            }
            
        } catch {
            print("❌ 获取仪表板数据失败: \(error)")
        }
    }
    
    /// 示例：SwiftyJSON的常用操作
    func swiftyJSONOperationsExample() {
        // 创建JSON对象
        let jsonString = """
        {
            "user": {
                "id": 123,
                "name": "张三",
                "email": "zhangsan@example.com",
                "preferences": {
                    "theme": "dark",
                    "notifications": true
                },
                "tags": ["developer", "swift", "ios"]
            }
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            let json = try! JSON(data: data)
            
            // 基本访问
            print("用户ID: \(json["user"]["id"].intValue)")
            print("用户名: \(json["user"]["name"].stringValue)")
            
            // 安全访问（可能不存在的字段）
            if let email = json["user"]["email"].string {
                print("邮箱: \(email)")
            }
            
            // 访问嵌套对象
            let preferences = json["user"]["preferences"]
            print("主题: \(preferences["theme"].stringValue)")
            print("通知: \(preferences["notifications"].boolValue)")
            
            // 访问数组
            let tags = json["user"]["tags"].arrayValue
            print("标签: \(tags.map { $0.stringValue }.joined(separator: ", "))")
            
            // 检查字段是否存在
            if json["user"]["avatar"].exists() {
                print("头像: \(json["user"]["avatar"].stringValue)")
            } else {
                print("用户没有设置头像")
            }
            
            // 类型转换
            let userIdString = json["user"]["id"].stringValue // "123"
            let userIdInt = json["user"]["id"].intValue // 123
            let userIdDouble = json["user"]["id"].doubleValue // 123.0
            
            print("ID转换: String=\(userIdString), Int=\(userIdInt), Double=\(userIdDouble)")
        }
    }
}