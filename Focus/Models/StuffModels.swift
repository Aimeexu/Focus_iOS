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
}

struct AchievementPetStuffs: Codable {
    let tropicalWilds: [AchievementUserStuff?]?
    let calmFields: [AchievementUserStuff?]?
    let iceSands: [AchievementUserStuff?]?
    
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
    let tropicalWilds: [AchievementUserStuff?]?
    let calmFields: [AchievementUserStuff?]?
    let iceSands: [AchievementUserStuff?]?
    
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
    let errors: String?
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
    let errors: String?
}

struct ConcentrationEndData: Codable {
    let userStuff: ConcentrationUserStuff
}

struct ConcentrationUserStuff: Codable {
    let uuid: String
    let amount: Int
    let userStuffBase: UserStuffBase
    let createTime: String?
    let updateTime: String?
}

// 物品列表请求响应
struct StuffListResponse: Codable {
    let status: String
    let data: StuffListData?
    let code: String
    let message: String
    let errors: String?
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
            return "幼体"
        case .adult:
            return "成体"
        case .sleep:
            return "睡眠"
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
    
    // 测试解析结束响应方法
    func testParseEndResponse() {
        let testJson = """
        {"data":{"userStuff":{"amount":3,"uuid":"07ad8e4b-829b-46d2-95ba-6b64ec7a3766","userStuffBase":{"uuid":"639a15cb-c828-4ea7-bacc-ff6e6ace41d7","userStuffType":"PET","userStuffScene":"CalmFields","icon":"pet2","name":"宠物2","description":"宠物2的描述","attachment":{"child":"http://www.cdbolv.com/assets/file/fp/owl_child.json","adult":"http://www.cdbolv.com/assets/file/fp/owl_adult.json","sleep":"http://www.cdbolv.com/assets/file/fp/owl_sleep.json"},"stuffPrices":[{"stuffId":"94164b90-7e14-4541-b9b4-599345abf8a0","amount":1}]},"createTime":"2025-09-02 11:17:57","updateTime":"2025-09-05 11:56:39"}},"status":"success","code":"","message":"","errors":null}
        """
        
        print("🧪 开始测试结束响应解析...")
        if let response = parseConcentrationEndResponse(testJson) {
            print("🎉 测试成功！")
            if let data = response.data {
                let userStuff = data.userStuff
                print("📊 详细信息:")
                print("   - 物品UUID: \(userStuff.uuid)")
                print("   - 获得数量: \(userStuff.amount)")
                print("   - 物品名称: \(userStuff.userStuffBase.name)")
                print("   - 物品类型: \(userStuff.userStuffBase.userStuffType)")
                print("   - 物品场景: \(userStuff.userStuffBase.userStuffScene ?? "无")")
                print("   - 创建时间: \(userStuff.createTime ?? "无")")
                print("   - 更新时间: \(userStuff.updateTime ?? "无")")
                
                if let attachment = userStuff.userStuffBase.attachment {
                    print("   - 动画文件:")
                    if let child = attachment.child {
                        print("     * 幼体: \(child)")
                    }
                    if let adult = attachment.adult {
                        print("     * 成体: \(adult)")
                    }
                    if let sleep = attachment.sleep {
                        print("     * 睡眠: \(sleep)")
                    }
                }
            }
        } else {
            print("❌ 测试失败")
        }
    }
    
    // 测试解析方法
    func testParseStartResponse() {
        let testJson = """
        {"data":{"concentrationPlan":{"uuid":"d52023b0-2fef-49c6-bf9e-6421ef483f23","userId":"11da0533-0cdf-415f-8f12-5ca0b9a2664b","status":"STARTED","startDate":"2025-09-04 15:49:12","duration":25,"createTime":"2025-09-04 07:49:14"},"currentDropStuff":{"uuid":"639a15cb-c828-4ea7-bacc-ff6e6ace41d7","userStuffType":"PET","userStuffScene":"CalmFields","icon":"pet2","name":"宠物2","description":"宠物2的描述","attachment":{"child":"http://www.cdbolv.com/assets/file/fp/owl_child.json","adult":"http://www.cdbolv.com/assets/file/fp/owl_adult.json","sleep":"http://www.cdbolv.com/assets/file/fp/owl_sleep.json"},"stuffPrices":[{"stuffId":"94164b90-7e14-4541-b9b4-599345abf8a0","amount":1}]},"stuffDropAmount":1},"status":"success","code":"","message":"","errors":null}
        """
        
        print("🧪 开始测试解析...")
        if let response = parseConcentrationStartResponse(testJson) {
            print("🎉 测试成功！")
            if let data = response.data {
                print("📊 详细信息:")
                print("   - 计划状态: \(data.concentrationPlan.status)")
                print("   - 开始时间: \(data.concentrationPlan.startDate)")
                print("   - 持续时间: \(data.concentrationPlan.duration) 分钟")
                print("   - 掉落物品: \(data.currentDropStuff.name)")
                print("   - 物品类型: \(data.currentDropStuff.userStuffType)")
                print("   - 掉落数量: \(data.stuffDropAmount)")
                
                if let attachment = data.currentDropStuff.attachment {
                    print("   - 动画文件:")
                    if let child = attachment.child {
                        print("     * 幼体: \(child)")
                    }
                    if let adult = attachment.adult {
                        print("     * 成体: \(adult)")
                    }
                    if let sleep = attachment.sleep {
                        print("     * 睡眠: \(sleep)")
                    }
                }
            }
        } else {
            print("❌ 测试失败")
        }
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

