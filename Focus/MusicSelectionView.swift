//
//  MusicSelectionView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI

struct MusicSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMusic: String
    @State private var selectedSound: SoundType = .rain
    
    enum SoundType: CaseIterable {
        case rain, wave, forest, wind, silence
        
        var icon: String {
            switch self {
            case .rain:
                return "cloud.rain.fill"
            case .wave:
                return "water.waves"
            case .forest:
                return "leaf.fill"
            case .wind:
                return "wind"
            case .silence:
                return "speaker.slash.fill"
            }
        }
        
        var name: String {
            switch self {
            case .rain:
                return "Rain"
            case .wave:
                return "Wave"
            case .forest:
                return "Forest"
            case .wind:
                return "Wind"
            case .silence:
                return "Silence"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 主内容区域
            VStack(spacing: 20) {

                // 音量控制条
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green)
                                .frame(width: getBarWidth(for: index), height: getBarHeight(for: index))
                        }
                    }
                    
                    // 分隔线
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 1)
                        .frame(maxWidth: 200)
                }
                .padding(.top, 30)
                
                // 声音选择网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(SoundType.allCases.prefix(3), id: \.self) { soundType in
                        SoundButton(
                            soundType: soundType,
                            isSelected: selectedSound == soundType
                        ) {
                            selectedSound = soundType
                        }
                    }
                    
                    ForEach(SoundType.allCases.suffix(2), id: \.self) { soundType in
                        SoundButton(
                            soundType: soundType,
                            isSelected: selectedSound == soundType
                        ) {
                            selectedSound = soundType
                        }
                    }
                    
                    // 空白占位，保持布局对称
                    Color.clear
                        .frame(width: 50, height: 50)
                }
                .padding(.horizontal, 10)

            }
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))

            // OK 按钮
            Button(action: {
                // 更新选中的音乐图标
                selectedMusic = selectedSound.icon
                isPresented = false
            }) {
                Text("OK")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.brown)
            }
            .padding(.top, 30)
        }
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
    }
    
    private func getBarWidth(for index: Int) -> CGFloat {
        switch index {
        case 0, 4: return 20
        case 1, 3: return 25
        case 2: return 30
        default: return 20
        }
    }
    
    private func getBarHeight(for index: Int) -> CGFloat {
        switch index {
        case 0, 4: return 40
        case 1, 3: return 60
        case 2: return 80
        default: return 40
        }
    }
}

struct SoundButton: View {
    let soundType: MusicSelectionView.SoundType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: soundType.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.green : Color.white)
                    .clipShape(Circle())
                
                Text(soundType.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MusicSelectionView(
        isPresented: .constant(true),
        selectedMusic: .constant("music.note")
    )
    .background(Color.black.opacity(0.3))
}
