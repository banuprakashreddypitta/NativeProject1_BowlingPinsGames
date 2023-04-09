//
//  GameSoundsVC.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 28/03/23.
//

import Foundation
import AVFoundation

protocol PlayerDelegate: AnyObject {
    func playbackStarted()
    func playbackEnded()
}

public enum Sound: String {
    case none = "none"
    case startGame = "startgame"
    case endGame = "endGame"
    case shotSuccess = "shotsuccess"
    case foul = "foul"
    case gamebgm = "gamebgm"
}

public class PlayGameSounds: NSObject,AVAudioPlayerDelegate {
    var player: AVAudioPlayer?
    var currentSound: Sound = .none
    weak var playerDelegate: PlayerDelegate?
    
    // MARK: - player methods
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: AVAudioSession.sharedInstance())
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch type {
        case .began:
            pausePlayback()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                resumePlayback()
            }
        default: ()
        }
    }
    
    func startPlayback(with sound: Sound) {
        stopPlayback()
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.delegate = self
            guard let player = player else { return }
            player.play()
            playerDelegate?.playbackStarted()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func resumePlayback() {
        player?.play()
    }
    
    func pausePlayback() {
        player?.pause()
    }
    
    func stopPlayback() {
        player?.numberOfLoops = 0
        player?.stop()
    }
    
    func repeatPlayback() {
        player?.numberOfLoops = -1
    }
    
    
    // MARK: - Player delegate methods
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerDelegate?.playbackEnded()
    }
    
}
