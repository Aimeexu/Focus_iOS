//
//  PosterModels.swift
//  Focus
//
//  Created by Jessica mini on 2025/9/11.
//


// MARK: - Poster Exchange Check Response
struct PosterExchangeCheckResponse: Codable {
    let code: String
    let data: PosterExchangeCheckData
    let status: String
    let message: String
    let errors: String?   // 可能是 null，所以用可选

    enum CodingKeys: String, CodingKey {
        case code, data, status, message, errors
    }
}

// MARK: - Data 部分
struct PosterExchangeCheckData: Codable {
    let canExchange: Bool
}


// MARK: - 顶层响应
struct UserPosterStuffResponse: Codable {
    let status: String
    let errors: String?
    let code: String
    let message: String
    let data: UserPosterStuffData
}

// MARK: - Data
struct UserPosterStuffData: Codable {
    let userStuffMap: AchievementUserStuffs
}
