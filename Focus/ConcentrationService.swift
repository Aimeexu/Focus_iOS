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
    @Published var currentAnimationState: PetState = .child
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAnimationSwitching = false
    
    // 缓存当前物品的所有动画URL
    var currentStuffAttachment: StuffAttachment?
    
    private init() {}
    
    // MARK: - 开始专注计时并获取动画
    func startConcentrationWithAnimation(duration: Int) async throws -> (ConcentrationPlan, String?) {
        isLoading = true
        errorMessage = nil
        
        print("🎯 开始专注计时服务，当前状态:")
        print("   - currentPlan: \(currentPlan?.uuid ?? "nil")")
        print("   - currentStuffId: \(currentStuffId ?? "nil")")
        
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
            
            // 3. 更新状态 - 开始时使用child动画
            currentPlan = plan
            currentStuffId = stuffId
            currentAnimationState = .child
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
        
        // 缓存附件数据，用于后续状态切换
        currentStuffAttachment = attachment
        
        // 开始时使用child动画
        let animationURL = attachment.child ?? attachment.adult ?? attachment.sleep
        
        if let url = animationURL {
            print("🎬 选择开始动画URL (child): \(url)")
        } else {
            print("⚠️ 物品 \(stuff.name) 没有可用的动画")
        }
        
        return animationURL
    }
    
    // MARK: - 切换动画状态
    func switchToAdultAnimation() {
        switchToAnimation(state: .adult)
    }
    
    func switchToChildAnimation() {
        switchToAnimation(state: .child)
    }
    
    func switchToSleepAnimation() {
        switchToAnimation(state: .sleep)
    }
    
    private func switchToAnimation(state: PetState) {
        guard let attachment = currentStuffAttachment else {
            print("⚠️ 没有缓存的附件数据")
            return
        }
        
        isAnimationSwitching = true
        currentAnimationState = state
        
        let animationURL: String?
        switch state {
        case .child:
            animationURL = attachment.child
        case .adult:
            animationURL = attachment.adult
        case .sleep:
            animationURL = attachment.sleep
        }
        
        if let url = animationURL {
            currentLottieAnimationURL = url
            print("🎬 切换到\(state.displayName)动画: \(url)")
        } else {
            // 如果没有对应动画，尝试使用其他动画
            let fallbackURL = attachment.child ?? attachment.adult ?? attachment.sleep
            if let fallbackURL = fallbackURL {
                currentLottieAnimationURL = fallbackURL
                print("⚠️ 没有\(state.displayName)动画，使用备用动画")
            } else {
                print("⚠️ 没有可用的动画")
            }
        }
        
        // 延迟重置切换状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isAnimationSwitching = false
        }
    }
    
    // MARK: - 根据状态获取动画URL
    func getAnimationURL(for state: PetState) -> String? {
        guard let attachment = currentStuffAttachment else { return nil }
        
        switch state {
        case .child:
            return attachment.child
        case .adult:
            return attachment.adult
        case .sleep:
            return attachment.sleep
        }
    }
    
    // MARK: - 安全结束专注计时（不抛出错误）
    func safeEndConcentration() async {
        do {
            try await endConcentration()
        } catch {
            print("⚠️ 安全结束专注计时时出现错误，但已清理状态: \(error)")
        }
    }
    
    // MARK: - 结束专注计时
    func endConcentration() async throws {
        guard let planId = currentPlan?.uuid else {
            // 如果没有当前计划，直接清理状态并返回
            print("⚠️ 没有正在进行的专注计时，清理本地状态")
            clearState()
            return
        }
        
        isLoading = true
        
        do {
            print("🏁 结束专注计时，计划ID: \(planId)")
            let response = try await NetworkManager.shared.endConcentration(id: planId)
            
            if response.status == "success" {
                print("✅ 专注计时结束成功")
            } else {
//                print("⚠️ 结束专注计时API返回失败: \(response.message)")
            }
            
            // 无论API调用成功与否，都清除本地状态
            clearState()
            isLoading = false
            
        } catch {
            // 即使API调用失败，也要清除本地状态
            clearState()
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ 结束专注计时失败: \(error)")
            // 不再抛出错误，因为本地状态已经清理
        }
    }
    

    
    // MARK: - 清除状态
    func clearState() {
        currentPlan = nil
        currentStuffId = nil
        currentLottieAnimationURL = nil
        currentStuffAttachment = nil
        currentAnimationState = .child
        isAnimationSwitching = false
        errorMessage = nil
        print("🧹 专注计时状态已清除")
    }
    
    // MARK: - 检查当前状态
    func printCurrentState() {
        print("📊 当前专注计时状态:")
        print("   - currentPlan: \(currentPlan?.uuid ?? "nil")")
        print("   - currentStuffId: \(currentStuffId ?? "nil")")
        print("   - currentAnimationState: \(currentAnimationState)")
        print("   - isLoading: \(isLoading)")
        print("   - isAnimationSwitching: \(isAnimationSwitching)")
        print("   - hasAnimationURL: \(currentLottieAnimationURL != nil)")
        print("   - hasAttachment: \(currentStuffAttachment != nil)")
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
