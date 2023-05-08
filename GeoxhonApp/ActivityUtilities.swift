//
//  ActivityUtilities.swift
//  PoopyApp
//
//  Created by Γεώργιος Χονδροματίδης on 17/11/22.
//

import Foundation
import SwiftUI
class UActivityUtilities{
    private var activityReserved: Bool = false
    private var reservedBy: Any = EmptyView()
    public func isActivityPending()->Bool{
        return activityReserved
    }
    public func reserveActivity(_ reservationObject: Any){
        if(!self.activityReserved){
            self.activityReserved = true
            self.reservedBy = reservationObject
        }
    }
    public func activityFinished(_ reservationObject: Any){
        if(self.activityReserved){
            self.activityReserved = false
        }
    }
}
