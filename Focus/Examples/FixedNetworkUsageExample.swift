//
//  FixedNetworkUsageExample.swift
//  Focus
//
//  修复后的NetworkManager使用示例
//

import SwiftUI
import SwiftyJSON

struct FixedNetworkUsageExample: View {
    @State private var stuffItems: [UserStuffBase] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var debugOutput = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 测试按钮组
                VStack(spacing: 8) {
                    Button("🔧 快速测试") {
                        quickTest()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("📦 获取物品列表 (SwiftyJSON)") {
                        fetchStuffWithSwiftyJSON()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("📦 获取物品列表 (Codable)") {
                        fetchStuffWithCodable()
                    }
                    .buttonStyle(.bordered)
                }
                .disabled(isLoading)
                
                // 状态显示
                if isLoading {
                    ProgressView("加载中...")
                        .padding()
                }
                
                if let errorMessage = errorMessage {
                    Text("错误: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 物品列表
                if !stuffItems.isEmpty {
                    List(stuffItems) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.userStuffType.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 调试输出
                if !debugOutput.isEmpty {
                    ScrollView {
                        Text(debugOutput)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                }
            }
            .padding()
            .navigationTitle("网络测试")
        }
    }
    
    private func quickTest() {
        isLoading = true
        errorMessage = nil
        debugOutput = "开始快速测试...\n"
        
//        Task {
//            await NetworkManagerTest.shared.quickTest()
//            
//            await MainActor.run {
//                isLoading = false
//                debugOutput += "测试完成，请查看控制台输出"
//            }
//        }
    }
    
    private func fetchStuffWithSwiftyJSON() {
        isLoading = true
        errorMessage = nil
        stuffItems = []
        debugOutput = "使用SwiftyJSON获取物品列表...\n"
        
        Task {
            do {
                let json = try await NetworkManager.shared.getUserStuffBaseListWithJSON()
                
                await MainActor.run {
                    debugOutput += "✅ SwiftyJSON请求成功\n"
                    debugOutput += "状态: \(json["status"].stringValue)\n"
                    debugOutput += "物品数量: \(json["data"]["userStuffBases"].arrayValue.count)\n"
                }
                
                // 手动解析为模型
                let items = parseStuffItemsFromJSON(json)
                
                await MainActor.run {
                    self.stuffItems = items
                    self.isLoading = false
                    debugOutput += "成功解析 \(items.count) 个物品\n"
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    debugOutput += "❌ SwiftyJSON请求失败: \(error)\n"
                }
            }
        }
    }
    
    private func fetchStuffWithCodable() {
        isLoading = true
        errorMessage = nil
        stuffItems = []
        debugOutput = "使用Codable获取物品列表...\n"
        
        Task {
            do {
                let response = try await NetworkManager.shared.getUserStuffBaseList()
                
                await MainActor.run {
                    debugOutput += "✅ Codable请求成功\n"
                    debugOutput += "状态: \(response.status)\n"
                    
                    if let data = response.data {
                        self.stuffItems = data.userStuffBases
                        debugOutput += "成功获取 \(data.userStuffBases.count) 个物品\n"
                    }
                    
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    debugOutput += "❌ Codable请求失败: \(error)\n"
                }
            }
        }
    }
    
    private func parseStuffItemsFromJSON(_ json: JSON) -> [UserStuffBase] {
        let itemsArray = json["data"]["userStuffBases"].arrayValue
        
        return itemsArray.compactMap { itemJson -> UserStuffBase? in
            guard let uuid = itemJson["uuid"].string,
                  let name = itemJson["name"].string,
                  let description = itemJson["description"].string,
                  let icon = itemJson["icon"].string,
                  let typeString = itemJson["userStuffType"].string,
                  let type = UserStuffType(rawValue: typeString) else {
                return nil
            }
            
            // 解析价格
            let prices = itemJson["stuffPrices"].arrayValue.compactMap { priceJson -> StuffPrice? in
                guard let stuffId = priceJson["stuffId"].string else { return nil }
                let amount = priceJson["amount"].intValue
                return StuffPrice(stuffId: stuffId, amount: amount)
            }
            
            // 解析附件
            var attachment: StuffAttachment? = nil
            if itemJson["attachment"].exists() && itemJson["attachment"].type != .null {
                let child = itemJson["attachment"]["child"].string
                let adult = itemJson["attachment"]["adult"].string
                let sleep = itemJson["attachment"]["sleep"].string
                attachment = StuffAttachment(child: child, adult: adult, sleep: sleep)
            }
            
            return UserStuffBase(
                uuid: uuid,
                name: name,
                description: description,
                icon: icon,
                userStuffType: type,
                stuffPrices: prices,
                attachment: attachment
            )
        }
    }
}

#Preview {
    FixedNetworkUsageExample()
}
