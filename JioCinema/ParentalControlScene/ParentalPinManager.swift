//
//  ParentalPinManager.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/14/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class ParentalPinManager: NSObject {
    static let shared = ParentalPinManager()
    private override init() {
        super.init()
    }
    
    var parentalPinModel: ParentalPinModel?
    var sessionDuration = 0
    var sessionStartTime: Date?
    var isPinActive: Bool {
        guard let sessionStartTime = sessionStartTime else {
            return false
        }
        return (Int(sessionStartTime.timeIntervalSinceNow) < sessionDuration)
    }
    
    func setParentalPinModel() {
        guard JCLoginManager.sharedInstance.isUserLoggedIn() else {return}
        RJILApiManager.defaultManager.getParentalPinForContentFromServer(completion: {[unowned self] (parentalPinModel) in
            self.parentalPinModel = parentalPinModel
        })
    }
    
    func userLoggedOut() {
        resetManager()
    }
    func resetManager() {
        parentalPinModel = nil
        sessionDuration = 0
        sessionStartTime = nil
    }

}
