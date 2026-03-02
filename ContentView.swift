import SwiftUI

struct ContentView: View {
    @Binding var currentScreen: AppScreen
    @StateObject var vm = CameraViewModel()
    @State private var showTips = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreview(session: vm.captureSession).ignoresSafeArea()
                
                // styling
                Color.black.opacity(0.2).ignoresSafeArea()
                
                // Drum Styling
                ForEach(vm.drums) { drum in
                    DrumDecor(drum: drum)
                        .position(x: drum.position.x * geo.size.width, y: drum.position.y * geo.size.height)
                }
                
                // Green dots
                ForEach(vm.trackers) { tracker in
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                        .shadow(color: .green, radius: tracker.isStriking ? 15 : 5)
                        .position(
                            x: tracker.position.x * geo.size.width,
                            y: tracker.position.y * geo.size.height
                        )
                }
                
                // Top Navigation Bar
                VStack {
                    HStack {
                        // Back Button
                        Button(action: {
                            currentScreen = .home
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        
                        Spacer()
                        
                        // Tips Button
                        Button(action: {
                            showTips = true
                        }) {
                            Image(systemName: "questionmark")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .onAppear { vm.screenSize = geo.size }
            .onChange(of: geo.size) { newValue in vm.screenSize = newValue }
            
            // TIPS POP-UP SHEET
            .sheet(isPresented: $showTips) {
                TutorialView(currentScreen: .constant(.tutorial))
            }
        }
    }
}
