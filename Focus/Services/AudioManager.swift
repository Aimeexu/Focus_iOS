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
    private var soundEffectPlayer: AVAudioPlayer?
    
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
    
    func pauseSound() {
        audioPlayer?.pause()
        print("⏸️ 音乐已暂停")
    }
    
    func resumeSound() {
        audioPlayer?.play()
        print("▶️ 音乐已恢复")
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
    
    // 播放单次音效（不循环）
    func playSoundEffect(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("找不到音效文件: \(fileName).mp3")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.numberOfLoops = 0 // 只播放一次
            soundEffectPlayer?.volume = 1.0 // 音效使用100%音量
            soundEffectPlayer?.play()
            
            print("🔔 播放音效: \(fileName)")
        } catch {
            print("播放音效失败: \(error.localizedDescription)")
        }
    }
}
