//
//  ContentView.swift
//  ios1024
//
//  Created by Hans Dulimarta for CIS357
//  Continued by Keefer Riley

import SwiftUI
import Combine

struct GameView: View {
    @State var swipeDirection: SwipeDirection? = .none
    @StateObject var viewModel: GameViewModel = GameViewModel()
    
    @EnvironmentObject var driver: MyNavigator
    @State private var showingWinAlert = false
    @State private var showingLoseAlert = false
    @State private var triggerViewUpdate = false
    @State private var cancellables: Set<AnyCancellable> = []

    
    var body: some View {
        VStack {
            Text("Welcome to 1024 by Keefer!").font(.title2)
            Text("Valid Swipes: \(viewModel.validSwipes)")
            NumberGrid(viewModel: viewModel, shouldUpdate: $triggerViewUpdate)
                .gesture(DragGesture().onEnded {
                    swipeDirection = determineSwipeDirection($0)
                    viewModel.handleSwipe(swipeDirection!)
                })
                .padding()
                .frame(maxWidth: .infinity)
            
            if let swipeDirection {
                Text("You swiped \(swipeDirection)")
            }
            HStack {
                Button("Logout") {
                    driver.backHome()
                }
                Button("Settings") {
                    driver.navigate(to: .SettingsDestination)
                }
                Button("Show Stats") {
                    driver.navigate(to: .StatisticsDestination)
                }
            }
            .buttonStyle(.borderedProminent)
            if viewModel.gameWon {
                Text("You Won!")
            } else if viewModel.gameLost {
                Text("Game Over!")
            }
            
            // Add the Reset Button
            Button(action: {
                viewModel.resetGame()
                showingWinAlert = false
                showingLoseAlert = false
            }) {
                Text("Reset Game")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear() {
            viewModel.settingsChangedPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in self.viewModel.resetGame()
                }
                .store(in: &cancellables)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .alert("You Won!", isPresented: $showingWinAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Game Over!", isPresented: $showingLoseAlert) {
            Button("OK", role: .cancel) { }
        }
        .onChange(of: viewModel.gameWon) {
            if viewModel.gameWon {
                showingWinAlert = true
            }
        }
        .onChange(of: viewModel.gameLost) {
            if viewModel.gameLost {
                showingLoseAlert = true
            }
        }
    }
    
    struct NumberGrid: View {
        @ObservedObject var viewModel: GameViewModel
        let size: Int = 4
        @Binding var shouldUpdate: Bool
        
        var body: some View {
            VStack(spacing:4) {
                ForEach(0..<size, id: \.self) { row in
                    HStack (spacing:4) {
                        ForEach(0..<size, id: \.self) { column in
                            let cellValue = viewModel.grid[row][column]
                            Text("\(cellValue)")
                                .font(.system(size:26))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .id(shouldUpdate)
            .onAppear{
                viewModel.applySettings()
            }
            .padding(4)
            .background(Color.gray.opacity(0.4))
            .id(shouldUpdate)
        }
    }
    
    func determineSwipeDirection(_ swipe: DragGesture.Value) -> SwipeDirection {
        if abs(swipe.translation.width) > abs(swipe.translation.height) {
            return swipe.translation.width < 0 ? .left : .right
        } else {
            return swipe.translation.height < 0 ? .up : .down
        }
    }
}

#Preview {
    LoginView(vm: GameViewModel())
}
