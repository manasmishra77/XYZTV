//
//  JCTextField.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 13/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCTextField: UITextField,UITextFieldDelegate
{
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            self.attributedPlaceholder = NSAttributedString(string: "Jio ID", attributes: [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1)])
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.textColor = .black
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3597708972)
            self.attributedPlaceholder = NSAttributedString(string: "Jio ID", attributes: [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.3607843137, green: 0.3607843137, blue: 0.3607843137, alpha: 1)])
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
