//
//  AudioManager.swift
//  Focus
//
//  Created by Jessica mini on 2025/8/14.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playSound(fileName: String) {
        stopSound()
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("找不到音频文件: \(fileName).wav")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 无限循环播放
            audioPlayer?.volume = 0.3 // 设置音量为30%
            audioPlayer?.play()
            
        } catch {
            print("播放音频失败: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
}
