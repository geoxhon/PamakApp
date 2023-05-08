//
//  User.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 20/11/22.
//

import Foundation
/*
 The AUser class contains information about the currently logged in user, such as:
 1. ID
 2. Users name
 3. Users Email
 */
class AUser{
    private var id:String
    private var username:String
    private var email:String
    private var isAdmin:Bool
    init(_ id:String, _ username:String, _ email:String, _ isAdmin:Int){
        self.id = id
        self.username = username
        self.email = email
        self.isAdmin = isAdmin == 1
    }
    
    public func getName()->String{
        return self.username
    }
    public func getEmail()->String{
        return self.email
    }
    public func getId()->String{
        return self.id
    }
    
    public func getIsAdmin()->Bool{
        return self.isAdmin
    }
}
