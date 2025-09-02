//
//  StuffModels.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import Foundation
import SwiftUI

// MARK: - 物品相关数据模型

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
    let amount: Int
    let userStuffBaseId: String
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

#Preview {
    StuffListView()
}
