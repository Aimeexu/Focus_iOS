//
//  BarChartView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct BarChartView: View {
    @State private var selectedPeriod: TimePeriod = .day
    
    enum TimePeriod: String, CaseIterable {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }
    
    // 示例数据 - 一周的专注时间（分钟）
    let weeklyData = [
        BarData(day: "Mon", value: 90),
        BarData(day: "Tue", value: 15),
        BarData(day: "Wed", value: 22),
        BarData(day: "Thu", value: 78),
        BarData(day: "Fri", value: 62),
        BarData(day: "Sat", value: 20),
        BarData(day: "Sun", value: 88)
    ]
    
    var maxValue: Int {
        weeklyData.map { $0.value }.max() ?? 100
    }
    
    var totalFocus: Int {
        weeklyData.reduce(0) { $0 + $1.value }
    }
    
    var dailyAverage: Int {
        totalFocus / weeklyData.count
    }
    
    var totalSessions: Int {
        60 // 示例数据
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 60)
            
            // 条形图区域
            VStack(spacing: 20) {
                // Y轴标签
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach([100, 80, 60, 40, 20, 0], id: \.self) { value in
                            Text("\(value)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(height: 30, alignment: .top)
                        }
                    }
                    .frame(width: 30)
                    
                    // 条形图
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(weeklyData, id: \.day) { data in
                            VStack(spacing: 8) {
                                // 条形
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green)
                                    .frame(width: 30, height: CGFloat(data.value) * 180 / CGFloat(maxValue))
                                
                                // 日期标签
                                Text(data.day)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .frame(height: 200)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // 底部统计信息
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Total Focus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(totalFocus) m")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // 分隔线
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 2, height: 40)
                
                VStack(spacing: 8) {
                    Text("Daily Focus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(dailyAverage) m")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // 分隔线
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 2, height: 40)
                
                VStack(spacing: 8) {
                    Text("Focus Sessions")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(totalSessions)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
        .background(Color(.systemBackground))
    }
}

struct BarData {
    let day: String
    let value: Int
}

#Preview {
    BarChartView()
}