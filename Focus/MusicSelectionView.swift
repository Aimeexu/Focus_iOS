//
//  MusicSelectionView.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/7.
//

import SwiftUI
import AVFoundation

struct MusicSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMusic: String
    @State private var selectedSound: SoundType = .silence
    @StateObject private var audioManager = AudioManager.shared
    
    enum SoundType: CaseIterable {
        case rain, wave, forest, wind, silence
        
        var icon: String {
            switch self {
            case .rain:
                return "rain"
            case .wave:
                return "river"
            case .forest:
                return "jungle"
            case .wind:
                return "sea"
            case .silence:
                return "silent"
            }
        }
        
        var audioFileName: String? {
            switch self {
            case .rain:
                return "rain_sound"
            case .wave:
                return "wave_sound"
            case .forest:
                return "forest_sound"
            case .wind:
                return "wind_sound"
            case .silence:
                return nil // 静音不播放音频
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 背景
            AppColors.Background.primary
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 主内容区域
                VStack(spacing: 0) {

                    // 音量控制条
                    VStack(spacing: 0) {

                        Image("wave")
                            .padding(.top, 80)

                        // 分隔线
                        Rectangle()
                            .fill(AppColors.Semantic.darkBrown)
                            .frame(height: 2)
                            .frame(maxWidth: 180)
                            .padding(.vertical, 56)
                    }
                    .padding(.top, 30)

                    // 声音选择网格
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 56) {
                        ForEach(SoundType.allCases.prefix(3), id: \.self) { soundType in
                            SoundButton(
                                soundType: soundType,
                                isSelected: selectedSound == soundType
                            ) {
                                selectedSound = soundType
                                playSound(for: soundType)
                            }
                        }

                        ForEach(SoundType.allCases.suffix(2), id: \.self) { soundType in
                            SoundButton(
                                soundType: soundType,
                                isSelected: selectedSound == soundType
                            ) {
                                selectedSound = soundType
                                playSound(for: soundType)
                            }
                        }

                        // 空白占位，保持布局对称
                        Color.clear
                            .frame(width: 48, height: 48)
                    }
                    .padding(.horizontal, 10)

                }
                .padding(.horizontal, 20)
                .background(Color(.systemGray6))

                // OK 按钮
                Button(action: {
                    // 更新选中的音乐图标
                    selectedMusic = selectedSound.icon
                    // 开始播放选中的音乐
                    playSound(for: selectedSound)
                    isPresented = false
                }) {
                    Text("OK")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppColors.Semantic.darkBrown)
                }
                .padding(.top, 30)
            }
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(AppColors.Semantic.darkBrown, lineWidth: 3)
            )
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
        }
        .onAppear {
            // 根据当前选中的音乐图标设置selectedSound
            selectedSound = SoundType.allCases.first { $0.icon == selectedMusic } ?? .silence
        }

    }
    
    // 播放音频
    private func playSound(for soundType: SoundType) {
        // 如果是静音，停止播放
        guard let fileName = soundType.audioFileName else {
            audioManager.stopSound()
            return
        }
        
        // 播放对应的音频文件
        audioManager.playSound(fileName: fileName)
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
                Image(isSelected ? soundType.icon + "_fill" : soundType.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(.white)
                    .clipShape(Circle())
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
