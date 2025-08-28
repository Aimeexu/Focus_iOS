//
//  ConcentrationService.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import Foundation
import SwiftUI

// MARK: - 专注计时服务
@MainActor
class ConcentrationService: ObservableObject {
    static let shared = ConcentrationService()
    
    @Published var currentPlan: ConcentrationPlan?
    @Published var currentStuffId: String?
    @Published var currentLottieAnimationURL: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - 开始专注计时并获取动画
    func startConcentrationWithAnimation(duration: Int) async throws -> (ConcentrationPlan, String?) {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. 开始专注计时
            print("🎯 开始专注计时，时长: \(duration) 分钟")
            let startResponse = try await NetworkManager.shared.startConcentration(duration: duration)
            
            guard startResponse.status == "success",
                  let data = startResponse.data else {
                throw NetworkError.networkError(startResponse.message.isEmpty ? "开始专注计时失败" : startResponse.message)
            }
            
            let plan = data.concentrationPlan
            let stuffId = data.stuffId
            
            print("✅ 专注计时开始成功")
            print("📋 计划ID: \(plan.uuid)")
            print("🎁 物品ID: \(stuffId)")
            print("💰 物品数量: \(data.stuffAmount)")
            
            // 2. 获取物品列表并查找对应的动画
            let animationURL = try await getAnimationURL(for: stuffId)
            
            // 3. 更新状态
            currentPlan = plan
            currentStuffId = stuffId
            currentLottieAnimationURL = animationURL
            isLoading = false
            
            return (plan, animationURL)
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ 开始专注计时失败: \(error)")
            throw error
        }
    }
    
    // MARK: - 根据stuffId获取动画URL
    private func getAnimationURL(for stuffId: String) async throws -> String? {
        print("🔍 查找物品ID \(stuffId) 对应的动画...")
        
        // 获取物品列表
        let stuffResponse = try await NetworkManager.shared.getUserStuffBaseList()
        
        guard stuffResponse.status == "success",
              let data = stuffResponse.data else {
            print("⚠️ 获取物品列表失败: \(stuffResponse.message)")
            return nil
        }
        
        // 查找对应的物品
        let targetStuff = data.userStuffBases.first { $0.uuid == stuffId }
        
        guard let stuff = targetStuff else {
            print("⚠️ 未找到ID为 \(stuffId) 的物品")
            return nil
        }
        
        print("🎁 找到物品: \(stuff.name) (\(stuff.userStuffType.displayName))")
        
        // 检查是否有附件（动画数据）
        guard let attachment = stuff.attachment else {
            print("ℹ️ 物品 \(stuff.name) 没有附件数据")
            return nil
        }
        
        // 根据物品类型选择合适的动画
        let animationURL = selectAnimationURL(from: attachment, for: stuff)
        
        if let url = animationURL {
            print("🎬 选择动画URL: \(url)")
        } else {
            print("⚠️ 物品 \(stuff.name) 没有可用的动画")
        }
        
        return animationURL
    }
    
    // MARK: - 选择合适的动画URL
    private func selectAnimationURL(from attachment: StuffAttachment, for stuff: UserStuffBase) -> String? {
        // 根据物品类型和当前状态选择动画
        switch stuff.userStuffType {
        case .pet:
            // 对于宠物，优先选择成体动画，其次是幼体，最后是睡眠
            return attachment.adult ?? attachment.child ?? attachment.sleep
        default:
            // 对于其他类型，选择第一个可用的动画
            return attachment.allAnimationURLs.first
        }
    }
    
    // MARK: - 结束专注计时
    func endConcentration() async throws {
        guard let planId = currentPlan?.uuid else {
            throw NetworkError.networkError("没有正在进行的专注计时")
        }
        
        isLoading = true
        
        do {
            print("🏁 结束专注计时，计划ID: \(planId)")
            let response = try await NetworkManager.shared.endConcentration(planId: planId)
            
            if response.status == "success" {
                print("✅ 专注计时结束成功")
                // 清除当前状态
                currentPlan = nil
                currentStuffId = nil
                currentLottieAnimationURL = nil
            } else {
//                print("⚠️ 结束专注计时失败: \(response.message ?? "未知错误")")
            }
            
            isLoading = false
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ 结束专注计时失败: \(error)")
            throw error
        }
    }
    
    // MARK: - 获取当前动画状态
    func getCurrentAnimationState() -> PetState {
        // 这里可以根据专注计时的进度或其他逻辑来决定动画状态
        // 暂时返回成体状态
        return .adult
    }
    
    // MARK: - 根据状态获取动画URL
    func getAnimationURL(for state: PetState) -> String? {
        guard let stuffId = currentStuffId else { return nil }
        
        // 这里可以从缓存的物品数据中获取
        // 暂时返回当前的动画URL
        return currentLottieAnimationURL
    }
    
    // MARK: - 清除状态
    func clearState() {
        currentPlan = nil
        currentStuffId = nil
        currentLottieAnimationURL = nil
        errorMessage = nil
    }
}

// MARK: - 动画管理器
class LottieAnimationManager: ObservableObject {
    static let shared = LottieAnimationManager()
    
    @Published var currentAnimationURL: String?
    @Published var isAnimationLoading = false
    
    private init() {}
    
    // MARK: - 加载动画
    func loadAnimation(from url: String) async {
        await MainActor.run {
            isAnimationLoading = true
            currentAnimationURL = url
        }
        
        // 这里可以添加预加载逻辑
        print("🎬 开始加载动画: \(url)")
        
        // 模拟加载时间
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        
        await MainActor.run {
            isAnimationLoading = false
        }
        
        print("✅ 动画加载完成")
    }
    
    // MARK: - 清除动画
    func clearAnimation() {
        currentAnimationURL = nil
        isAnimationLoading = false
    }
}
