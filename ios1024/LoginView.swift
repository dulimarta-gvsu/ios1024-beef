//
//  LoginView.swift
//  ios1024
//
//  Created by Keefer Riley on 11/12/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var what: MyNavigator
    @ObservedObject var vm: GameViewModel
    @State var loginError: String = ""
    var body: some View {
        VStack {
            Text("Login here")
            HStack {
                Button("Sign in") {
                    checkAuthentication()
                }
                Button("Sign up") {
                    what.navigate(to: .NewAccountDestination)
                }
            }
        }
        .buttonStyle(.borderedProminent)
        
    }
    
    func checkAuthentication() {
        Task {
            if await vm.checkUserAcc(user: "beef@mail.com", pwd: "password") {
                what.navigate(to: .GameDestination)
            } else {
                loginError = "Unable to login"
            }
        }
    }
}

#Preview {
    LoginView(vm: GameViewModel())
}
