//
//  StatisticsView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct StatisticsView: View {
    @State private var selectedPeriod: TimePeriod = .day
    @State private var showBarChart: Bool = false
    
    enum TimePeriod: String, CaseIterable {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }
    
    // 示例数据
    let focusData = [
        FocusData(category: "Study", minutes: 10, color: Color.green),
        FocusData(category: "Work", minutes: 25, color: Color.brown.opacity(0.3)),
        FocusData(category: "Read", minutes: 20, color: Color.gray.opacity(0.5))
    ]
    
    var totalMinutes: Int {
        focusData.reduce(0) { $0 + $1.minutes }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部时间段选择和图表切换
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                        }) {
                            Text(period.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedPeriod == period ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(selectedPeriod == period ? Color.red : Color.clear)
                                .cornerRadius(selectedPeriod == period ? 8 : 0)
                        }
                    }
                }
                
                // 图表类型切换按钮
                HStack {
                    Spacer()
                    Button(action: {
                        showBarChart.toggle()
                    }) {
                        Image(systemName: showBarChart ? "chart.pie" : "chart.bar")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            // 图表内容区域
            if showBarChart {
                BarChartView()
            } else {
                VStack(spacing: 40) {
                    Spacer()
                    
                    // 饼图和标签
                    ZStack {
                        // 饼图
                        PieChartView(data: focusData, total: totalMinutes)
                            .frame(width: 220, height: 220)
                        
                        // 中心数字
                        Text("\(totalMinutes)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        // 标签定位在饼图周围
                        ForEach(Array(focusData.enumerated()), id: \.offset) { index, data in
                            PieChartLabel(
                                data: data,
                                angle: labelAngle(for: index),
                                radius: 140
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // 底部统计信息
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("Total Focus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("\(totalMinutes) m")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        // 分隔线
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 2, height: 40)
                        
                        VStack(spacing: 8) {
                            Text("Focus Sessions")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("3")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func labelAngle(for index: Int) -> Angle {
        let previousTotal = focusData.prefix(index).reduce(0) { $0 + $1.minutes }
        let currentValue = focusData[index].minutes
        let midPoint = previousTotal + currentValue / 2
        return Angle(degrees: Double(midPoint) / Double(totalMinutes) * 360 - 90)
    }
}

struct FocusData {
    let category: String
    let minutes: Int
    let color: Color
}

struct PieChartView: View {
    let data: [FocusData]
    let total: Int
    
    private let gapDegrees: Double = 3 // 每个扇形之间的间隙度数
    
    var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: item.color
                )
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let baseAngle = Double(previousTotal) / Double(total) * (360 - Double(data.count) * gapDegrees) - 90
        let gapOffset = Double(index) * gapDegrees
        return Angle(degrees: baseAngle + gapOffset)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let currentValue = data[index].minutes
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.minutes }
        let baseAngle = Double(previousTotal + currentValue) / Double(total) * (360 - Double(data.count) * gapDegrees) - 90
        let gapOffset = Double(index) * gapDegrees
        return Angle(degrees: baseAngle + gapOffset)
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                let innerRadius = radius * 0.6 // 创建环形图
                
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

struct PieChartLabel: View {
    let data: FocusData
    let angle: Angle
    let radius: CGFloat
    
    var body: some View {
        let x = cos(angle.radians) * radius
        let y = sin(angle.radians) * radius
        
        VStack(spacing: 2) {
            Text(data.category)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            Text("\(data.minutes)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .offset(x: x, y: y)
    }
}

#Preview {
    StatisticsView()
}
