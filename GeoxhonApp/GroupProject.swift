//
//  GroupProject.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 22/11/22.
//

import Foundation
import SwiftUI
class AGroupProject: Identifiable, ObservableObject{
    internal var id:Int
    internal var groupName: String
    internal var groupDetails: String
    internal var groupCreator: String
    internal var groupSubjectId: String
    internal var groupSubject: ASubject?
    @Published var uniqueId: Int
    @Published var groupLikes: Int
    @Published var hasLiked:Bool
    init(_ id: Int, _ name:String, _ details: String, _ creator: String, _ subjectId: String, _ likes:Int, _ hasLiked: Bool){
        self.id = id
        self.groupName = name
        self.groupDetails = details
        self.groupCreator = creator
        self.groupSubjectId = subjectId
        self.groupLikes = likes
        self.hasLiked = hasLiked
        self.uniqueId = 2*id + 3*likes
    }
    
    public func getLikes()->Int{
        return self.groupLikes
    }
    
    public func hasUserLiked()->Bool{
        return self.hasLiked
    }
    
    public func getName() -> String{
        return self.groupName
    }
    
    public func getDetails() -> String{
        return self.groupDetails
    }
    
    public func getCreator() -> String{
        return self.groupCreator
    }
    
    public func getSubject() -> ASubject{
        if groupSubject != nil{
            return groupSubject!
        }
        let subjects = UStaticFunctionUtilities.getSubjects()
        for i in 0 ... subjects.count - 1{
            if(subjects[i].getId() == groupSubjectId){
                self.groupSubject = subjects[i]
                return self.groupSubject!
            }
        }
        return ASubject("", "")
    }
    
    public func getId() -> Int{
        return self.id
    }
    
    public func setLikes(_ newLikes: Int){
        self.uniqueId = self.id*2 + newLikes*3
        self.groupLikes = newLikes
    }
    
    public func setHasLiked(_ newHasLiked: Bool){
        self.hasLiked = newHasLiked
    }
}
