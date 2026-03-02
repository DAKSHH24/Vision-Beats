
import SwiftUI
import AVFoundation
import Vision

struct TrackerData: Identifiable {
    let id: Int
    var position: CGPoint
    var isStriking: Bool
}

@MainActor
class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    //drum sounds and position
    @Published var drums: [Drum] = [
        Drum(name: "Crash", fileName: "CrashCymbal", color: .yellow, position: CGPoint(x: 0.15, y: 0.15), size: 200, isCymbal: true),
        Drum(name: "Tom 1", fileName: "Tom1", color: Color(white: 0.15), position: CGPoint(x: 0.38, y: 0.28), size: 150),
        Drum(name: "Tom 2", fileName: "Tom2", color: Color(white: 0.15), position: CGPoint(x: 0.62, y: 0.28), size: 150),
        Drum(name: "Ride", fileName: "Ride", color: .yellow, position: CGPoint(x: 0.85, y: 0.15), size: 200, isCymbal: true),
        Drum(name: "Hi-Hat", fileName: "Hi_Hat_Close", color: .yellow, position: CGPoint(x: 0.12, y: 0.45), size: 180, isCymbal: true),
        Drum(name: "Snare", fileName: "Snare", color: Color(white: 0.15), position: CGPoint(x: 0.25, y: 0.65), size: 180),
        Drum(name: "Kick", fileName: "Kick", color: Color(white: 0.15), position: CGPoint(x: 0.5, y: 0.78), size: 290),
        Drum(name: "Floor Tom", fileName: "Floor_Tom", color: Color(white: 0.15), position: CGPoint(x: 0.78, y: 0.7), size: 200)
    ]
    
    @Published var trackers: [TrackerData] = []
    var screenSize: CGSize = .zero
    let captureSession = AVCaptureSession()
    
    private var lastFingerPoints: [CGPoint] = [] // for tracking the finger
    private var lastHitTimes: [UUID: Date] = [:]
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    override init() {
        super.init()
        handPoseRequest.maximumHandCount = 2 // hand count
        setupCamera()
        drums.forEach { DrumSoundManager.shared.preload(fileName: $0.fileName) }
    }


    func setupCamera() {
        guard let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: dev) else { return }
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        
        let out = AVCaptureVideoDataOutput()
        out.alwaysDiscardsLateVideoFrames = true
        out.setSampleBufferDelegate(self, queue: DispatchQueue(label: "visionQueue", qos: .userInteractive))
        if captureSession.canAddOutput(out) { captureSession.addOutput(out) }
        
        DispatchQueue.global(qos: .userInitiated).async { // to remove the latency
            self.captureSession.startRunning()
        }
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        let localHandPoseRequest = VNDetectHumanHandPoseRequest()
        localHandPoseRequest.maximumHandCount = 2
        try? VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .leftMirrored).perform([localHandPoseRequest])
        
        guard let observations = localHandPoseRequest.results else { return }
        var points: [CGPoint] = []
        
        for observation in observations {
            if let tip = try? observation.recognizedPoints(.indexFinger)[.indexTip], tip.confidence > 0.6 {
                points.append(CGPoint(x: tip.location.x, y: 1 - tip.location.y))
            }
        }
        
        Task { @MainActor in self.processDetection(points: points) }
    }

    private func processDetection(points: [CGPoint]) {
        var newTrackers: [TrackerData] = []
        var nextLastFingerPoints: [CGPoint] = []
        let now = Date()
        
        for (index, pt) in points.enumerated() {
            // for finding the matching finger from the previous frame to prevent swapping
            let prevPt = lastFingerPoints.min(by: { hypot($0.x - pt.x, $0.y - pt.y) < hypot($1.x - pt.x, $1.y - pt.y) }) ?? pt
            let smoothedX = (prevPt.x * 0.5) + (pt.x * 0.5)   
            let smoothedY = (prevPt.y * 0.5) + (pt.y * 0.5)
            let smoothedPt = CGPoint(x: smoothedX, y: smoothedY)
            
            let velocityY = smoothedPt.y - prevPt.y
            let isMovingDownGlobal = velocityY > 0.005
            
            newTrackers.append(TrackerData(id: index, position: smoothedPt, isStriking: isMovingDownGlobal))
            
            for i in drums.indices {
                let dPos = CGPoint(x: drums[i].position.x * screenSize.width, y: drums[i].position.y * screenSize.height)
                let fPos = CGPoint(x: smoothedPt.x * screenSize.width, y: smoothedPt.y * screenSize.height)
                
                let effectiveSize = drums[i].name == "Kick" ? drums[i].size * 1.2 : drums[i].size
                
               
                if hypot(dPos.x - fPos.x, dPos.y - fPos.y) < (effectiveSize * 0.5) { // If the finger is inside the drum's hit-box
                    let drumID = drums[i].id
                    let hitThreshold: CGFloat = drums[i].name == "Kick" ? 0.002 : 0.005
                    let isStrikingThisDrum = velocityY > hitThreshold
                    
                    let lastHit = lastHitTimes[drumID] ?? .distantPast
                    
                    // It will only play if it's striking and it has been at least 0.2 seconds since the last hit.
                    if isStrikingThisDrum && now.timeIntervalSince(lastHit) > 0.2 {
                        lastHitTimes[drumID] = now
                        DrumSoundManager.shared.playSound(fileName: drums[i].fileName)
                        drums[i].isHit = true
                        
                        let idx = i
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.drums[idx].isHit = false }
                    }
                }
            }
            nextLastFingerPoints.append(smoothedPt)
        }
        
        lastFingerPoints = nextLastFingerPoints
        self.trackers = newTrackers
    }
}
