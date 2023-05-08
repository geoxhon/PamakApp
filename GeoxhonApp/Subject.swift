//
//  Subject.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 16/11/22.
//

import Foundation
import SwiftUI
/*
 Class AFile contains all information about a certain file that is located inside a subject.
 */
class AFile: NSObject, UIDocumentInteractionControllerDelegate{
    private var name:String
    private var id:String
    private var size:Int
    private var fileType:String
    init(_ name:String, _ id:String, _ size:Int, _ fileType:String){
        self.name = name
        self.id = id
        self.size = size
        self.fileType = fileType
    }
    public func documentInteractionControllerViewControllerForPreview(_ controller:UIDocumentInteractionController) ->UIViewController
    {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    public func getName()->String{
        return self.name
    }
    public func getId()->String{
        return self.id
    }
    public func getSize()->Int{
        return self.size
    }
    public func getType()->String{
        return self.fileType
    }
    public func getSizeText()->String{
        if(size/1024>1024){
            return (String((size/1024)/1024)+" MB")
        }else{
            return (String(size/1024)+" KB")
        }
    }
}
/*
 Class ASubject contains all information about a given subject such as
 1. Subject Name.
 2. Files.
 3. Subject ID.
 */
class ASubject: Hashable, Identifiable, ObservableObject{
    static func == (lhs: ASubject, rhs: ASubject) -> Bool {
        return lhs.getId() == rhs.getId()
    }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
    private var name:String
    var id:String
    @Published var files = [AFile]()
    @Published var videoFiles = [AFile]()
    @Published var imageFiles = [AFile]()
    @Published var documentFiles = [AFile]()
    @Published var imageFilesCount = "0"
    @Published var videoFilesCount = "0"
    @Published var docFilesCount = "0"
    @State var hasLoadedFiles:Bool = false
    init(_ name:String, _ id:String){
        self.name = name
        self.id = id
        self.files = []
        self.videoFiles = []
        self.imageFiles = []
        self.documentFiles = []
    }
    public func getName()->String{
        return self.name
    }
    public func getId()->String{
        return self.id
    }
    
    public func addFile(_ newFile: AFile){
        if(files.count == 0 ){
            files.append(newFile)
            return
        }
        for i in 0 ... files.count - 1{
            if(files[i].getId() == newFile.getId()){
                return
            }
        }
        files.append(newFile)
        DispatchQueue.main.async {
            if(newFile.getType().contains("video")){
                self.videoFiles.append(newFile)
                self.videoFilesCount = String(self.videoFiles.count)
            }
            if(newFile.getType().contains("image")){
                self.imageFiles.append(newFile)
                self.imageFilesCount = String(self.imageFiles.count)
            }
            if(newFile.getType().contains("document")||newFile.getType().contains("pdf")){
                self.documentFiles.append(newFile)
                self.docFilesCount = String(self.documentFiles.count)
            }
        }
        

    }
    
    public func getFiles()->[AFile]{
        if(self.files.count>0){
            print(self.files)
            return self.files
        }else{
            UStaticFunctionUtilities.getRestHandler().getSubjectFiles(self, finished: {loaded in
                
            })
            return self.files
        }
    }
    
    public func getVideoFiles()->[AFile]{
        if(self.videoFiles.count > 0){
            return self.videoFiles
        }else{
            var temp:[AFile] = self.files
            if(temp.count>0){
                for i in 0 ... temp.count - 1{
                    if(temp[i].getType().contains("video")){
                        self.videoFiles.append(temp[i])
                    }
                }
            }
            return self.videoFiles
        }
    }
    
    public func getImageFiles()->[AFile]{
        if(self.imageFiles.count > 0){
            return self.imageFiles
        }else{
            var temp:[AFile] = self.files
            if(temp.count>0){
                for i in 0 ... temp.count - 1{
                    if(temp[i].getType().contains("image")){
                        self.imageFiles.append(temp[i])
                    }
                }
            }
            return self.imageFiles
        }
    }
    
    public func getDocumentFiles()->[AFile]{
        if(self.documentFiles.count > 0){
            return self.files
        }else{
            var temp:[AFile] = self.getFiles()
            if(temp.count>0){
                for i in 0 ... temp.count - 1{
                    if(temp[i].getType().contains("document")||temp[i].getType().contains("pdf")){
                        self.documentFiles.append(temp[i])
                    }
                }
            }
            return self.documentFiles
        }
    }
    
}
