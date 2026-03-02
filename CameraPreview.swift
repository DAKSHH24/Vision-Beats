import SwiftUI
import AVFoundation

struct CameraPreview: UIViewControllerRepresentable {
    let session: AVCaptureSession
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.session = session
        return vc
    }
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // For getting the camera feed onto the screen
        if let session = session {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill // styling for the camera to cover the whole screen
            view.layer.addSublayer(layer)
            self.previewLayer = layer
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        
        if let connection = previewLayer?.connection, let windowScene = view.window?.windowScene {
            
            // Check if the device is running iOS 17 or newer
            if #available(iOS 17.0, *) {
                // For iOS 17+
                switch windowScene.interfaceOrientation {
                case .landscapeLeft:
                    connection.videoRotationAngle = 180.0
                case .landscapeRight:
                    connection.videoRotationAngle = 0.0
                case .portraitUpsideDown:
                    connection.videoRotationAngle = 270.0
                default: // .portrait
                    connection.videoRotationAngle = 90.0
                }
            } else {
                // For iOS 16 and older
                switch windowScene.interfaceOrientation {
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeRight:
                    connection.videoOrientation = .landscapeRight
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                default: // .portrait
                    connection.videoOrientation = .portrait
                }
            }
        }
    }
}
