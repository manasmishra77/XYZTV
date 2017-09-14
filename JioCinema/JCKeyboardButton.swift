//
//  JCKeyboardButton.swift
//  JioCinema
//
//  Created by Manas Mishra on 14/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCKeyboardButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            if context.nextFocusedView?.tag == -1{
                let backImage = UIImage(named: "back_ic_focused")
                self.setImage(backImage, for: .focused)
            }
            self.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)
            self.setTitleColor(UIColor.darkGray, for: .focused)
            self.layer.cornerRadius = 10
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        else
        {
            self.backgroundColor = UIColor.clear
            self.setTitleColor(#colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1), for: .normal)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }

}
