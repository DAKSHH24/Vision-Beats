import SwiftUI

struct DrumDecor: View {
    let drum: Drum
    
    // making and styling the drum 
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.35))
                .frame(width: drum.size * 1.1, height: drum.size * 0.4)
                .blur(radius: 20)
                .offset(y: drum.size * 0.6)

            if drum.isCymbal {
                ZStack {
                    Circle()
                        .fill(AngularGradient(colors: [Color(red: 0.85, green: 0.65, blue: 0.2), Color(red: 1.0, green: 0.88, blue: 0.5), Color(red: 0.7, green: 0.5, blue: 0.1), Color(red: 0.85, green: 0.65, blue: 0.2)], center: .center))
                    ForEach(0..<10) { i in
                        Circle().stroke(Color.black.opacity(0.08), lineWidth: 1).padding(CGFloat(i) * (drum.size / 20))
                    }
                    Circle().fill(RadialGradient(colors: [.white.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: drum.size * 0.15)).frame(width: drum.size * 0.3)
                }
                .frame(width: drum.size, height: drum.size)
                .rotation3DEffect(.degrees(55), axis: (x: 1, y: 0, z: 0))
                .scaleEffect(drum.isHit ? 1.08 : 1.0)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 10)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: drum.size / 2.2)
                        .fill(LinearGradient(colors: [Color(white: 0.05), Color(white: 0.2), Color(white: 0.05)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: drum.size, height: drum.size * 0.7)
                        .offset(y: drum.size * 0.2)
                    
                    ForEach(0..<6) { i in
                        Capsule().fill(LinearGradient(colors: [.white, .gray, .black], startPoint: .top, endPoint: .bottom))
                            .frame(width: drum.size * 0.04, height: drum.size * 0.20)
                            .offset(x: (drum.size * 0.47) * cos(CGFloat(i) * .pi / 3), y: drum.size * 0.25)
                    }

                    Ellipse().stroke(LinearGradient(colors: [.white, .gray, .white, .black], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 5)
                        .frame(width: drum.size * 1.02, height: drum.size * 0.48)
                    
                    Ellipse().fill(RadialGradient(colors: [Color(white: 0.98), Color(white: 0.85)], center: .center, startRadius: 0, endRadius: drum.size * 0.4))
                        .frame(width: drum.size, height: drum.size * 0.45)
                        .overlay(Ellipse().stroke(Color.black.opacity(0.1), lineWidth: 1))
                }
                .scaleEffect(drum.isHit ? 0.96 : 1.0)
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 15)
            }
        }
        .animation(.spring(response: 0.15, dampingFraction: 0.5), value: drum.isHit)
    }
}
