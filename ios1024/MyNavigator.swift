//
//  MyNavigator.swift
//  ios1024
//
//  Created by Keefer Riley on 11/12/24.
//

import SwiftUI

enum Destination {
    case NewAccountDestination
    case GameDestination
    case SettingsDestination
    case StatisticsDestination
}

class MyNavigator: ObservableObject {
    @Published var myNavStack: Array<Destination> = []
    @Published var navPath: NavigationPath = NavigationPath()
    func navigate(to d: Destination) {
        navPath.append(d)
    }
    
    func backHome() {
        while navPath.count > 0 {
            navPath.removeLast()
        }
    }
    
    func navBack() {
        navPath.removeLast()
    }
}
