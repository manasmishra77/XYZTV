//
//  EnterPINViewController.swift
//  JioCinema
//
//  Created by Shweta Adagale on 13/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol EnterParentalPinViewDelegate: NSObjectProtocol {
    func didClickOnSubmitButton(_ pin: String) -> Bool
}

class EnterParentalPinView: UIView {
    
    var myPreferdFocusedView : UIView?
    
    var password: String = ""
    weak var delegate: EnterParentalPinViewDelegate?
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var keyBoardView: UIStackView!
    
    @IBOutlet var passwordLabelArray: [UILabel]!
    override func awakeFromNib() {
        cancelButton.setTitleColor(#colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1), for: .focused)
        playButton.setTitleColor(#colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1), for: .focused)
        myPreferdFocusedView = keyBoardView
        self.updateFocusIfNeeded()
        self.setNeedsFocusUpdate()
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        self.sendParentalPINAskEvent(userAction: "Play")
        if delegate?.didClickOnSubmitButton(password) ?? false {
        }
        password = ""
        self.setLabel(password)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.sendParentalPINAskEvent(userAction: "Cancel")
        let topVC = UIApplication.topViewController()
        topVC?.dismiss(animated: true, completion: nil)
    }
    
    func sendParentalPINAskEvent(userAction: String) {
        // For Clever Tap Event
        let eventProperties = ["platform":"TVOS", "User Action": userAction]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "PIN Asked", properties: eventProperties)
        
        // For Internal Analytics Event
        let parentalPinAskEvent = JCAnalyticsEvent.sharedInstance.getParentalPINAskEvent(userAction: userAction)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: parentalPinAskEvent)
    }
    
    @IBAction func onTapOfNumKeyboard(_ sender: UIButton) {
        myPreferdFocusedView = nil
        if(sender.tag == -1){
            if(password.count == 0) {
                return
            } else {
                
                let truncatedPass: String = password.substring(to: password.index(before: password.endIndex)) //String(password[..<password.endIndex])
                //.substring(to: password.index(before: password.endIndex))
                password = truncatedPass
                setLabel(password)
            }
        } else {
            if(password.count < 4) {
                password = password + "\(sender.tag)"
                setLabel(password)
            }
        }
    }
    
    func setLabel(_ pass:String) {
        if(pass.count <= 4){
            playButton.isEnabled = false
            for i in 0...3{
                passwordLabelArray[i].text = ""
                passwordLabelArray[i].layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            }
            for i in 0..<pass.count{
                passwordLabelArray[i].text = "●"
                passwordLabelArray[i].textColor = #colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1)
                passwordLabelArray[i].layer.borderColor = #colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1)
            }
            if(pass.count == 4) {
                playButton.isEnabled = true
                myPreferdFocusedView = playButton
                self.updateFocusIfNeeded()
                self.setNeedsFocusUpdate()
            }
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferedView = myPreferdFocusedView {
            return [preferedView]
        }
        return []
    }
}
