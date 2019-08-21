//
//  EnterPinViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/13/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

protocol EnterPinViewModelDelegate: NSObject {
    func pinVerification(_ isSucceed: Bool)
}

class EnterPinViewModel: NSObject {
    var contentName: String
    weak var delegate: EnterPinViewModelDelegate?
    
    init(contentName : String, delegate: EnterPinViewModelDelegate) {
        self.contentName = contentName
        self.delegate = delegate
        super.init()
        self.sendParentalPINAskEvent()
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

    func sendParentalPINAskEvent() {
        // For Clever Tap Event
        let eventProperties = ["platform":"TVOS"]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "PIN Asked", properties: eventProperties)
        // For Internal Analytics Event
        let parentalPinAskedEvent = JCAnalyticsEvent.sharedInstance.getParentalPINEntryViewedEvent()
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: parentalPinAskedEvent)
    }
    
    func sendParentalPINEntryStatusEvent(resultStatus: String, errorString: String?) {
        // For Clever Tap Event
        var eventProperties = ["platform":"TVOS", "Result": resultStatus]
        if let error = errorString {
            eventProperties = ["platform":"TVOS", "Result": resultStatus, "PIN Entry Error": error]
        }
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "PIN Entry Status", properties: eventProperties)
        // For Internal Analytics Event
        let parentalPinEntryStatusEvent = JCAnalyticsEvent.sharedInstance.getParentalPINEntryStatusEvent(resultStatus: resultStatus, errorString: errorString)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: parentalPinEntryStatusEvent)
    }
    
    
}

extension EnterPinViewModel: EnterParentalPinViewDelegate {
    func didClickOnSubmitButton(_ pin: String) -> Bool {
        if checkPin(pin) {
            ParentalPinManager.shared.isPinOnceVerifiedWithinTheSession = true
            self.sendParentalPINEntryStatusEvent(resultStatus: "Success", errorString: nil)
            delegate?.pinVerification(true)
            return true
        }
        else {
            self.sendParentalPINEntryStatusEvent(resultStatus: "Failure", errorString: ValidPinAlertMsg)
            Utility.sharedInstance.showAlert(viewController: nil, title: "", message: ValidPinAlertMsg)
        }
        return false
    }
}


