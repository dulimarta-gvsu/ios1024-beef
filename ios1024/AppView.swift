//
//  AppView.swift
//  ios1024
//
//  Created by Keefer Riley on 11/12/24.
//

import SwiftUI
import Combine

struct AppView: View {
    @ObservedObject private var navCtrl:MyNavigator = MyNavigator()
    @StateObject var vm: GameViewModel = GameViewModel()
    @StateObject var statsVM = StatisticsViewModel()
    var body: some View {
        NavigationStack(path: $navCtrl.navPath){
            LoginView(vm: vm)
            .navigationDestination(for: Destination.self) { d in
                switch(d) {
                case .GameDestination: GameView().navigationBarBackButtonHidden(true)
                case .NewAccountDestination: NewAccView()
                case .SettingsDestination: SettingsView()
                case .StatisticsDestination: StatisticsView()
                
                }
            }
        }
        .environmentObject(navCtrl)
        .environmentObject(vm)
        .environmentObject(statsVM)
    }
}
