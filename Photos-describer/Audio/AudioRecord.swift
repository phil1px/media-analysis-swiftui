import AVFoundation
import UIKit

final class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private let fileName = "audio.m4a"
    
    @Published var isRecording = false
    @Published var audioFileURL: URL?
    @Published var amplitude: CGFloat = 0.0
    @Published var errorMessage: String?
    
    private var timer: Timer?
    
    override init() {
        super.init()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        audioFileURL = documentsDirectory.appendingPathComponent(fileName)
    }
    
    func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startMonitoring()
        } catch {
            print("Failed to start recording: \(error)")
            errorMessage = "Falha ao iniciar a gravação: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioRecorder?.updateMeters()
            let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
            self.amplitude = CGFloat(max(0, min(1, (level + 160) / 160)))
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        amplitude = 0.0
    }
    
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording()
            errorMessage = "A gravação não foi bem-sucedida."
        }
    }
}
