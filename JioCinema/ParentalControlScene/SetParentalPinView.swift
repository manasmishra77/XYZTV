//
//  SetPINViewController.swift
//  JioCinema
//
//  Created by Shweta Adagale on 13/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class SetParentalPinView: UIView {
    
    private let SetPinText = "To set Parental PIN, please go to:"
    private let ResetPinText = "To reset Parental PIN, please go to:"

    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var setParentalPinHeading: UILabel!
    
    func configureParentalPinView(_ pin: String) {
        pinLabel.text = pin
        if ParentalPinManager.shared.parentalPinModel != nil {
            setParentalPinHeading.text = ResetPinText
        } else {
            setParentalPinHeading.text = SetPinText
        }
    }
    
}
