//
//  CarouselViewButton.swift
//  JioCinema
//
//  Created by Manas Mishra on 21/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class CarouselViewButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self) {
      
            self.alpha = 1.0
            self.transform = CGAffineTransform.init(scaleX: 1.03, y: 1.05)
        } else {
            self.alpha = 0.5
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }

}
