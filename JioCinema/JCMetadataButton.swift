//
//  JCMetadataButton.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 10/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMetadataButton: UIButton {

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = #colorLiteral(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9333333333, blue: 0.9333333333, alpha: 0.3525736924)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }


}
