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
    
    var parentalPinModel: ParentalPinModel? {
        didSet {
            if parentalPinModel != nil {
                sessionStartTime = Date()
            }
        }
    }
    var sessionDuration: Int? {
        get {
            if let sessionString = JCDataStore.sharedDataStore.configData?.configDataUrls?.parentalSession, let sessionInt = Int(sessionString) {
                return sessionInt
            }
            return nil
        }
        set {
            //Setting when user logging out
            JCDataStore.sharedDataStore.configData?.configDataUrls?.parentalSession = nil
        }
        
    }
    
    var isPinOnceVerifiedWithinTheSession: Bool = false
    
    private var sessionStartTime: Date?
    
    var isPinActive: Bool {
        guard let sessionStartTime = sessionStartTime else {
            return false
        }
        if (Int(sessionStartTime.timeIntervalSinceNow) < (sessionDuration ?? 0)) {
            return true
        }
        isPinOnceVerifiedWithinTheSession = false
        return false
    }
    var allowedCategory: AgeGroup {
        return ParentalPinManager.shared.parentalPinModel?.parentalSettings?.allowedAgeGrpCategory ?? .allAge
    }
    
    func setParentalPinModel() {
        guard JCLoginManager.sharedInstance.isUserLoggedIn() else {return}
        RJILApiManager.defaultManager.getParentalPinForContentFromServer(completion: {[unowned self] (parentalPinModel) in
            self.parentalPinModel = parentalPinModel
        })
    }
    
    func checkParentalPin(_ maturityRating: AgeGroup) -> Bool {
        if ParentalPinManager.shared.isPinActive {
            if isPinOnceVerifiedWithinTheSession {
                return false
            }
            if maturityRating.ageIntValue < (ParentalPinManager.shared.allowedCategory.ageIntValue) {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    static var shouldShowFirstTimeParentalControlAlert: Bool {
        if((UserDefaults.standard.value(forKey: isParentalControlShown)) != nil) {
            return false
        }
        else {
            UserDefaults.standard.setValue(true, forKeyPath: isParentalControlShown)
            return true
        }
    }
    
    var parentalControlStatus: String {
        if(JCLoginManager.sharedInstance.isUserLoggedIn()){
            if parentalPinModel != nil {
                if isPinActive {
                    return "ON"
                }
                else {
                    return "OFF"
                }
            }
        }
        return ""
    }
    
    func userLoggedOut() {
        resetManager()
    }
    func resetManager() {
        parentalPinModel = nil
        sessionDuration = nil
        sessionStartTime = nil
    }
    
}
