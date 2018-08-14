//
//  EnterPinViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/13/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

class EnterPinViewModel: NSObject {
    var contentName: String
    
    init(contentName : String) {
        self.contentName = contentName
        super.init()

    }

    func checkPin(_ enteredPin: String) -> Bool {
        if ParentalPinManager.shared.isPinActive {
            let pin = ParentalPinManager.shared.parentalPinModel?.pin ?? ""
            return pin == enteredPin
        }
        return false
    }
    
    func getContentName() -> String {
        return contentName
    }
    
}
