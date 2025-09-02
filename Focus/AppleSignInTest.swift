//
//  AppleSignInTest.swift
//  Focus
//
//  Created by Kiro on 2025/9/2.
//

import Foundation

// 测试 Apple 登录响应解码
class AppleSignInTest {
    static func testResponseDecoding() {
        let jsonString = """
        {
            "data": {
                "user": {
                    "uuid": "bc499c83-9487-4fc8-b820-94f3186c305e",
                    "account": "APPLE-BIPPlPDG",
                    "nickname": null,
                    "phone": null,
                    "channel": {
                        "uuid": "1385d076-333f-4bb1-ab40-dcc9f0d2cdf0",
                        "channelType": "APPLE",
                        "description": "11111"
                    },
                    "userSettings": {
                        "backgroundMusic": "default"
                    },
                    "userStuffs": [
                        {
                            "amount": 1,
                            "userStuffBaseId": "639a15cb-c828-4ea7-bacc-ff6e6ace41d7",
                            "createTime": null,
                            "updateTime": null
                        }
                    ],
                    "createTime": 1756469068538
                },
                "accessTokenName": "focus-pals-token",
                "accessToken": "53389f0c-7bba-4aeb-8a66-b9f774cec6c2",
                "refreshToken": "eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiJiYzQ5OWM4My05NDg3LTRmYzgtYjgyMC05NGYzMTg2YzMwNWUiLCJpYXQiOjE3NTY3NzcyNzgsImV4cCI6MTc1NzM4MjA3OH0.JGoMe_nofp38MBGs7ZFZuc3-gcAlQUwnErPzS__Hq6k8jBrM0PPOf7pZBk7USIH3AbcQJO9Inlh9l_VSVuQRJYKzbAfu7i1gBan1F5aiD5AUsIg5JocTEkieXAqPHV_WPyZoh2k_qFdrwEK_wlqv2RgvbMxB91DrRhlQOdUZ3IUjFMv74FfW0SKDEs9VB50y0IgIWj62nBpZrjhs7ry-lDsH_ptYRbRmEoK2hFgdzoaVvo-LcacmXbxEX_oMd1U_QfjmdIbHLtc2qGc6TdrDmIQzNwOp2g5s4IY0Zq3zzjJMmO1lgpBEGRosUvPe3hVQ3fzdlB5Y_XlnXU_lEPabZg"
            },
            "status": "success",
            "code": "",
            "message": "",
            "errors": null
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ 无法转换JSON字符串为Data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(AppleSignInResponse.self, from: jsonData)
            
            print("✅ JSON解码成功!")
            print("   status: \(response.status)")
            print("   data存在: \(response.data != nil)")
            
            if let data = response.data {
                print("   用户UUID: \(data.user.uuid)")
                print("   用户账号: \(data.user.account)")
                print("   访问令牌: \(data.accessToken)")
                print("   令牌名称: \(data.accessTokenName)")
            }
            
        } catch {
            print("❌ JSON解码失败: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   缺少键: \(key.stringValue)")
                    print("   上下文: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   类型不匹配: \(type)")
                    print("   上下文: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   值未找到: \(type)")
                    print("   上下文: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("   数据损坏: \(context.debugDescription)")
                @unknown default:
                    print("   未知解码错误")
                }
            }
        }
    }
}