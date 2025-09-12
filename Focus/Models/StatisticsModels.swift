//
//  StaticModels.swift
//  Focus
//
//  Created by Jessica mini on 2025/9/11.
//

// MARK: - Concentration Statistics Response
struct ConcentrationStatisticsResponse: Codable {
    let status: String
    let data: ConcentrationStatisticsData
    let errors: String?
    let message: String
    let code: String
}

// MARK: - Data 部分
struct ConcentrationStatisticsData: Codable {
    let totalDuration: Int                  // 总专注时长
    let dataByDate: [ConcentrationDataByDate]   // 按日期统计
    let durationByTag: [String: Int]       // 按标签统计
    let dailyFocusTime: Int                // 日均专注时间
    let totalSession: Int                  // 总专注次数
}

// MARK: - 单日统计
struct ConcentrationDataByDate: Codable {
    let date: String                       // 日期
    let durationTotal: Int                 // 当天总时长
}
