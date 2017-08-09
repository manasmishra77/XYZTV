//
//  JCPasswordField.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 13/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCPasswordField: UITextField,UITextFieldDelegate
{
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            self.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:#colorLiteral(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1)])
            self.textColor = UIColor.black
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.3)
            self.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:#colorLiteral(red: 0.4361188412, green: 0.4361297488, blue: 0.4361238778, alpha: 1)])
        }
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
