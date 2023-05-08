//
//  ContentView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 14/11/22.
//

import SwiftUI


/*
 This is the login view.
 The view contains a username and password field,
 A button to login,
 A buttont to navigate to sign up view.
 
 The login view features an activity wheel to show that the app is currently communicating with the API
 as well as alerts to notify the user of invalid input.
 The login view is best designed to be viewed on an iPhone, there are scaling problems that need to be looked at for the iPad.
 */
struct ContentView: View {
    @State var move:Bool = false
    @State var loginButtonDisabled:Bool = false
    @State var usernameText:String = ""
    @State var passwordText:String = ""
    @State var showActivity:Double = 0.0
    @State var loginErr:String = ""
    @State var loginAlert:Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    func login(_ username:String, _ password:String) async{
        showActivity = 1.0
        UStaticFunctionUtilities.getRestHandler().doLogin(username, password, self)
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        showActivity = 0.0
        loginButtonDisabled = false
    }
    func getInputFieldColour() -> Color {
        switch colorScheme {
        case .light:
            return .black.opacity(0.05)
        case .dark:
            return Color(red: 64/255, green: 64/255, blue: 64/255)
        }
    }
    
    
    var body: some View {
        GeometryReader{
            metrics in
            ZStack {
                VStack{
                    Circle()
                        .scale(2)
                        .padding(.top, metrics.size.height * -0.9)
                        .ignoresSafeArea().ignoresSafeArea()
                        .foregroundColor(.blue)
                    Spacer().ignoresSafeArea()
                }
                
                VStack(alignment: .center) {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "lock")
                        Text("Σύνδεση")
                            .font(.largeTitle)
                        .fontWeight(.bold)
                        ProgressView()
                            .padding(.leading, 7.0)
                            .opacity(showActivity)
                            .scaleEffect(1.5, anchor: .center)
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    .padding(.top, metrics.size.height * -0.28)

                    HStack(alignment: .center){
                        Spacer()
                        VStack(alignment: .center){
                            TextField("Όνομα Χρήστη", text: $usernameText)
                                .padding()
                                .frame(width: metrics.size.width*0.6, height: metrics.size.height*0.06)
                                .background(getInputFieldColour())
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                
                            SecureField("Κωδικός", text: $passwordText)
                                .padding()
                                .frame(width: metrics.size.width*0.6, height: metrics.size.height*0.06)
                                .background(getInputFieldColour())
                                .cornerRadius(10)
                            Button("Σύνδεση"){
                                loginButtonDisabled = true
                                loginErr = ""
                                if(usernameText.isEmpty){
                                    loginErr = "Το όνομα χρήστη δεν μπορεί να είναι άδειο"
                                    loginButtonDisabled = false
                                    return
                                }
                                if(passwordText.isEmpty){
                                    loginErr = "O κωδικός δεν μπορεί να είναι άδειος"
                                    loginButtonDisabled = false
                                    return
                                }
                                showActivity = 1.0
                                let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
                                dispatchQueue.async{
                                    Task{
                                        await login(usernameText, passwordText)
                                    }
                                }
                            }
                            .disabled(loginButtonDisabled)
                            .foregroundColor(.white)
                            .frame(width: metrics.size.width*0.6, height: metrics.size.height*0.06)
                            .background(Color.blue)
                            .cornerRadius(10)
                            Text(loginErr)
                                .fontWeight(.thin)
                                .foregroundColor(Color.red)
                                .multilineTextAlignment(.leading)
                            Button("Δεν έχεις λογαριασμό?\nΚάνε εγγραφή"){
                                
                            }
                        
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }.ignoresSafeArea(.keyboard)
            .navigate(to: MainView(), when: $move)
            .alert(isPresented: $loginAlert) {
                        Alert(
                            title: Text("Σφάλμα"),
                            message: Text("Η σύνδεση δεν ήταν επιτυχής. \nΠαρακαλώ επιβεβαιώστε τα στοιχεία σας.\nΕπιπλέον πληροφορίες: " + UStaticFunctionUtilities.getRestHandler().getLatestError())
                        )
                    }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
