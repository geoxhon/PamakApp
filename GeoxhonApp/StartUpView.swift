//
//  StartUpView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 20/11/22.
//

import Foundation
import SwiftUI
import KeychainAccess
/*
 This is the first view that gets loaded when the application starts.
 The purpose of this view is to check the validity of the refresh token.
 If no such token exists or its invalid the application moves to the login screen.
 If the token is valid and the user is authenticated then we move to the main screen directly.
 */
struct FStartUpView: View{
    @State var moveToLogin:Bool = false
    @State var moveToMain:Bool = false
    public func move(){
        
    }
    
    init(){
        moveToLogin = false
        
    }
    
    var body: some View{
        NavigationStack(){
            NavigationLink(
                destination: ContentView()
                    .navigationBarTitle("")
                    .navigationBarHidden(true),
                isActive: $moveToLogin
            ){}
            NavigationLink(
                destination: MainView()
                    .navigationBarTitle("")
                    .navigationBarHidden(true),
                isActive: $moveToMain
            ){}
                .onAppear{
                let keychain = Keychain(service: "com.geoxhonapps.dai")
                if let token = keychain["refreshToken"] as? String{
                    if(token != "NO ID"){
                        UStaticFunctionUtilities.getRestHandler().doLoginToken(token, self)
                        
                    }else{
                        moveToLogin = true
                    }
                }else{
                    moveToLogin = true
                }
            }

        }
    }
        
}
