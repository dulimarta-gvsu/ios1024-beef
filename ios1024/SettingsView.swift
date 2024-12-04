import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: GameViewModel // Access the shared ViewModel
    @EnvironmentObject var driver: MyNavigator
    @State private var selectedBoardSize = 4 // Default board size
    @State private var selectedTarget = 1024 // Default target
    @State private var boardSize = UserDefaults.standard.integer(forKey: "boardSize")
    @State private var targetScore = UserDefaults.standard.integer(forKey: "targetScore")

    var body: some View {
        VStack {
            Stepper("Board Size: \(boardSize)", value: $boardSize, in: 3...7)
            Picker("Target Score:", selection: $targetScore) {
                ForEach([1024, 2048, 4096, 8192], id: \.self) { score in
                    Text("\(score)")
                }
            }
            Button("Use New Settings") {
                UserDefaults.standard.set(boardSize, forKey: "boardSize")
                UserDefaults.standard.set(targetScore, forKey: "targetScore")
                vm.applySettings()
                driver.navBack() // Navigate back after applying settings
            }
        }
        .onAppear {
                    vm.loadSavedSettings()
                }
                .padding(.horizontal)
            }
        }
