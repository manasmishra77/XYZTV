//
//  EnterPINViewController.swift
//  JioCinema
//
//  Created by Shweta Adagale on 13/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol EnterParentalPinViewDelegate {
    func didClickOnSubmitButton(_ pin: String) -> Bool
}

class EnterParentalPinView: UIView {
    
    var myPreferdFocusedView : UIView?
    
    var password: String = ""
    var delegate: EnterParentalPinViewDelegate?
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet var passwordLabelArray: [UILabel]!
    override func awakeFromNib() {
        cancelButton.setTitleColor(#colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1), for: .focused)
        playButton.setTitleColor(#colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1), for: .focused)
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        if delegate?.didClickOnSubmitButton(password) ?? false {
        }
        password = ""
        self.setLabel(password)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let topVC = UIApplication.topViewController()
        topVC?.dismiss(animated: true, completion: nil)
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
            }
            for i in 0..<pass.count{
                passwordLabelArray[i].text = "●"
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
