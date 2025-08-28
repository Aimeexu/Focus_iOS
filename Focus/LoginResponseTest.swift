//
//  LoginResponseTest.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/28.
//

import Foundation

// 测试登录响应解析
class LoginResponseTest {
    static func testResponseParsing() {
        let jsonString = """
        {
            "status": "success",
            "data": {
                "accessTokenName": "focus-pals-token",
                "refreshToken": "eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiI2MGM4NzRiMC0wMzM3LTRjNjctODk3YS1iYTI5NzZlNGRjYjgiLCJpYXQiOjE3NTYzNzUxNzgsImV4cCI6MTc1Njk3OTk3OH0.C3_FN-cxS8V0WnZmDle9rYjIYI8IwCpTxG7ePFfRyuT-Iy3xKpB7NWamtHiPbiGsksEAEGlN0kARUwaAH0gkZPOwOiNh8ocB-i8Hrkn3MlpLdwSvfgPcQtmi7eIrwcck3hgUUjlFri-jI46VCkLZRk-GJ-HwZiL5247jm3DNvMgIOmGyOCCiORWuLSKNGkySbwWEqwZBRRsgXHHmXMl7faT_LmzzUFLHEv-LS2kKYwTEfUag7vUEhA-hEYbK2yEFptxtEH2yO4raMeiDRY3j6Vn8iugcI2vU_W_lsy02ygdyHeyiZ91FUv1qgYqI8SHCH_Zm_YmIw9mLlQ9gBteCVA",
                "accessToken": "28dc80ca-a874-46aa-816b-27d1760fae94",
                "user": {
                    "account": "测试1",
                    "phone": null,
                    "channel": {
                        "channelType": null,
                        "description": "11111",
                        "uuid": "1385d076-333f-4bb1-ab40-dcc9f0d2cdf0"
                    },
                    "nickname": "支晨阳",
                    "userSettings": {
                        "backgroundMusic": "default"
                    },
                    "uuid": "60c874b0-0337-4c67-897a-ba2976e4dcb8",
                    "userStuffs": [
                        {
                            "amount": 3,
                            "createTime": "2025-08-15 21:04:47",
                            "userStuffBaseId": "3e5b0426-4c91-4471-bfdf-33a67006f908",
                            "updateTime": "2025-08-15 21:04:47"
                        }
                    ],
                    "createTime": 1754782484902
                }
            },
            "code": "",
            "message": "",
            "errors": null
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ 无法创建JSON数据")
            return
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
            print("✅ 登录响应解析成功")
            print("状态: \(loginResponse.status)")
            print("访问令牌: \(loginResponse.data?.accessToken ?? "无")")
            print("用户昵称: \(loginResponse.data?.user.nickname ?? "无")")
            print("用户UUID: \(loginResponse.data?.user.uuid ?? "无")")
        } catch {
            print("❌ 登录响应解析失败: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("缺少键: \(key.stringValue), 路径: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("类型不匹配: \(type), 路径: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("值未找到: \(type), 路径: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("数据损坏: \(context)")
                @unknown default:
                    print("未知解码错误")
                }
            }
        }
    }
}