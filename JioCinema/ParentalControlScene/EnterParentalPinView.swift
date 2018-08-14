//
//  EnterPINViewController.swift
//  JioCinema
//
//  Created by Shweta Adagale on 13/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class EnterParentalPinView: UIView {

    var password : String = ""
    
    @IBOutlet weak var playButton: UIButton!
   
    @IBOutlet var passwordLabelArray: [UILabel]!
    
    @IBAction func onTapOfNumKeyboard(_ sender: UIButton) {
        if(sender.tag == -1){
            if(password.count == 0){
                return
            } else{
                let truncatedPass : String = password.substring(to: password.index(before: password.endIndex))
                password = truncatedPass
                setLabel(password)
                returnPass()
            }
        } else {
            if(password.count < 4){
                password = password + "\(sender.tag)"
                setLabel(password)
                returnPass()
            }
        }
    }
    func setLabel(_ pass:String){
        if(pass.count <= 4){
            playButton.isEnabled = false
            for i in 0...3{
                passwordLabelArray[i].text = ""
            }
            for i in 0..<pass.count{
                passwordLabelArray[i].text = "●"
            }
            if(pass.count == 4){
                playButton.isEnabled = true
            }
        }
    }
    func returnPass(){
        print(password)
    }
}
