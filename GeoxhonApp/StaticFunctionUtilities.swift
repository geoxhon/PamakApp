//
//  StaticFunctionUtilities.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 16/11/22.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
/*
 This is a a helper class that ensures data is consistent across all views.
 */
class UStaticFunctionUtilities{
    private static var restHandler: URestHandler = URestHandler()
    private static var subjects: [ASubject] = []
    private static var currentSubject: ASubject = ASubject("", "")
    private static var restaurantMenu: [FRestaurantMenu] = []
    private static var currentUser: AUser?
    private static var availableProjects: [AGroupProject] = []
    static func getRestHandler() -> URestHandler{
        return restHandler
    }
    static func getSubjects() -> [ASubject]{
        return subjects;
    }
    static func insertSubject(_ newSubjectName:String, _ subjectId:String){
        subjects.append(ASubject(newSubjectName, subjectId))
    }
    static func setCurrentSubject(_ newCurrentSubject:ASubject){
        currentSubject = newCurrentSubject
    }
    static func getCurrentSubject()->ASubject{
        return currentSubject
    }
    
    static func addMenu(_ day:FRestaurantMenu){
        restaurantMenu.append(day)
    }
    static func getRestaunrantMenu()->[FRestaurantMenu]{
        return restaurantMenu
    }
    
    static func getTodaysMenu()->FRestaurantMenu{
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"{
            return FRestaurantMenu()
        }
        var day = Date().dayNumberOfWeek()!
        day = day - 2
        print(restaurantMenu)
        if(day == -1){
            return restaurantMenu[6]
        }else{
            return restaurantMenu[day]
        }
    }
    static func setCurrentUser(_ user:AUser){
        currentUser = user
    }
    static func getCurrentUser()->AUser{
        return currentUser ?? AUser("", "", "", 0)
    }
    
    static func addProject(_ newProject: AGroupProject){
        if(availableProjects.count > 0){
            for i in 0 ... availableProjects.count - 1{
                if(availableProjects[i].getId() == newProject.getId()){
                    return
                }
            }
        }
        availableProjects.append(newProject)
    }
    
    static func clearProjects(){
        availableProjects = []
    }
    
    static func getProjects() -> [AGroupProject]{
        return availableProjects
    }
}
