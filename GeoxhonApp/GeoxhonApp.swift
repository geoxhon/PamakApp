//
//  PoopyAppApp.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 14/11/22.
//

import SwiftUI

@main
struct GeoxhonApp: App {
    var body: some Scene {
        WindowGroup {
            FStartUpView()
        }
    }
}
struct loginResponse: Decodable{
  let success: Bool
  let reason: String
}


extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    /// Navigate to a new view with back option.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigateWithReturn<NewView: View>(to view: NewView, viewName:String = "", parentViewName:String = "", when binding: Binding<Bool>) -> some View {
            ZStack {
                self
                    .navigationBarTitle(parentViewName)

                NavigationLink(
                    destination: view
                        .navigationBarTitle(viewName),
                    isActive: binding
                ) {

                }
            }
    }
}
