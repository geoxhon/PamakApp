//
//  FilesView.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 18/11/22.
//

import Foundation
import SwiftUI
import CustomAlert
enum EFileType{
    case image, video, document
}
struct FSubjectContentExplore: View{
    @State var subject: ASubject
    @State var filetype: EFileType
    init(_ associatedSubject: ASubject, _ type: EFileType){
        _subject = State(initialValue: associatedSubject)
        _filetype = State(initialValue: type)
    }
    var body: some View{
        NavigationStack(){
            List(){
                switch filetype{
                case .image:
                    ForEach(0 ..< subject.getImageFiles().count){
                        value in
                        NavigationLink(destination: FFileExplore(file: subject.getImageFiles()[value])){
                            VStack(){
                                HStack(){
                                    Text(subject.getImageFiles()[value].getName())
                                    Spacer()
                                }
                                HStack(){
                                    Text(subject.getImageFiles()[value].getSizeText())
                                    Spacer()
                                }
                            }
                        }
                    }
                case .video:
                    ForEach(0 ..< subject.getVideoFiles().count){
                        value in
                        NavigationLink(destination: FFileExplore(file: subject.getVideoFiles()[value])){
                            VStack(){
                                HStack(){
                                    Text(subject.getVideoFiles()[value].getName())
                                    Spacer()
                                }
                                HStack(){
                                    Text(subject.getVideoFiles()[value].getSizeText())
                                    Spacer()
                                }
                            }
                        }
                    }
                case .document:
                    ForEach(0 ..< subject.getDocumentFiles().count){
                        value in
                        NavigationLink(destination: FFileExplore(file: subject.getDocumentFiles()[value])){
                            VStack(){
                                HStack(){
                                    Text(subject.getDocumentFiles()[value].getName())
                                    Spacer()
                                }
                                HStack(){
                                    Text(subject.getDocumentFiles()[value].getSizeText())
                                    Spacer()
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
}


struct FFileExplore: View{
    var file: AFile
    @State var presentAlert = false
    @State var presentAccessGrantedAlert = false
    @State var presentFailAlert = false
    @Environment(\.colorScheme) var colorScheme
    func getTextColor() -> Color {
        switch colorScheme {
        case .light:
            return .black
        case .dark:
            return .white
        }
    }
    var body: some View{
        GeometryReader{
            metrics in
            VStack {
                Text("Έχεις αιτηθεί το αρχείο: " + file.getName())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .alert(isPresented: $presentFailAlert){
                        Alert(
                            title: Text("Σφάλμα"),
                            message: Text("Ένα σφάλμα προέκυψε κατά την ανάκτηση του αρχείου.")
                        )
                    }
                HStack {
                    Spacer()
                    VStack(){
                        Spacer()
                        Button(){
                            presentAlert = true
                            UStaticFunctionUtilities.getRestHandler().downloadFile(file, finished: {
                                wasSuccess, savedURL in
                                presentAlert = false
                                if(wasSuccess){
                                    DispatchQueue.main.async { () -> Void in
                                        let controller = UIDocumentInteractionController(url: savedURL)
                                        print(savedURL)
                                        controller.delegate = file
                                        controller.presentPreview(animated: true)
                                     }
                                }else{
                                    presentAlert = false
                                    presentFailAlert = true
                                }
                            }, finishedAccessGranted: {
                                wasSuccess in
                                if(wasSuccess){
                                    presentAlert = false
                                    presentAccessGrantedAlert = true
                                }else{
                                    presentAlert = false
                                    presentFailAlert = true
                                }
                            })

                        }label:{
                            HStack(){
                                Image(systemName: "square.and.arrow.down")
                                Text("Λήψη " + file.getSizeText())
                            }
                        }
                        .foregroundColor(.white)
                        .frame(width: metrics.size.width*0.8, height: metrics.size.height*0.08)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    Spacer()
                }
            }
            .frame(width: metrics.size.width)
            .customAlert(isPresented: $presentAlert){
                HStack(){
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: getTextColor()))
                    Text("Παρακαλώ Περιμένετε")
                        .padding(.leading)
                }
                
            } actions:{
                
            }
            .alert(isPresented: $presentAccessGrantedAlert){
                Alert(
                    title: Text("Επιτυχία"),
                    message: Text("Το μέγεθος του αρχείου είναι πολύ μεγάλο, σας έχει χορηγηθεί πρόσβαση στο Google Drive")
                )
            }
        }
    }
}
struct FFileExplore_Previews: PreviewProvider {
    static var previews: some View {
        FFileExplore(file: AFile("SubjectName", "id", 10000, "video"))
    }
}
