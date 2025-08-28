# 专注计时动画功能实现

## 功能概述

实现了从专注计时开始接口获取 `stuffId`，然后从物品列表接口获取对应的 Lottie 动画数据并显示的完整功能。

## 实现架构

### 1. 数据模型 (`StuffModels.swift`)

```swift
// 物品列表响应结构
struct StuffListResponse: Codable {
    let status: String
    let data: StuffListData?
    let code: String
    let message: String
    let errors: String?
}

// 用户物品基础信息
struct UserStuffBase: Codable, Identifiable {
    let uuid: String
    let name: String
    let description: String
    let icon: String
    let userStuffType: UserStuffType
    let stuffPrices: [StuffPrice]
    let attachment: StuffAttachment?  // 包含Lottie动画URL
}

// 物品附件信息（Lottie动画数据）
struct StuffAttachment: Codable {
    let child: String?   // 幼体动画URL
    let adult: String?   // 成体动画URL
    let sleep: String?   // 睡眠动画URL
}
```

### 2. 专注计时服务 (`ConcentrationService.swift`)

核心服务类，负责：
- 开始专注计时并获取 `stuffId`
- 根据 `stuffId` 查找对应的物品和动画
- 管理专注计时状态
- 结束专注计时

```swift
@MainActor
class ConcentrationService: ObservableObject {
    // 开始专注计时并获取动画
    func startConcentrationWithAnimation(duration: Int) async throws -> (ConcentrationPlan, String?)
    
    // 根据stuffId获取动画URL
    private func getAnimationURL(for stuffId: String) async throws -> String?
    
    // 结束专注计时
    func endConcentration() async throws
}
```

### 3. 动画管理器 (`LottieAnimationView.swift`)

包含：
- `NetworkLottieView`: 从网络URL加载Lottie动画的UIViewRepresentable
- `ConcentrationAnimationView`: 专注计时动画显示组件
- `LottieAnimationManager`: 动画状态管理器

```swift
// 网络Lottie动画视图
struct NetworkLottieView: UIViewRepresentable {
    let animationURL: String
    // 从网络下载并播放Lottie动画
}

// 专注计时动画视图
struct ConcentrationAnimationView: View {
    // 显示当前的专注计时动画，包含加载状态
}
```

### 4. 网络接口扩展 (`NetworkManager.swift`)

```swift
extension NetworkManager {
    /// 获取用户物品基础列表
    func getUserStuffBaseList() async throws -> StuffListResponse
}
```

## 工作流程

### 开始专注计时流程

1. **用户点击开始按钮**
   ```swift
   // HomeView.swift
   private func startTimer() {
       // 调用专注计时服务
       let (plan, animationURL) = try await concentrationService.startConcentrationWithAnimation(duration: selectedMinutes)
   }
   ```

2. **专注计时服务处理**
   ```swift
   // ConcentrationService.swift
   func startConcentrationWithAnimation(duration: Int) async throws -> (ConcentrationPlan, String?) {
       // 1. 调用开始专注计时接口
       let startResponse = try await NetworkManager.shared.startConcentration(duration: duration)
       
       // 2. 获取返回的stuffId
       let stuffId = startResponse.data.stuffId
       
       // 3. 根据stuffId查找对应的动画
       let animationURL = try await getAnimationURL(for: stuffId)
       
       return (plan, animationURL)
   }
   ```

3. **查找动画URL**
   ```swift
   private func getAnimationURL(for stuffId: String) async throws -> String? {
       // 1. 获取物品列表
       let stuffResponse = try await NetworkManager.shared.getUserStuffBaseList()
       
       // 2. 查找对应的物品
       let targetStuff = stuffResponse.data.userStuffBases.first { $0.uuid == stuffId }
       
       // 3. 获取动画URL
       return targetStuff?.attachment?.adult ?? targetStuff?.attachment?.child
   }
   ```

4. **显示动画**
   ```swift
   // HomeView.swift - 在计时器运行时显示
   ConcentrationAnimationView(size: CGSize(width: 200, height: 200))
   ```

### 动画显示流程

1. **ConcentrationAnimationView** 监听 `LottieAnimationManager.currentAnimationURL`
2. 当URL更新时，**NetworkLottieView** 下载并解析Lottie JSON
3. 创建 `LottieAnimationView` 并开始播放动画

## API数据示例

### 专注计时开始接口响应
```json
{
  "status": "success",
  "data": {
    "concentrationPlan": {
      "uuid": "plan-123",
      "userId": "user-456",
      "status": "active",
      "startDate": "2025-08-28 11:21:22",
      "duration": 25
    },
    "stuffId": "639a15cb-c828-4ea7-bacc-ff6e6ace41d7",
    "stuffAmount": 1
  }
}
```

### 物品列表接口响应
```json
{
  "status": "success",
  "data": {
    "userStuffBases": [
      {
        "uuid": "639a15cb-c828-4ea7-bacc-ff6e6ace41d7",
        "name": "宠物2",
        "description": "宠物2的描述",
        "userStuffType": "PET",
        "attachment": {
          "child": "http://www.cdbolv.com/assets/file/fp/owl_child.json",
          "adult": "http://www.cdbolv.com/assets/file/fp/owl_adult.json",
          "sleep": "http://www.cdbolv.com/assets/file/fp/owl_sleep.json"
        }
      }
    ]
  }
}
```

## 测试功能

在设置页面的调试工具中提供了以下测试功能：

1. **物品列表测试** - 测试物品列表API和数据解析
2. **Lottie动画测试** - 测试网络Lottie动画加载和播放
3. **JSON解析测试** - 测试数据模型的JSON解析功能

## 使用方法

1. 确保用户已登录
2. 点击开始专注计时按钮
3. 系统会自动：
   - 调用开始专注计时接口获取 `stuffId`
   - 根据 `stuffId` 查找对应的物品和动画
   - 下载并播放Lottie动画
4. 专注计时结束时，动画会自动清除

## 错误处理

- 网络请求失败时会有相应的错误日志
- 动画加载失败时显示占位符
- 找不到对应物品时显示默认状态
- 所有错误都不会阻断专注计时的基本功能

## 性能优化

- 动画数据会缓存在内存中
- 支持异步加载，不阻塞UI
- 计时结束时及时清理动画资源