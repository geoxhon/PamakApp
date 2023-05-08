//
//  SignUpView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 5/12/22.
//

import Foundation
import SwiftUI

struct FSignUpView: View {
    
    var body: some View{
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
                        Text("Εγγραφή")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    .padding(.top, metrics.size.height * -0.28)
                }
            }
        }
    }
    
}
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        FSignUpView()
    }
}
