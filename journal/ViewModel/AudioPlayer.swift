//
//  AudioPlayer.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation

import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    
    var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var audioPlayer: AVAudioPlayer!
    
    func startPlayback(audio: URL) {
        
        print(audio)
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
        URLSession.shared.dataTask(with: audio) { (data, response, error) in
            guard let data = data else {
                print("Error downloading audio file: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer.delegate = self
                self.audioPlayer.play()
                self.isPlaying = true
            } catch {
                print("Playback failed. Error: \(error.localizedDescription)")
            }
        }.resume()

    }
    
    func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}
