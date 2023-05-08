//
//  ProjectsView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 21/11/22.
//

import Foundation

import SwiftUI
import PopupView
struct FProjectContentView: View{
    @State var isExpanded: Bool = false
    @ObservedObject var project: AGroupProject
    @State var hasLiked:Bool = false
    @State var likes: Int = 0
    var body: some View{
        VStack {
            GroupBox(label: HStack(){
                Image(systemName: "wrench.and.screwdriver.fill")
                Spacer()
                Text(project.getName())
                    .onAppear(){
                        likes = project.getLikes()
                        hasLiked = project.hasUserLiked()
                    }
                Spacer()
                if(!isExpanded){
                    Image(systemName: "chevron.down")
                }else{
                    Image(systemName: "chevron.up")
                }
            }){
                if(isExpanded){
                    ScrollView(.vertical){
                        Text(project.getDetails())
                    }
                }
                Divider()
                HStack(){
                    Text("Από")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Text(project.getCreator())
                        .fontWeight(.light)
                }
                HStack(){
                    Text("Μάθημα")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Text(project.getSubject().getName())
                        .fontWeight(.light)
                }
            }
            .onTapGesture {
                withAnimation{
                    isExpanded.toggle()
                }
                
            }
            
            Button(action: {
                UStaticFunctionUtilities.getRestHandler().likeProject(project)
            }, label: {
                HStack(){
                    if(project.hasLiked){
                        Image(systemName: "heart.fill")
                    }else{
                        Image(systemName: "heart")
                    }
                    Text(String(project.groupLikes))
                }
            })
            .padding(.vertical)
        }
    }
}

struct FProjectsView: View{
    @State var projects = UStaticFunctionUtilities.getProjects()
    @State var presentCreateProject: Bool = false
    @State var subjects = UStaticFunctionUtilities.getSubjects()
    @State var selectedSubject: ASubject = ASubject("", "")
    @State var presentSuccessToast = false
    @State var presentFailToast = false
    @State var projectViews: [FProjectContentView] = []
    var body: some View{
        ZStack(){
            ZStack{
                VStack(){
                    HStack(){
                        NavigationLink(destination: FProfileView(), label: {
                            Image(systemName: "person.crop.circle")
                        })
                        Spacer()
                        Text("Ομαδικές Εργασίες").font(.headline)
                        Spacer()
                        Button(action: {
                            presentCreateProject.toggle()
                        }, label: {
                            Text("+").font(.largeTitle)
                        })
                    }
                    List(){
                        ForEach(projects, id: \.id) { item in
                            Section(){
                                VStack(){
                                    FProjectContentView(project: item)
                                }
                            }
                        }
                    }.refreshable {
                        projects = []
                        await UStaticFunctionUtilities.getRestHandler().ASYNC_getAvailableProjects()
                        projects = UStaticFunctionUtilities.getProjects()
                        for i in 0 ... projects.count - 1{
                            await UStaticFunctionUtilities.getRestHandler().ASYNC_refreshGroupProjectLikes(projects[i])
                        }
                        
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                }
                if presentCreateProject{
                    createProjectView
                       .zIndex(1)     // << required !!
                       .transition(.move(edge: .bottom)).animation(.default)

                }
            }
            .popup(isPresented: $presentSuccessToast, type: .toast, position: .top, autohideIn: 3) {
                VStack {
                    Spacer()
                    GroupBox(label: Label("Επιτυχία", systemImage: "checkmark.square")){
                        Text("Η ανάρτηση ολοκληρώθηκε με επιτυχία.")
                    }
                    .groupBoxStyle(TransparentGroupBox(BoxColor: .green, BoxHeight: 100))
                    .padding([.top, .horizontal])
                    
                }
                .padding(.top)
                .background(.green)
                .frame(maxWidth: .infinity, maxHeight: 100)
            }
            .popup(isPresented: $presentFailToast, type: .toast, position: .top, autohideIn: 3) {
                VStack {
                    Spacer()
                    GroupBox(label: Label("Σφάλμα", systemImage: "exclamationmark.triangle")){
                        Text("Ένα απρόσμενο σφάλμα προέκυψε.")
                    }
                    .groupBoxStyle(TransparentGroupBox(BoxColor: .red, BoxHeight: 100))
                    .padding([.top, .horizontal])
                    
                }
                .padding(.top)
                .background(.red)
                .frame(maxWidth: .infinity, maxHeight: 100)
            }
        }
        
    }
    @Environment(\.colorScheme) var colorScheme
    func getBackgroundColor() -> Color{
        switch colorScheme{
        case .dark:
            return Color(red: 44/255, green: 44/255, blue: 44/255)
        case .light:
            return Color(red: 235/255, green: 235/255, blue: 235/255)
        }
    }
    func getTextColor() -> Color{
        switch colorScheme{
        case .dark:
            return .white
        case .light:
            return .black
        }
    }
    func getPickerColor() -> Color{
        switch colorScheme{
        case .dark:
            return Color(red: 64/255, green: 64/255, blue: 64/255)
        case .light:
            return Color(red: 215/255, green: 215/255, blue: 215/255)
        }
    }
    @State var titleText: String = ""
    @State var detailsText: String = ""
    var createProjectView: some View{
        VStack(){
            HStack(){
                Button(action: {self.presentCreateProject.toggle()}, label: {
                    Image(systemName: "x.square.fill")
                })
                .foregroundColor(.white)
                .frame(width: 80, height: 40)
                .background(Color.red)
                .cornerRadius(10)
                Spacer()
                Button(action: {
                    presentCreateProject.toggle()
                    UStaticFunctionUtilities.getRestHandler().createGroupProject(titleText, detailsText, selectedSubject, finished: {
                        wasSuccess, projectCreated in
                        if(wasSuccess){
                            UStaticFunctionUtilities.addProject(projectCreated!)
                            projects.append(projectCreated!)
                            presentSuccessToast.toggle()
                        }else{
                            presentFailToast.toggle()
                        }
                    })
                }, label: {
                    Image(systemName: "paperplane.fill")
                })
                .foregroundColor(.white)
                .frame(width: 80, height: 40)
                .background(Color.blue)
                .cornerRadius(10)
            }
            HStack(){
                Text("Δημιουργεία αγγελίας για εργασία")
            }.padding(.top)
            Divider()
            TextField("Δώσε έναν τίτλο", text: $titleText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.white).opacity(0))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
            TextField("Πρόσθεσε λεπτομέρειες", text: $detailsText, axis: .vertical)
                .padding([.leading, .bottom])
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color(.white).opacity(0))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
            Spacer()
            GroupBox(label: Label("Διάλεξε ένα μάθημα", systemImage: "book")){
                Picker("Διάλεξε ένα μάθημα", selection: $selectedSubject){
                    ForEach(subjects, id: \.self){
                        item in
                        Text(item.getName())
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .foregroundColor(getTextColor())
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .foregroundColor(getTextColor())
                .cornerRadius(5)
            }
                
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(getBackgroundColor())
        
    }
}
struct TransparentGroupBox: GroupBoxStyle {
    @State var BoxColor: Color
    @State var BoxHeight: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity, maxHeight: BoxHeight)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(BoxColor))
            .overlay(configuration.label.padding(.leading, 4), alignment: .topLeading)
    }
}

struct FProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        FProjectsView()
    }
}
