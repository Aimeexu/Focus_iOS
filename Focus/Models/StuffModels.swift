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
    let stuffPrices: [StuffPrice]
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
    let stuffPrices: [StuffPrice]
    
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
    let stuffPrices: [StuffPrice]
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
        }
    }
}

// 宠物状态枚举
enum PetState: String, CaseIterable {
    case child = "child"
    case adult = "adult"
    case sleep = "sleep"
    
    var displayName: String {
        switch self {
        case .child:
            return "Child"
        case .adult:
            return "Adult"
        case .sleep:
            return "Sleep"
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

        // 取出本地数据
        guard var localStuffs = UserManager.shared.getUserAchievement() else { return }
        var updated = false

        // 更新宠物
        if var petStuffs = localStuffs.pet {
            updated = updateStuff(in: &petStuffs.tropicalWilds, with: newStuff)
            || updateStuff(in: &petStuffs.calmFields, with: newStuff)
            || updateStuff(in: &petStuffs.iceSands, with: newStuff)

            localStuffs = AchievementUserStuffs(pet: petStuffs, poster: localStuffs.poster)
        }

        // 更新海报
        if !updated, var posterStuffs = localStuffs.poster {
            updated = updateStuff(in: &posterStuffs.tropicalWilds, with: newStuff)
            || updateStuff(in: &posterStuffs.calmFields, with: newStuff)
            || updateStuff(in: &posterStuffs.iceSands, with: newStuff)

            localStuffs = AchievementUserStuffs(pet: localStuffs.pet, poster: posterStuffs)
        }

        // 保存回本地
        let userDefaults = UserDefaults.standard
        if let userAchievement = try? JSONEncoder().encode(localStuffs) {
            userDefaults.set(userAchievement, forKey: UserManager.Keys.userAchievement)
            userDefaults.synchronize()
            NotificationCenter.default.post(name:Notification.Name.didUpdateAchievement, object: nil)
            print("本地成就数据已更新 ✅")
        }
    }

    // 更新数组里的某个元素
    private func updateStuff(in array: inout [AchievementUserStuff?]?, with newStuff: AchievementUserStuff) -> Bool {
        guard var arr = array else { return false }

        for i in 0..<arr.count {
            if let oldStuff = arr[i], oldStuff.userStuffBase.uuid == newStuff.userStuffBase.uuid {
                arr[i] = newStuff   // ✅ 替换成最新数据
                array = arr
                return true
            }
        }
        return false
    }
}

// MARK: - 物品列表测试视图
struct StuffListView: View {
    @StateObject private var stuffManager = StuffManager.shared
    @State private var selectedType: UserStuffType = .poster
    
    var body: some View {
        NavigationView {
            VStack {
                // 类型选择器
                Picker("物品类型", selection: $selectedType) {
                    ForEach(UserStuffType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon)
                            .tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 物品列表
                if stuffManager.isLoading {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = stuffManager.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("加载失败")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("重试") {
                            Task {
                                try? await stuffManager.fetchStuffList()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    let filteredItems = stuffManager.getUserStuffBases(by: selectedType)
                    
                    if filteredItems.isEmpty {
                        VStack {
                            Image(systemName: selectedType.icon)
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("暂无\(selectedType.displayName)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(filteredItems) { item in
                            StuffItemRow(item: item)
                        }
                    }
                }
            }
            .navigationTitle("物品商店")
            .onAppear {
                if stuffManager.userStuffBases.isEmpty {
                    Task {
                        try? await stuffManager.fetchStuffList()
                    }
                }
            }
        }
    }
}

// 物品行视图
struct StuffItemRow: View {
    let item: UserStuffBase
    
    var body: some View {
        HStack {
            // 图标
            AsyncImage(url: URL(string: item.icon)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: item.userStuffType.icon)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, height: 50)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label(item.userStuffType.displayName, systemImage: item.userStuffType.icon)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if let firstPrice = item.stuffPrices.first {
                        Text("\(firstPrice.amount) 金币")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // 如果是宠物且有附件，显示动画指示器
            if item.userStuffType == .pet && item.attachment != nil {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

