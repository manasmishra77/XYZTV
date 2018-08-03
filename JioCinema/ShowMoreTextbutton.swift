//
//  ShowMoreTextbutton.swift
//  JioCinema
//
//  Created by manas on 19/02/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class ShowMoreTextbutton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self) {
            self.alpha = 0.3
            self.backgroundColor = #colorLiteral(red: 0.2809922272, green: 0.2693810222, blue: 0.2796935921, alpha: 1)
        } else {
            self.alpha = 0.01
            self.backgroundColor = .clear
        }
    }
}
