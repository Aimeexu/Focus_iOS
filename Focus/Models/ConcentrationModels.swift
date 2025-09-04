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

//// MARK: - 专注计时响应模型
//struct ConcentrationPlan: Codable {
//    let uuid: String
//    let userId: String
//    let status: String
//    let startDate: String  // 改为字符串格式："2025-08-28 11:21:22"
//    let duration: Int
//    let createTime: String  // 改为字符串格式："2025-08-28 11:21:23"
//}

//struct ConcentrationStartResponse: Codable {
//    let data: ConcentrationStartData?
//    let status: String
//    let code: String
//    let message: String
//    let errors: String?
//}

//struct ConcentrationStartData: Codable {
//    let concentrationPlan: ConcentrationPlan
//    let stuffId: String
//    let stuffAmount: Int
//}

// MARK: - 通用API响应模型
struct BaseAPIResponse<T: Codable>: Codable {
    let data: T?
    let status: String
    let code: String
}
