//
//  NewAccView.swift
//  ios1024
//
//  Created by Keefer Riley on 11/12/24.
//

import SwiftUI

struct NewAccView: View {
    @EnvironmentObject var driver: MyNavigator
    var body: some View {
        VStack {
            Text("Create new account")
            HStack {
                Button("Not now") {
                    driver.navBack()
                }
                Button("Create") {
                    createAcct()
                }
            }
        }
        .buttonStyle(.borderedProminent)
    }
    func createAcct() {
        driver.navigate(to: .GameDestination)
    }
}

#Preview {
    LoginView(vm: GameViewModel())
}
