//
//  MainView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 15/11/22.
//

import SwiftUI
import KeychainAccess
struct MainView: View {
    @State var cum:Int = 1
    var body: some View {
            
        TabView(selection: $cum) {
                WelcomeView()
                .tabItem {
                    HStack {
                        Image(systemName: "house")
                        Text("Αρχική")
                    }
                }
                .tag(1)
                SubjectsView()
                .navigationTitle("Μαθήματα")
                .tabItem {
                    HStack {
                        Image(systemName: "book")
                        Text("Μαθήματα")
                    }
                }
                .tag(2)
                FProjectsView()
                .tabItem{
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                        Text("Εργασίες")
                    }
                }
                .tag(3)
                FRestaurantView()
                .tabItem{
                    HStack {
                        Image(systemName: "fork.knife")
                        Text("Λέσχη")
                    }
                }
                .tag(4)
            }
        
    }
}

struct FRestaurantMenuView: View{
    @State var menuTextDay: String
    @State var menuTextNight: String
    init(_ menu:FRestaurantMenu){
        _menuTextDay = State(initialValue: String("Κυρίως: "+menu.dayMeal+"\nΧορτοφαγικό: "+menu.daySpecial+"\nΣαλάτα: "+menu.daySalad+"\nΓλυκό: "+menu.dayDesert))
        _menuTextNight = State(initialValue: String("Κυρίως: "+menu.nightMeal+"\nΧορτοφαγικό: "+menu.nightSpecial+"\nΣαλάτα: "+menu.nightSalad+"\nΓλυκό: "+menu.nightDesert))
    }
    var body: some View{
        VStack(alignment: .leading, spacing:20){
            
            GroupBox(label: Label("Mεσημεριανό", systemImage: "sun.max")){
                ScrollView(.vertical){
                    Text(menuTextDay)

                }
            }
            GroupBox(label: Label("Βραδινό", systemImage: "moon.fill")){
                ScrollView(.vertical){
                    Text(menuTextNight)
                }
            }
            .padding(.bottom)
                
        }
        .padding(.top)
    }
}


struct FRestaurantView: View{
    var body: some View{
        List(){
            ForEach(UStaticFunctionUtilities.getRestaunrantMenu(), id: \.self) { menu in
                Section(header: Text(menu.day)){
                    FRestaurantMenuView(menu)
                }
            }
        }
    }
}


struct WelcomeView: View {
    var body: some View{
        List(){
            NavigationStack(){
                NavigationLink(destination: FProfileView())
                    {
                    HStack {
                        VStack(){
                            HStack {
                                Text("Καλώς Ήρθες")
                                    .font(.title)
                                Spacer()
                            }
                            HStack {
                                Text(UStaticFunctionUtilities.getCurrentUser().getName())
                                Spacer()
                            }
                        }
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            Section(header: Text("Σήμερα στην λέσχη")){
                FRestaurantMenuView(UStaticFunctionUtilities.getTodaysMenu())
            }.headerProminence(.increased)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

