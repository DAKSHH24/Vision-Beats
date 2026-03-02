import SwiftUI

//structure of drum
struct Drum: Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
    let color: Color
    var position: CGPoint
    var size: CGFloat
    var isHit = false
    var isCymbal = false
}
