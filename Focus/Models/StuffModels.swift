//
//  StuffModels.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import Foundation
import SwiftUI

// MARK: - 物品相关数据模型

// MARK: - 登录响应数据模型（用于成就系统）
struct AchievementLoginResponse: Codable {
    let status: String
    let data: AchievementLoginData?
    let code: String
    let message: String
    let errors: String?
}

struct AchievementLoginData: Codable {
    let accessTokenName: String
    let refreshToken: String
    let accessToken: String
    let user: AchievementUser
}

struct AchievementUser: Codable {
    let account: String
    let phone: String?
    let channel: AchievementChannel
    let nickname: String?
    let userSettings: AchievementUserSettings
    let uuid: String
    let userStuffs: AchievementUserStuffs
    let createTime: Int64
}

struct AchievementChannel: Codable {
    let channelType: String
    let description: String
    let uuid: String
}

struct AchievementUserSettings: Codable {
    let backgroundMusic: String
}

// 用户物品数据结构，按类型和场景分组
struct AchievementUserStuffs: Codable {
    let pet: AchievementPetStuffs?
    let poster: AchievementPosterStuffs?
    
    enum CodingKeys: String, CodingKey {
        case pet = "PET"
        case poster = "POSTER"
    }
    
    // 获取所有用户物品
    var allUserStuffs: [AchievementUserStuff] {
        var allStuffs: [AchievementUserStuff] = []
        
        // 添加所有宠物
        if let petStuffs = pet?.allPets {
            allStuffs.append(contentsOf: petStuffs)
        }
        
        // 添加所有海报
        if let posterStuffs = poster?.allPosters {
            allStuffs.append(contentsOf: posterStuffs)
        }
        
        return allStuffs
    }
}

struct AchievementPetStuffs: Codable {
    var tropicalWilds: [AchievementUserStuff?]?
    var calmFields: [AchievementUserStuff?]?
    var iceSands: [AchievementUserStuff?]?
    
    enum CodingKeys: String, CodingKey {
        case tropicalWilds = "TropicalWilds"
        case calmFields = "CalmFields"
        case iceSands = "IceSands"
    }
    
    // 获取所有宠物
    var allPets: [AchievementUserStuff] {
        let allPets = (tropicalWilds ?? []) + (calmFields ?? []) + (iceSands ?? [])
        return allPets.compactMap { $0 }
    }
}

struct AchievementPosterStuffs: Codable {
    var tropicalWilds: [AchievementUserStuff?]?
    var calmFields: [AchievementUserStuff?]?
    var iceSands: [AchievementUserStuff?]?
    
    enum CodingKeys: String, CodingKey {
        case tropicalWilds = "TropicalWilds"
        case calmFields = "CalmFields"
        case iceSands = "IceSands"
    }
    
    // 获取所有海报
    var allPosters: [AchievementUserStuff] {
        let allPosters = (tropicalWilds ?? []) + (calmFields ?? []) + (iceSands ?? [])
        return allPosters.compactMap { $0 }
    }
}

struct AchievementUserStuff: Codable {
    let amount: Int
    let userStuffBase: AchievementUserStuffBase
    let createTime: String
    let updateTime: String
    let uuid: String
}

struct AchievementUserStuffBase: Codable {
    let attachment: StuffAttachment?
    let shareImage: String
//    let stuffPrices: [StuffPrice]
    let userStuffType: String
    let userStuffScene: String
    let uuid: String
    let description: String
    let icon: String
    let name: String
    
    // 计算属性：获取物品类型枚举
    var stuffType: UserStuffType? {
        return UserStuffType(rawValue: userStuffType)
    }
}

// MARK: - 专注计划启动响应模型
struct ConcentrationStartResponse: Codable {
    let status: String
    let data: ConcentrationStartData?
    let code: String
    let message: String
    // 忽略errors字段，避免类型不匹配问题
    
    enum CodingKeys: String, CodingKey {
        case status, data, code, message
        // 不包含errors，这样就会忽略这个字段
    }
}

struct ConcentrationStartData: Codable {
    let concentrationPlan: ConcentrationPlan
    let currentDropStuff: CurrentDropStuff
    let stuffDropAmount: Int
}

struct ConcentrationPlan: Codable {
    let uuid: String
    let userId: String
    let status: String
    let startDate: String
    let duration: Int
    let createTime: String
    
    // 计算属性：获取开始时间
    var startDateTime: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: startDate)
    }
    
    // 计算属性：获取创建时间
    var createDateTime: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: createTime)
    }
    
    // 计算属性：获取结束时间
    var endDateTime: Date? {
        guard let start = startDateTime else { return nil }
        return Calendar.current.date(byAdding: .minute, value: duration, to: start)
    }
    
    // 计算属性：剩余时间（秒）
    var remainingSeconds: Int {
        guard let end = endDateTime else { return 0 }
        let remaining = end.timeIntervalSinceNow
        return max(0, Int(remaining))
    }
    
    // 计算属性：是否已完成
    var isCompleted: Bool {
        return remainingSeconds <= 0
    }
}

struct CurrentDropStuff: Codable {
    let uuid: String
    let userStuffType: String
    let userStuffScene: String
    let icon: String
    let name: String
    let description: String
    let attachment: StuffAttachment?
    
    // 计算属性：获取物品类型枚举
    var stuffType: UserStuffType? {
        return UserStuffType(rawValue: userStuffType)
    }
}

// MARK: - 专注计时结束响应模型
struct ConcentrationEndResponse: Codable {
    let status: String
    let data: ConcentrationEndData?
    let code: String
    let message: String
    // 忽略errors字段，避免类型不匹配问题
    
    enum CodingKeys: String, CodingKey {
        case status, data, code, message
        // 不包含errors，这样就会忽略这个字段
    }
}

struct ConcentrationEndData: Codable {
    let userStuff: AchievementUserStuff
}

// 物品列表请求响应
struct StuffListResponse: Codable {
    let status: String
    let data: StuffListData?
    let code: String
    let message: String
    // 忽略errors字段，避免类型不匹配问题
    
    enum CodingKeys: String, CodingKey {
        case status, data, code, message
        // 不包含errors，这样就会忽略这个字段
    }
}

// 物品列表数据容器
struct StuffListData: Codable {
    let userStuffBases: [UserStuffBase]
}

// 用户物品基础信息
struct UserStuffBase: Codable, Identifiable {
    let uuid: String
    let name: String
    let description: String
    let icon: String
    let userStuffType: UserStuffType
    let userStuffScene: String?
//    let stuffPrices: [StuffPrice]
    let attachment: StuffAttachment?
    
    var id: String { uuid }
}

// 物品类型枚举
enum UserStuffType: String, Codable, CaseIterable {
    case poster = "POSTER"
    case pet = "PET"
    case background = "BACKGROUND"
    case music = "MUSIC"
    
    var displayName: String {
        switch self {
        case .poster:
            return "海报"
        case .pet:
            return "宠物"
        case .background:
            return "背景"
        case .music:
            return "音乐"
        }
    }
    
    var icon: String {
        switch self {
        case .poster:
            return "photo"
        case .pet:
            return "pawprint"
        case .background:
            return "paintbrush"
        case .music:
            return "music.note"
        }
    }
}

// 物品价格信息
struct StuffPrice: Codable, Identifiable {
    let stuffId: String
    let amount: Int
    
    var id: String { stuffId }
}

// 物品附件信息（主要用于宠物的动画文件）
struct StuffAttachment: Codable {
    let child: String?
    let adult: String?
    let sleep: String?
    
    // 获取所有动画URL
    var allAnimationURLs: [String] {
        return [child, adult, sleep].compactMap { $0 }
    }
    
    // 根据状态获取动画URL
    func getAnimationURL(for state: PetState) -> String? {
        switch state {
        case .child:
            return child
        case .adult:
            return adult
        case .sleep:
            return sleep
        case .transitioningToAdult:
            
        }
    }
}

// 宠物状态枚举
enum PetState {
    case child
    case adult
    case sleep
    case transitioningToAdult

    var displayName: String {
        switch self {
        case .child: return "Child"
        case .adult: return "Adult"
        case .sleep: return "Sleep"
        case .transitioningToAdult: return "TransitioningToAdult"
        }
    }
}

// 物品管理器
class StuffManager: ObservableObject {
    static let shared = StuffManager()
    
    @Published var userStuffBases: [UserStuffBase] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // 获取物品列表
    func fetchStuffList() async throws -> [UserStuffBase] {
        isLoading = true
        let baseURL = "http://ds2.tapgame.cn"
        
        do {
            print("🛍️ 开始获取物品列表...")
            
            let response: StuffListResponse = try await NetworkManager.shared.getUserStuffBaseList()
            
            print("🛍️ 物品列表响应: \(response)")
            
            if response.status == "success", let data = response.data {
                let items = data.userStuffBases
                await MainActor.run {
                    self.userStuffBases = items
                    self.errorMessage = nil
                    self.isLoading = false
                }
                print("✅ 成功获取 \(items.count) 个物品")
                return items
            } else {
                let error = NetworkError.networkError(response.message.isEmpty ? "获取物品列表失败" : response.message)
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                throw error
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("❌ 获取物品列表失败: \(error)")
            throw error
        }
    }
    
    // 根据ID查找物品
    func getUserStuffBase(by id: String) -> UserStuffBase? {
        return userStuffBases.first { $0.uuid == id }
    }
    
    // 根据类型筛选物品
    func getUserStuffBases(by type: UserStuffType) -> [UserStuffBase] {
        return userStuffBases.filter { $0.userStuffType == type }
    }
    
    // 获取所有海报
    var posters: [UserStuffBase] {
        return getUserStuffBases(by: .poster)
    }
    
    // 获取所有宠物
    var pets: [UserStuffBase] {
        return getUserStuffBases(by: .pet)
    }
    
    // 获取所有背景
    var backgrounds: [UserStuffBase] {
        return getUserStuffBases(by: .background)
    }
    
    // 获取所有音乐
    var music: [UserStuffBase] {
        return getUserStuffBases(by: .music)
    }
    
    // 清除数据
    func clearData() {
        userStuffBases = []
        errorMessage = nil
    }
    
    // 解析专注计时结束响应
    func parseConcentrationEndResponse(_ jsonString: String) -> ConcentrationEndResponse? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ 无法将字符串转换为Data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(ConcentrationEndResponse.self, from: data)
            print("✅ 成功解析专注计时结束响应")
            print("📋 获得物品: \(response.data?.userStuff.userStuffBase.name ?? "未知")")
            print("📦 获得数量: \(response.data?.userStuff.amount ?? 0)")
            return response
        } catch {
            print("❌ 解析专注计时结束响应失败: \(error)")
            
            // 详细错误信息
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ 缺少键: \(key.stringValue), 路径: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("❌ 类型不匹配: 期望 \(type), 路径: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("❌ 值未找到: \(type), 路径: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("❌ 数据损坏: \(context.debugDescription), 路径: \(context.codingPath)")
                @unknown default:
                    print("❌ 未知解码错误: \(error)")
                }
            }
            return nil
        }
    }
    
    // 解析专注计划启动响应
    func parseConcentrationStartResponse(_ jsonString: String) -> ConcentrationStartResponse? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ 无法将字符串转换为Data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(ConcentrationStartResponse.self, from: data)
            print("✅ 成功解析专注计划启动响应")
            print("📋 专注计划ID: \(response.data?.concentrationPlan.uuid ?? "未知")")
            print("⏰ 专注时长: \(response.data?.concentrationPlan.duration ?? 0) 分钟")
            print("🎁 掉落物品: \(response.data?.currentDropStuff.name ?? "未知")")
            print("📦 掉落数量: \(response.data?.stuffDropAmount ?? 0)")
            return response
        } catch {
            print("❌ 解析专注计划启动响应失败: \(error)")
            
            // 详细错误信息
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ 缺少键: \(key.stringValue), 路径: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("❌ 类型不匹配: 期望 \(type), 路径: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("❌ 值未找到: \(type), 路径: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("❌ 数据损坏: \(context.debugDescription), 路径: \(context.codingPath)")
                @unknown default:
                    print("❌ 未知解码错误: \(error)")
                }
            }
            return nil
        }
    }
    
    // 更新本地数据
    func updateLocalUserStuff(with newStuff: AchievementUserStuff) {
        print("🔄 开始更新本地成就数据")
        print("   物品名称: \(newStuff.userStuffBase.name)")
        print("   物品类型: \(newStuff.userStuffBase.userStuffType)")
        print("   物品场景: \(newStuff.userStuffBase.userStuffScene)")
        print("   物品数量: \(newStuff.amount)")
        print("   物品UUID: \(newStuff.userStuffBase.uuid)")
        
        // 取出本地数据
        guard var localStuffs = UserManager.shared.getUserAchievement() else {
            print("❌ 无法获取本地成就数据")
            return
        }
        
        let stuffType = newStuff.userStuffBase.userStuffType
        let stuffScene = newStuff.userStuffBase.userStuffScene
        var updated = false
        
        // 根据物品类型更新对应的数据
        if stuffType == "PET" {
            var petStuffs = localStuffs.pet ?? AchievementPetStuffs()
            updated = updateStuffInScene(
                petStuffs: &petStuffs,
                scene: stuffScene,
                newStuff: newStuff
            )
            localStuffs = AchievementUserStuffs(pet: petStuffs, poster: localStuffs.poster)
            print("   更新宠物数据: \(updated ? "成功" : "失败")")
        } else if stuffType == "POSTER" {
            var posterStuffs = localStuffs.poster ?? AchievementPosterStuffs()
            updated = updateStuffInScene(
                posterStuffs: &posterStuffs,
                scene: stuffScene,
                newStuff: newStuff
            )
            localStuffs = AchievementUserStuffs(pet: localStuffs.pet, poster: posterStuffs)
            print("   更新海报数据: \(updated ? "成功" : "失败")")
        }
        
        if !updated {
            print("⚠️ 未找到匹配的场景或物品类型")
            return
        }
        
        // 保存回本地
        let userDefaults = UserDefaults.standard
        if let userAchievement = try? JSONEncoder().encode(localStuffs) {
            userDefaults.set(userAchievement, forKey: UserManager.Keys.userAchievement)
            userDefaults.synchronize()
            NotificationCenter.default.post(name: Notification.Name.didUpdateAchievement, object: nil)
            print("✅ 本地成就数据已更新并保存")
        } else {
            print("❌ 编码本地成就数据失败")
        }
    }
    
    // 根据场景更新宠物数据
    private func updateStuffInScene(
        petStuffs: inout AchievementPetStuffs,
        scene: String,
        newStuff: AchievementUserStuff
    ) -> Bool {
        switch scene {
        case "TropicalWilds":
            return updateOrAddStuff(in: &petStuffs.tropicalWilds, with: newStuff)
        case "CalmFields":
            return updateOrAddStuff(in: &petStuffs.calmFields, with: newStuff)
        case "IceSands":
            return updateOrAddStuff(in: &petStuffs.iceSands, with: newStuff)
        default:
            print("⚠️ 未知的宠物场景: \(scene)")
            return false
        }
    }
    
    // 根据场景更新海报数据
    private func updateStuffInScene(
        posterStuffs: inout AchievementPosterStuffs,
        scene: String,
        newStuff: AchievementUserStuff
    ) -> Bool {
        switch scene {
        case "TropicalWilds":
            return updateOrAddStuff(in: &posterStuffs.tropicalWilds, with: newStuff)
        case "CalmFields":
            return updateOrAddStuff(in: &posterStuffs.calmFields, with: newStuff)
        case "IceSands":
            return updateOrAddStuff(in: &posterStuffs.iceSands, with: newStuff)
        default:
            print("⚠️ 未知的海报场景: \(scene)")
            return false
        }
    }
    
    // 更新或添加物品到数组
    private func updateOrAddStuff(
        in array: inout [AchievementUserStuff?]?,
        with newStuff: AchievementUserStuff
    ) -> Bool {
        // 如果数组不存在，创建新数组
        if array == nil {
            array = [newStuff]
            print("   创建新数组并添加物品")
            return true
        }
        
        guard var arr = array else { return false }
        
        // 查找是否已存在该物品
        var foundIndex: Int?
        for i in 0..<arr.count {
            if let existingStuff = arr[i],
               existingStuff.userStuffBase.uuid == newStuff.userStuffBase.uuid {
                foundIndex = i
                break
            }
        }
        
        if let index = foundIndex {
            // 更新已存在的物品
            let oldAmount = arr[index]?.amount ?? 0
            arr[index] = newStuff
            print("   更新已存在物品，数量: \(oldAmount) -> \(newStuff.amount)")
        } else {
            // 添加新物品
            arr.append(newStuff)
            print("   添加新物品到数组")
        }
        
        array = arr
        return true
    }


}


