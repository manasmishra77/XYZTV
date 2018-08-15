//
//  EnterPinViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/13/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

protocol EnterPinViewModelDelegate {
    func pinVerification(_ isSucceed: Bool)
}

class EnterPinViewModel: NSObject {
    var contentName: String
    var delegate: EnterPinViewModelDelegate
    
    init(contentName : String, delegate: EnterPinViewModelDelegate) {
        self.contentName = contentName
        self.delegate = delegate
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

extension EnterPinViewModel: EnterParentalPinViewDelegate {
    func didClickOnSubmitButton(_ pin: String) -> Bool {
        if checkPin(pin) {
            ParentalPinManager.shared.isPinOnceVerifiedWithinTheSession = true
            delegate.pinVerification(true)
            return true
        }
        return false
    }
}


