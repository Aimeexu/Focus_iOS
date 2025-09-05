# 成就系统使用说明

## 概述

成就系统已经集成到 AchievementsView 页面中，可以使用登录返回的用户数据来动态生成成就。

## 主要组件

### 1. 数据模型 (StuffModels.swift)
- `AchievementLoginResponse`: 登录响应的根结构
- `AchievementUser`: 用户信息结构
- `AchievementUserStuffs`: 用户物品结构，按类型和场景分组

### 2. 成就管理器 (AchievementManager.swift)
- `AchievementManager.shared`: 单例管理器
- `parseLoginDataAndGenerateAchievements()`: 解析登录数据并生成成就
- `generateAchievementsFromCurrentUser()`: 从当前用户生成成就

### 3. 用户管理器扩展 (UserManager.swift)
- `saveAchievementLoginData()`: 保存登录数据并触发成就生成

### 4. 成就视图 (AchievementsView.swift)
- 已更新为使用 `AchievementManager`
- 自动从用户数据生成成就
- 支持动态用户信息显示

## 使用方法

### 1. 基本使用

```swift
// 在登录成功后调用
let loginJsonString = "你的登录返回JSON字符串"
UserManager.shared.saveAchievementLoginData(loginJsonString)

// AchievementsView 会自动更新显示新的成就
```

### 2. 手动生成成就

```swift
// 从当前用户数据生成成就
AchievementManager.shared.generateAchievementsFromCurrentUser()

// 或者直接解析登录数据
AchievementManager.shared.parseLoginDataAndGenerateAchievements(loginJsonString)
```

### 3. 在视图中使用

```swift
struct MyView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        // 显示成就数量
        Text("成就数量: \(achievementManager.achievements.count)")
        
        // 显示加载状态
        if achievementManager.isLoading {
            ProgressView("加载中...")
        }
    }
}
```

## 数据映射

登录返回的数据会按以下规则映射为成就：

### 宠物 (PET)
- **CalmFields** → `AchievementCategory.calmFields`
- **IceSands** → `AchievementCategory.iceSpirits`  
- **TropicalWilds** → `AchievementCategory.tropicalVibes`

### 海报 (POSTER)
- **CalmFields** → `AchievementCategory.calmFields`
- **IceSands** → `AchievementCategory.iceSpirits`
- **TropicalWilds** → `AchievementCategory.tropicalVibes`

### 成就属性
- `title`: 使用物品名称
- `description`: 使用物品描述
- `image`: 根据物品图标映射到本地图片
- `badgeNumber`: 使用物品数量
- `isUnlocked`: 有物品的设为 true

## 示例数据格式

你提供的登录数据格式已经完全支持：

```json
{
  "status": "success",
  "data": {
    "accessTokenName": "focus-pals-token",
    "refreshToken": "...",
    "accessToken": "...",
    "user": {
      "account": "APPLE-BIPPlPDG",
      "userStuffs": {
        "PET": {
          "CalmFields": [
            {
              "amount": 4,
              "userStuffBase": {
                "name": "宠物2",
                "description": "宠物2的描述",
                "icon": "pet2"
              }
            }
          ]
        },
        "POSTER": {
          "IceSands": [
            {
              "amount": 1,
              "userStuffBase": {
                "name": "海报2",
                "description": "海报2的描述",
                "icon": "poster2"
              }
            }
          ]
        }
      }
    }
  }
}
```

## 测试

可以使用以下测试视图来验证功能：

1. `AchievementTestView`: 基本功能测试
2. `AchievementUsageExample`: 完整使用示例

## 注意事项

1. 登录数据中的 `null` 值会被自动过滤
2. 成就图标会根据物品类型自动映射
3. 用户等级会根据物品数量动态计算
4. 系统会自动添加未解锁的占位符成就

## 扩展

如需添加新的成就类型或规则，可以在 `AchievementManager` 中修改 `generateAchievementsFromLoginData()` 方法。