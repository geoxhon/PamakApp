//
//  MainView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 15/11/22.
//

import SwiftUI


struct ASubjectRow: View{
    var subjectName:String = ""
    @StateObject var subject:ASubject
    @State var readyToTransition:Bool = false
    @State var contentNav: FContentNavigator
    @Environment(\.colorScheme) var colorScheme
    
    init(_ associatedSubject:ASubject){
        _subject = StateObject(wrappedValue: associatedSubject)
        _contentNav = State(initialValue: FContentNavigator(associatedSubject))
        self.readyToTransition = false
    }
    
    func getTextColour() -> Color{
        switch colorScheme {
        case .light:
            return .black
        case .dark:
            return .white
        }
    }
    
    var body: some View{
        NavigationLink(destination: contentNav
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .navigationBarTitle(self.subject.getName()))
        {
            HStack(){
                Image(systemName: "book")
                Text(subject.getName())
                Spacer()
            }
            
            .foregroundColor(getTextColour())
            .frame(maxWidth: .infinity)
            
            
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .padding(0)
        
    }
            
}


struct FContentNavigator: View{
    @State var imageCount:String = "0"
    @State var videoCount:String = "0"
    @State var documentCount:String = "0"
    @StateObject var subject:ASubject
    init(_ associatedSubject: ASubject){
        _subject = StateObject(wrappedValue: associatedSubject)
    }
    
    var body: some View{
        List(){
            NavigationLink(destination: FSubjectContentExplore(subject, .image).navigationTitle("Αρχεία")){
                HStack(){
                    Image(systemName: "photo")
                    Text("Φωτογραφίες")
                    Spacer()
                    Text(String(subject.imageFiles.count))
                }
            }.disabled(Bool(subject.imageFiles.count==0))
            NavigationLink(destination: FSubjectContentExplore(subject, .video).navigationTitle("Αρχεία")){
                HStack(){
                    Image(systemName: "video")
                    Text("Video")
                    Spacer()
                    Text(String(subject.videoFiles.count))
                }
            }.disabled(Bool(subject.videoFiles.count==0))
            NavigationLink(destination: FSubjectContentExplore(subject, .document).navigationTitle("Αρχεία")){
                HStack(){
                    Image(systemName: "doc")
                    Text("Documents")
                    Spacer()
                    Text(String(subject.documentFiles.count))
                }
            }.disabled(Bool(subject.documentFiles.count == 0))
        }
        .onAppear {
            subject.getFiles()
        }
        
    }
}
struct ASubjectContentView: View{
    private var subject: ASubject;
    init(_ associatedSubject: ASubject){
        self.subject = associatedSubject
    }
    var body: some View{
        EmptyView()
    }
}

struct SubjectsView: View{
    public var ActivityUtilies = UActivityUtilities()
    var body: some View{
        NavigationView(){
            List(){
                ForEach(0 ..< UStaticFunctionUtilities.getSubjects().count) { value in
                    ASubjectRow(UStaticFunctionUtilities.getSubjects()[value])
                    
                }
                
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .padding(0)
        
    }
}

struct SubjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectsView()
    }
}

