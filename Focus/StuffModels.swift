//
//  StuffModels.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import Foundation

// MARK: - 物品相关数据模型

// 物品列表请求响应
struct StuffListResponse: Codable {
    let status: String
    let data: [StuffItem]?
    let code: String
    let message: String
    let errors: String?
}

// 物品基础信息
struct StuffItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String?
    let category: String?
    let rarity: String?
    let value: Int?
    let isActive: Bool
    let createTime: String
    let updateTime: String
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case description
        case icon
        case category
        case rarity
        case value
        case isActive = "is_active"
        case createTime = "create_time"
        case updateTime = "update_time"
    }
}

// 物品管理器
class StuffManager: ObservableObject {
    static let shared = StuffManager()
    
    @Published var stuffItems: [StuffItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // 获取物品列表
    func fetchStuffList() async throws -> [StuffItem] {
        let baseURL = "http://ds2.tapgame.cn"
        
        do {
            let response: StuffListResponse = try await NetworkManager.shared.get(
                url: "\(baseURL)/app/user/stuff/base/list",
                headers: NetworkManager.shared.getAuthHeaders(),
                responseType: StuffListResponse.self
            )
            
            if response.status == "success", let items = response.data {
                await MainActor.run {
                    self.stuffItems = items
                    self.errorMessage = nil
                }
                return items
            } else {
                let error = NetworkError.networkError(response.message.isEmpty ? "获取物品列表失败" : response.message)
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
                throw error
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // 根据ID查找物品
    func getStuffItem(by id: String) -> StuffItem? {
        return stuffItems.first { $0.id == id }
    }
    
    // 清除数据
    func clearData() {
        stuffItems = []
        errorMessage = nil
    }
}