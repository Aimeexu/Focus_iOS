//
//  DeviceInfoTestView.swift
//  Focus
//
//  Created by Kiro on 2025/8/28.
//

import SwiftUI

struct DeviceInfoTestView: View {
    @State private var deviceInfo: [String: String] = [:]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("设备信息测试")
                    .font(.largeTitle)
                    .padding()
                
                Button("获取设备信息") {
                    deviceInfo = DeviceManager.shared.getDeviceInfo()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if !deviceInfo.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("设备信息:")
                            .font(.headline)
                        
                        ForEach(deviceInfo.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                Text("\(key):")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 100, alignment: .leading)
                                
                                Text(value)
                                    .font(.caption)
                                    .textSelection(.enabled)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Button("重置设备ID") {
                    DeviceManager.shared.resetDeviceId()
                    deviceInfo = DeviceManager.shared.getDeviceInfo()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .navigationTitle("设备信息")
        }
        .onAppear {
            deviceInfo = DeviceManager.shared.getDeviceInfo()
        }
    }
}

#Preview {
    DeviceInfoTestView()
}