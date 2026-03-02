
import SwiftUI

// This keeps track of which screen the user is currently looking at
enum AppScreen {
    case home
    case tutorial
    case playing
}

struct HomeView: View {
    @State private var currentScreen: AppScreen = .home
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(white: 0.15), Color(white: 0.05)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // for switching between screens based on the state
            switch currentScreen {
            case .home:
                HomeContent(currentScreen: $currentScreen)
                    .transition(.opacity)
            case .tutorial:
                TutorialView(currentScreen: $currentScreen)
                    .transition(.slide)
            case .playing:
                ContentView(currentScreen: $currentScreen)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: currentScreen)
    }
}

// main home screen
struct HomeContent: View {
    @Binding var currentScreen: AppScreen
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 30) {
                
                VStack(alignment: .center, spacing: 15) {
                    Image("DrumLogo.png")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: geo.size.width / 3, maxWidth: geo.size.width / 3)

                        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 10)
                    
                    Text("Vision Beats") // app name
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .foregroundStyle(.white)
                        .tracking(5)
                }

                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(icon: "waveform.circle.fill", text: "Studio-quality kits mapped directly into your room.")
                    InstructionRow(icon: "sparkles", text: "Advanced motion tracking catches every single flick.")
                    InstructionRow(icon: "guitars.fill", text: "Zero hardware required, only your hands and the air.")
                }
                .padding(30)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white, lineWidth: 2)
                    )
                .padding(.horizontal, 20)
                
                Button(action: {
                    currentScreen = .playing
                }) {
                    Text("Start Playing")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 60)
                        .background(Capsule().fill(.yellow))
                        .shadow(color: .yellow.opacity(0.4), radius: 15)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TutorialView: View {
    @Binding var currentScreen: AppScreen
    @State private var currentStep = 0
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("HOW TO PLAY")
                .font(.title)
                .bold()
                .foregroundStyle(.white)
                .padding(.top, 60)
            
         // all the 4 steps
            TabView(selection: $currentStep) {
                TutorialStep(icon: "hand.point.up.left.fill", stepNum: "Step 1", title: "Aim", description: "Place the ipad on a stable place and bring the green tracking dot to any of the drum sets.")
                    .tag(0)
                
                TutorialStep(icon: "hand.point.left.fill", stepNum: "Step 2", title: "Strike", description: "Hit down in the air to get the sound of the drum.")
                    .tag(1)
                
                TutorialStep(icon: "hand.point.up.left.fill", stepNum: "Step 3", title: "Reset", description: "Retract your hand immediately to prevent repeat triggers. Once the beat plays, move your finger to the next drum to keep the beat going.")
                    .tag(2)
                
                TutorialStep(icon: "checkmark.circle.fill", stepNum: "Step 4", title: "You are good to go!", description: "Keep your movements sharp. Have fun!")
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            Spacer()
            
            if currentStep == 3 {
                Button(action: {
                    dismiss()
                    currentScreen = .playing
                }) {
                    Text("PLAY")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.black)
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(.yellow))
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                }
                .padding(.bottom, 50)
            } else {
                Button(action: {
                    withAnimation { currentStep += 1 }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 200)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                }
                .padding(.bottom, 50)
            }
        }
        .background(
            LinearGradient(colors: [Color(white: 0.15), Color(white: 0.05)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

// UI components
struct TutorialStep: View {
    let icon: String
    let stepNum: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .top) {
                if icon == "hand.point.up.left.fill" {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 15, height: 15)
                        .shadow(color: .green.opacity(0.6), radius: 5)
                        .offset(y: -30)
                        .offset(x: -35)
                }
                 else if icon == "hand.point.left.fill" {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 15, height: 15)
                            .shadow(color: .green.opacity(0.6), radius: 5)
                            .offset(y: 76)
                            .offset(x: -53)
                    }
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.white)
                    .padding(.bottom, 20)
                    .rotationEffect(icon == "hand.point.left.fill" ? .degrees(-50) : .degrees(0))
            }
            
            Text(stepNum)
                .font(.headline)
                .foregroundStyle(.yellow)
            
            Text(title)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(.yellow)
                .frame(width: 30)
            Text(text)
                .foregroundStyle(.white.opacity(0.8))
                .font(.subheadline)
        }
    }
}

#Preview("Home View") {
    HomeView()
}
