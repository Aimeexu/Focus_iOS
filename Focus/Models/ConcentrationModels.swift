//
//  ConcentrationModels.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/28.
//

import Foundation

// MARK: - 专注计时请求模型
struct ConcentrationStartRequest: Codable {
    let operateDate: String
    let timeZone: String
    let duration: Int
    let concentrationPlanTag: String
}

struct ConcentrationFinishRequest: Codable {
    let operateDate: String
    let timeZone: String
    let id: String
}

// MARK: - 通用API响应模型
struct BaseAPIResponse<T: Codable>: Codable {
    let data: T?
    let status: String
    let code: String
}
