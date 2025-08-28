//
//  DateUtils.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/28.
//

import Foundation

// 日期工具类
class DateUtils {
    
    // 服务器响应中的日期格式
    static let serverDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current // 根据需要调整时区
        return formatter
    }()
    
    // 显示用的日期格式
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    /// 将服务器返回的日期字符串转换为Date对象
    /// - Parameter dateString: 服务器返回的日期字符串，格式："yyyy-MM-dd HH:mm:ss"
    /// - Returns: Date对象，如果解析失败返回nil
    static func parseServerDate(_ dateString: String) -> Date? {
        return serverDateFormatter.date(from: dateString)
    }
    
    /// 将Date对象转换为显示用的字符串
    /// - Parameter date: Date对象
    /// - Returns: 格式化后的日期字符串
    static func formatForDisplay(_ date: Date) -> String {
        return displayDateFormatter.string(from: date)
    }
    
    /// 将服务器日期字符串直接转换为显示字符串
    /// - Parameter dateString: 服务器返回的日期字符串
    /// - Returns: 显示用的日期字符串，如果解析失败返回原字符串
    static func formatServerDateForDisplay(_ dateString: String) -> String {
        guard let date = parseServerDate(dateString) else {
            return dateString
        }
        return formatForDisplay(date)
    }
    
    /// 计算从指定时间到现在的时间差
    /// - Parameter dateString: 服务器返回的日期字符串
    /// - Returns: 时间差描述，如"2分钟前"
    static func timeAgoSince(_ dateString: String) -> String {
        guard let date = parseServerDate(dateString) else {
            return "未知时间"
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "刚刚"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)分钟前"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)小时前"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)天前"
        }
    }
    
    /// 获取当前时间的毫秒时间戳（用于发送请求）
    /// - Returns: 毫秒时间戳
    static func getCurrentTimestamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    /// 将毫秒时间戳转换为Date对象
    /// - Parameter timestamp: 毫秒时间戳
    /// - Returns: Date对象
    static func dateFromTimestamp(_ timestamp: Int64) -> Date {
        return Date(timeIntervalSince1970: Double(timestamp) / 1000.0)
    }
}