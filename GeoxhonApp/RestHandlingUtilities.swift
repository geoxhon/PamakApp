//
//  RestHandlingUtilities.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 16/11/22.
//

import Foundation
import SwiftUI
import KeychainAccess
struct FRestResponse{
    var isSuccess:Int = 0
    var jsonResponse:[String: Any] = ["":""]
}

struct FRestaurantMenu: Hashable{
    var day: String = ""
    var dayMeal:String = ""
    var daySpecial:String = ""
    var dayExtra:String = ""
    var daySalad:String = ""
    var dayDesert:String = ""
    var nightMeal:String = ""
    var nightSpecial:String = ""
    var nightExtra:String = ""
    var nightSalad:String = ""
    var nightDesert:String = ""
}

class HTTPRequestHandler{
    private var cookie:String = ""
    private var errorString:String = ""
    func getLatestError() ->String{
        return errorString
    }
    /// Send a GET request that retrieves a file from a remote server.
    /// - Parameters:
    ///   - path: URL to send the request
    ///   - finished: Function to call after the request has been processed
    func GETFILE(_ path:String, finished: @escaping (_ wasSuccessful:Bool, _ saveLocation: URL)->Void){
        guard let url = URL(string: path) else {return}
        let task = URLSession.shared.downloadTask(with: url){
            (data, response, error) in
            guard let fileURL =  data else {finished(false, url); return}
            do {
                finished(true, fileURL)
                
            } catch {
                print ("file error: \(error)")
                finished(false, url)
            }
        }
        task.resume()
    }
    /// Send a POST request to a remote server.
    /// - Parameters:
    ///   - path: URL to send the request
    ///   - data: JSON String to send post data
    ///   - finished: Function to call after the request has been processed
    func POST(_ path:String, _ data:String, finished: @escaping (_ result: FRestResponse)->Void){
        guard let jsonData = data.data(using: .utf8) else {finished(FRestResponse()); return}
        guard let url = URL(string: path) else {finished(FRestResponse()); return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(data)
            if let error = error {
                finished(FRestResponse())
                return
            } else if let data = data {
                // Handle HTTP request response
                
                if let httpResponse = response as? HTTPURLResponse {
                     if let authCookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                         let authCookieArray = authCookie.components(separatedBy: ";")
                         self.cookie = authCookieArray[0]
                     }
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let success = responseJSON?["success"] as? Int{
                    var finalResponse: FRestResponse = FRestResponse()
                    finalResponse.jsonResponse = responseJSON!
                    finalResponse.isSuccess = success
                    print(response)
                    
                    finished(finalResponse)
                    return
                }else{
                    if let reason = responseJSON?["reason"] as? String{
                        self.errorString = reason
                    }
                }
                finished(FRestResponse())
                return
            } else {
                finished(FRestResponse())
                return
            }
        }
        task.resume()
    }
    /// Send a GET request to a remote server.
    /// - Parameters:
    ///   - path: URL to send the request
    ///   - finished: Function to call after the request has been processed
    func GET(_ path:String, finished: @escaping (_ result: FRestResponse)->Void){
        guard let url = URL(string: path) else {finished(FRestResponse()); return}
        var request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                finished(FRestResponse())
                return
            } else if let data = data {
                // Handle HTTP request response
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let success = responseJSON?["success"] as? Int{
                    var finalResponse: FRestResponse = FRestResponse()
                    finalResponse.jsonResponse = responseJSON!
                    finalResponse.isSuccess = success
                    finished(finalResponse)
                    return
                }
                finished(FRestResponse())
                return
            } else {
                finished(FRestResponse())
                return
            }
        }
        task.resume()
    }
    /// Send a GET reques to a remote server and await for the response
    /// - Parameters:
    ///   - path: URL to send the request
    /// - Returns: FRestResponse with the result of the request
    func GET_AWAIT(_ path:String) async -> FRestResponse{
        guard let url = URL(string: path) else {return FRestResponse()}
        var request = URLRequest(url: url)
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let success = responseJSON?["success"] as? Int{
                var finalResponse: FRestResponse = FRestResponse()
                finalResponse.jsonResponse = responseJSON!
                finalResponse.isSuccess = success
                return finalResponse
            }
        }catch{
            return FRestResponse()
        }
        return FRestResponse()
    }
    
}
/*
 This class helps connect the application to the Rest API
 */
class URestHandler{
    public var requests: HTTPRequestHandler
    private var errorString: String = ""
    init(){
        requests = HTTPRequestHandler()
    }
    func getLatestError() ->String{
        return self.errorString
    }
    /// Request to download a file from the API
    /// If the file is larger than 100MB then access will be granted through Google Drive to the users email.
    /// - Parameters:
    ///   - file: The file to download
    ///   - finished: The function to call when the download has finished, also returns the save location of the file
    func downloadFile(_ file: AFile, finished: @escaping (_ wasSuccessful:Bool, _ saveLocation: URL)->Void, finishedAccessGranted: @escaping(_ wasSuccessful: Bool)->Void){
        if (file.getSize()/1024)/1024 > 100{
            requests.GET("https://dai.geoxhonapps.com/api/v1/subjects/files/download?file="+file.getId(), finished: {
                result in
                finishedAccessGranted(result.isSuccess==1)
            })
            return
        }
        requests.GETFILE("https://dai.geoxhonapps.com/api/v1/subjects/files/download?file="+file.getId(), finished: {
            wasSuccess, savedAt in
            do{
                let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
                
                let savedURL = documentsURL.appendingPathComponent(file.getName())
                try? FileManager.default.removeItem(at: savedURL)
                try FileManager.default.moveItem(at: savedAt, to: savedURL)
                finished(true, savedURL)
            }catch {
                finished(false, savedAt)
            }
        })
    }
    /// Request the restaurant menu for the week
    /// The result is saved in StaticFunctionUtitlities
    /// - Parameters:
    ///   - finished: The function to call when the request has been processed
    func getRestaurantMenu(finished: @escaping () ->Void){
        requests.GET("https://dai.geoxhonapps.com/api/v1/restaurant/menu", finished: {
            result in
            if(result.isSuccess == 1){
                if let triggerResults = result.jsonResponse["triggerResults"] as? [[String: String]]{
                    for i in 0 ... triggerResults.count - 1{
                        var menu = FRestaurantMenu()
                        menu.day = triggerResults[i]["day"]!
                        menu.dayMeal = triggerResults[i]["gevmaKirios"]!
                        menu.daySpecial = triggerResults[i]["gevmaEidiko"]!
                        menu.dayExtra = triggerResults[i]["gevmaGarnitoura"]!
                        menu.daySalad = triggerResults[i]["gevmaSalata"]!
                        menu.dayDesert = triggerResults[i]["gevmaEpidorpio"]!
                        menu.nightMeal = triggerResults[i]["deipnoKirios"]!
                        menu.nightSpecial = triggerResults[i]["deipnoEidiko"]!
                        menu.nightExtra = triggerResults[i]["deipnoGarnitoura"]!
                        menu.nightSalad = triggerResults[i]["deipnoSalata"]!
                        menu.nightDesert = triggerResults[i]["deipnoEpidorpio"]!
                        UStaticFunctionUtilities.addMenu(menu)
                    }
                    
                }
            }
            finished()
        })
    }
    /// Attempt to authenticate the user through a refresh token.
    /// This function is intended to be used only at the start of the application.
    /// - Parameters:
    ///   - token: The refresh token to use for authentication
    ///   - startUpViewInstance: The initial view instance of the application. The function will move the application to the main screen shall authentication be sucessful, otherwise it will navigate to the login screen.
    func doLoginToken(_ token:String, _ startupViewInstance: FStartUpView){
        requests.POST("https://dai.geoxhonapps.com/api/v1/auth/token/refresh/?refreshToken="+token, "{}", finished:{
            result in
            if result.isSuccess == 1{
                print(result.jsonResponse)
                let triggerResults = result.jsonResponse["triggerResults"] as? [String: Any]
                let username = triggerResults?["displayName"] as? String ?? "NO USERNAME"
                let email = triggerResults?["email"] as? String ?? "NO EMAIL"
                let id = triggerResults?["id"] as? String ?? "NO ID"
                let keychain = Keychain(service: "com.geoxhonapps.dai")
                keychain["refreshToken"] = triggerResults?["refreshToken"] as? String ?? "NO ID"
                let specialSccess = triggerResults?["specialAccess"] as? Int ?? 0
                UStaticFunctionUtilities.setCurrentUser(AUser(id, username, email, specialSccess))
                self.getSubjects()
                self.getAvailableProjects()
                self.getRestaurantMenu(finished: {
                    startupViewInstance.moveToMain = true
                })
            }else{
                startupViewInstance.moveToLogin = true
            }
        })
    }
    /// Attempt to authenticate the user with the API via Username & Password combination
    /// This function is intended to be called only from the login screen
    /// - Parameters:
    ///   - username: The users username
    ///   - password: The users password.
    ///   - contentViewInstance: The instance of the login screen.
    func doLogin(_ username:String, _ password:String, _ contentViewInstance: ContentView) -> Bool{
        var jsonString:String = "{ \"username\" : \""+username+"\", \"password\" : \""+password+"\"  }"
        requests.POST("https://dai.geoxhonapps.com/api/v1/auth/login/", jsonString, finished: {
            result in
            if result.isSuccess == 1{
                let triggerResults = result.jsonResponse["triggerResults"] as? [String: Any]
                let username = triggerResults?["displayName"] as? String ?? "NO USERNAME"
                let email = triggerResults?["email"] as? String ?? "NO EMAIL"
                let id = triggerResults?["id"] as? String ?? "NO ID"
                let specialSccess = triggerResults?["specialAccess"] as? Int ?? 0
                let keychain = Keychain(service: "com.geoxhonapps.dai")
                keychain["refreshToken"] = triggerResults?["refreshToken"] as? String ?? "NO ID"
                UStaticFunctionUtilities.setCurrentUser(AUser(id, username, email, specialSccess))
                self.getSubjects()
                self.getAvailableProjects()
                self.getRestaurantMenu(finished: {
                    contentViewInstance.move = true
                })
            }else{
                self.errorString = try! result.jsonResponse["reason"] as? String ?? "Σφάλμα Δικτύου"
                contentViewInstance.loginAlert = true
            }
        })
        return false
    }
    /// Logout the user from the API, and remove the refresh token from the device.
    func doLogout(){
        let keychain = Keychain(service: "com.geoxhonapps.com")
        keychain["refreshToken"] = "NO ID"
        requests.GET("https://dai.geoxhonapps.com/api/v1/auth/logout", finished:{result in})
    }
    /// Get all avaiable subjects from the API, the sujects are saved in UStaticFunctionUtilities
    /// Only needs to be called once.
    func getSubjects(){
        requests.GET("https://dai.geoxhonapps.com/api/v1/subjects/", finished: {
            result in
            if result.isSuccess == 1{
                
                let triggerResults = result.jsonResponse["triggerResults"] as? [[String: Any]]
                for i in 0 ... ((triggerResults?.count)! - 1){
                    UStaticFunctionUtilities.insertSubject((triggerResults?[i]["name"] as? String)!, (triggerResults?[i]["gApiId"] as? String)!)
                }
            }else{
                print("requestFailed")
            }
        })
    }
    /// Retrieve all files from a specific subject
    /// The files are saved inside the ASubject instance
    /// - Parameters:
    ///   - subject: The subject to get the files.
    ///   - finished: The function to call once the files have been retrieved.
    func getSubjectFiles(_ subject: ASubject, finished: @escaping (_ loaded:Bool)->Void){
        requests.GET("https://dai.geoxhonapps.com/api/v1/subjects/files?id="+subject.getId(), finished:{
            result in
            if result.isSuccess == 1{
                if let triggerResults = result.jsonResponse["triggerResults"] as? [[String: Any]]{
                    for i in 0 ... ((triggerResults.count) - 1){
                        let fileId = ( triggerResults[i]["id"] as? String)!
                        let fileName = ( triggerResults[i]["name"] as? String)!
                        let fileSize = ( triggerResults[i]["size"] as? Int)!
                        let fileType = ( triggerResults[i]["type"] as? String)!
                       
                        subject.addFile(AFile(fileName, fileId, fileSize, fileType))
                    }
                }
                finished(true)
            
            }else{

            }
        })
    }
    /// Get all available group projects from the API, the group projects are saved in UStaticFunctionUtilities
    func getAvailableProjects(){
        requests.GET("https://dai.geoxhonapps.com/api/v1/groups", finished:{
            result in
            if result.isSuccess == 1{
                if let triggerResults = result.jsonResponse["triggerResults"] as? [[String: Any]]{
                    if(triggerResults.count>0){
                        for i in 0 ... ((triggerResults.count) - 1){
                            let id = (triggerResults[i]["id"] as? Int)!
                            let groupName = ( triggerResults[i]["groupName"] as? String)!
                            let groupDetails = ( triggerResults[i]["groupDetails"] as? String)!
                            let groupSubject = ( triggerResults[i]["groupSubject"] as? String)!
                            let groupCreator = ( triggerResults[i]["createdBy"] as? String)!
                            let groupLikes = (triggerResults[i]["likes"] as? Int)!
                            let hasLiked = (triggerResults[i]["hasLiked"] as? Bool)!
                            UStaticFunctionUtilities.addProject(AGroupProject(id, groupName, groupDetails, groupCreator, groupSubject, groupLikes, hasLiked))
                        }
                    }
                }
            }
        })
    }
    /// Send a like or dislike to a certain Group Project
    /// - Parameters:
    ///   - project: The project to like.
    func likeProject(_ project:AGroupProject){
        requests.POST("https://dai.geoxhonapps.com/api/v1/groups/likes/?project="+String(project.getId()), "", finished:{
            result in
            if result.isSuccess == 1{
                project.hasLiked.toggle()
                if(project.hasLiked == false){
                    project.groupLikes = project.groupLikes - 1
                }else{
                    project.groupLikes = project.groupLikes + 1
                }
            }
        })
    }
    /// Get all available group projects from the API but halt the program until the projects have been retrieved, the group projects are saved in UStaticFunctionUtilities
    func ASYNC_getAvailableProjects() async{
        let result = await requests.GET_AWAIT("https://dai.geoxhonapps.com/api/v1/groups")
        if result.isSuccess == 1{
            if let triggerResults = result.jsonResponse["triggerResults"] as? [[String: Any]]{
                for i in 0 ... ((triggerResults.count) - 1){
                    let id = (triggerResults[i]["id"] as? Int)!
                    let groupName = ( triggerResults[i]["groupName"] as? String)!
                    let groupDetails = ( triggerResults[i]["groupDetails"] as? String)!
                    let groupSubject = ( triggerResults[i]["groupSubject"] as? String)!
                    let groupCreator = ( triggerResults[i]["createdBy"] as? String)!
                    let groupLikes = (triggerResults[i]["likes"] as? Int)!
                    let hasLiked = (triggerResults[i]["hasLiked"] as? Bool)!
                    UStaticFunctionUtilities.addProject(AGroupProject(id, groupName, groupDetails, groupCreator, groupSubject, groupLikes, hasLiked))
                }
            }
        }
    }
    /// Request to create a group project to the API
    /// - Parameters:
    ///   - groupName: The Projects name.
    ///   - groupDetails: The details of the project.
    ///   - groupSubject: The associated Subject.
    ///   - finished: The function to call after the request has been processed. Also returns the created project and saved it in UStaticFunctionUtilities
    func createGroupProject(_ groupName:String, _ groupDetails:String, _ groupSubject:ASubject, finished: @escaping (_ wasSuccess:Bool, _ projectCreated: AGroupProject?) -> Void){
        var jsonString:String = "{ \"groupName\" : \""+groupName+"\", \"groupDetails\" : \""+groupDetails+"\", \"groupSubject\" : \""+groupSubject.getId()+"\"  }"
        requests.POST("https://dai.geoxhonapps.com/api/v1/groups/create/", jsonString, finished: {
            result in
            if result.isSuccess == 1{
                if let triggerResults = result.jsonResponse["triggerResults"] as? [String: Any]{
                    let id = (triggerResults["createdId"] as? Int)!
                    finished(true, AGroupProject(id, groupName, groupDetails, UStaticFunctionUtilities.getCurrentUser().getName(), groupSubject.getId(), 0, false))
                }else{
                    finished(false, nil)
                }
            }else{
                finished(false, nil)
            }
        })
    }
    func ASYNC_refreshGroupProjectLikes(_ project: AGroupProject) async{
        let result = await requests.GET_AWAIT("https://dai.geoxhonapps.com/api/v1/groups/likes?project="+String(project.getId()))
        if result.isSuccess == 1{
            if let triggerResults = result.jsonResponse["triggerResults"] as? [String: Any]{
                project.setLikes((triggerResults["likes"] as? Int)!)
                project.setHasLiked((triggerResults["hasLiked"] as? Bool)!)
            }
        }
    }
}
