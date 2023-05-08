//
//  ProfileView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 20/11/22.
//

import Foundation
import SwiftUI
import PopupView
/*
 This view presents the users profile.
 The profile contains information about the user, such as his email and his id
 It also gives the option to log out from the account.
 Logging out will move the user to the login screen.
 */
struct FProfileView: View{
    @State var presentLogOut: Bool = false
    @State var moveToLogin: Bool = false
    var body: some View{
        GeometryReader{
            metrics in
            VStack(){
                List(){
                    HStack(){
                        Text("Όνομα Χρήστη")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        Text(UStaticFunctionUtilities.getCurrentUser().getName()).fontWeight(.light)
                    }
                    HStack(){
                        Text("Ακαδημαϊκο Email")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        Text(UStaticFunctionUtilities.getCurrentUser().getEmail()).fontWeight(.light)
                    }
                    HStack(){
                        Text("Αναγνωρηστικό")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        Text(UStaticFunctionUtilities.getCurrentUser().getId()).fontWeight(.light)
                    }
                    if(UStaticFunctionUtilities.getCurrentUser().getIsAdmin()){
                        HStack(){
                            Text("Admin")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text("ΝΑΙ").fontWeight(.light)
                        }
                    }
                }
                .navigationTitle("Το προφίλ μου")
                    .navigationBarTitleDisplayMode(.large)
                List(){
                    Button(){
                        presentLogOut = true
                    }label:{
                        HStack(){
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Αποσύνδεση")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .foregroundColor(.red)
            }.navigate(to: ContentView(), when: $moveToLogin)
            
            }.popup(isPresented: $presentLogOut, type: .floater(verticalPadding: 0, useSafeAreaInset: false), position: .bottom, dragToDismiss: true, closeOnTap:false, closeOnTapOutside: true) {
                GroupBox(){
                    HStack(){
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .scaleEffect(1.5, anchor: .center)
                        Text("ΠΡΟΣΟΧΗ")
                            .font(.title)
                            .frame(width: 150, height: 150)
                    }
                    
                    Text("Πρόκειται να αποσυνδεθείς")
                    Button("Αποσύνδεση"){
                        UStaticFunctionUtilities.getRestHandler().doLogout()
                        moveToLogin = true
                    }
                    .foregroundColor(.white)
                    .frame(width: metrics.size.width*0.7, height: metrics.size.height*0.07)
                    .background(Color.red)
                    .cornerRadius(10)
                    
                    
                    Button("Ακύρωση"){
                        presentLogOut = false
                    }
                    .foregroundColor(.white)
                    .frame(width: metrics.size.width*0.7, height: metrics.size.height*0.07)
                    .background(Color.gray)
                    .cornerRadius(10)
                }
                .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                .cornerRadius(20.0)
                .frame(minWidth: 400, minHeight: 400)
                }
        }
    }
}
