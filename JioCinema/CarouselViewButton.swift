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
        if (context.nextFocusedView == self)
        {
            //self.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
            self.alpha = 1.0
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            //self.backgroundColor = #colorLiteral(red: 0.4361188412, green: 0.4361297488, blue: 0.4361238778, alpha: 1)
            self.alpha = 0.5
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }

}
