//
//  ConcentrationModels.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/28.
//

import Foundation

// MARK: - 专注计时请求模型
struct ConcentrationStartRequest: Codable {
    let startDate: String
    let duration: Int
}

// MARK: - 专注计时响应模型
struct ConcentrationPlan: Codable {
    let uuid: String
    let userId: String
    let status: String
    let startDate: Int64
    let duration: Int
    let createTime: Int64
}

struct ConcentrationStartResponse: Codable {
    let data: ConcentrationStartData
    let status: String
    let code: String
}

struct ConcentrationStartData: Codable {
    let concentrationPlan: ConcentrationPlan
    let stuffId: String
    let stuffAmount: Int
}

// MARK: - 通用API响应模型
struct BaseAPIResponse<T: Codable>: Codable {
    let data: T?
    let status: String
    let code: String
}