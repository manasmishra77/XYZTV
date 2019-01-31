//
//  JCMetadataButton.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 10/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMetadataButton: UIButton {

    var focusedBGColor : UIColor = #colorLiteral(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1)
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {        
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = focusedBGColor
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.5843137255, blue: 0.5843137255, alpha: 0.3525736924)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
}
