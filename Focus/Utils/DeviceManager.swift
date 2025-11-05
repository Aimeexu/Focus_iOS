//
//  DeviceManager.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import Foundation
import UIKit

class DeviceManager {
    static let shared = DeviceManager()
    
    private init() {}
    
    // 获取设备唯一标识符
    func getDeviceId() -> String {
        // 首先尝试从UserDefaults获取已保存的deviceId
        if let savedDeviceId = UserDefaults.standard.string(forKey: "device_id"), !savedDeviceId.isEmpty {
            return savedDeviceId
        }
        
        // 如果没有保存的deviceId，生成一个新的
        let deviceId = generateDeviceId()
        
        // 保存到UserDefaults
        UserDefaults.standard.set(deviceId, forKey: "device_id")
        
        return deviceId
    }
    
    // 生成设备ID
    private func generateDeviceId() -> String {
        // 方法1：使用identifierForVendor（推荐）
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            return vendorId
        }
        
        // 方法2：如果identifierForVendor不可用，生成一个UUID
        let uuid = UUID().uuidString
        return uuid
    }
    
    // 获取设备信息
    func getDeviceInfo() -> [String: String] {
        return [
            "deviceId": getDeviceId(),
            "deviceModel": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "deviceName": UIDevice.current.name
        ]
    }
    
    // 重置设备ID（用于测试或特殊情况）
    func resetDeviceId() {
        UserDefaults.standard.removeObject(forKey: "device_id")
    }
}