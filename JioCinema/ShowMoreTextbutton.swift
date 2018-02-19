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
            self.alpha = 1.0
            
        } else {
            self.alpha = 0.5
            self.backgroundColor = .clear
        }
        
    }

}
