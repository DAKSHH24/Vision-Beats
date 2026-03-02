import Foundation
import AVFoundation

class DrumSoundManager: @unchecked Sendable {
    static let shared = DrumSoundManager()
    private let engine = AVAudioEngine() // drum sticks ready to hit the buffers
    private var players: [String: AVAudioPlayerNode] = [:]
    private var buffers: [String: AVAudioPCMBuffer] = [:]

    private init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    func preload(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { return }
      
        // Read the file data into the fast-access buffer
        try? file.read(into: buffer)
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        buffers[fileName] = buffer
        players[fileName] = player
        
        // Fire up the engine if it's not already humming
        if !engine.isRunning { try? engine.start() }
    }

    func playSound(fileName: String) {
        guard let player = players[fileName], let buffer = buffers[fileName] else { return }
        player.play()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
    }
}
