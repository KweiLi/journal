//
//  AudioPlayerManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//


import Foundation
import Combine
import AVFoundation
import Speech

class AudioRecorder:NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var audioClips: [AudioClip] = []
    @Published var isRecording = false

    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer?
    private var timer: AnyCancellable?

    override init() {
        super.init()
        requestTranscriptionPermission()
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }

        let url = getDocumentsDirectory().appendingPathComponent(UUID().uuidString + ".m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            isRecording = true
        } catch {
            print("Failed to start recording")
        }
    }

    private func stopRecording() {
        audioRecorder.stop()
        isRecording = false

        let newClip = AudioClip(url: audioRecorder.url)
        audioClips.append(newClip)

        transcribeAudio(audioRecorder.url) { transcript in
            if let index = self.audioClips.firstIndex(where: { $0.id == newClip.id }) {
                self.audioClips[index].transcript = transcript
            }
        }
    }

    func togglePlayback(of clip: AudioClip) {
        guard let index = audioClips.firstIndex(where: { $0.id == clip.id }) else { return }
        if clip.isPlaying {
            stopPlayback()
        } else {
            startPlayback(at: index)
        }
        audioClips[index].isPlaying.toggle()
    }

    func startPlayback(at index: Int) {
        let clip = audioClips[index]
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: clip.url)
            audioPlayer?.delegate = self
            audioPlayer?.play()

            timer = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self, let audioPlayer = self.audioPlayer else { return }
                    if index < self.audioClips.count {
                        if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
                            self.audioClips[index].playbackProgress = audioPlayer.currentTime / audioPlayer.duration
                        } else {
                            self.audioClips[index].playbackProgress = 0.0
                        }
                    }
                }
        } catch {
            print("Failed to start playback")
        }
        audioPlayer?.delegate = self
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = audioClips.firstIndex(where: { $0.url == player.url }) {
            audioClips[index].isPlaying = false
            audioClips[index].playbackProgress = 0.0
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        timer?.cancel()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            if index < audioClips.count {
                audioClips.remove(at: index)
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func requestTranscriptionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                print("Speech recognition authorization granted")
            } else {
                print("Speech recognition authorization denied")
            }
        }
    }

    private func transcribeAudio(_ url: URL, completion: @escaping (String) -> Void) {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        recognizer?.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                print("Transcription failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if result.isFinal {
                completion(result.bestTranscription.formattedString)
            }
        }
    }
}


