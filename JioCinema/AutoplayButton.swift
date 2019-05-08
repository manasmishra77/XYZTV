//
//  autoplayButton.swift
//  JioCinema
//
//  Created by Vinit Somani on 5/29/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class AutoplayButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTitleColor(ThemeManager.shared.selectionColor, for: .highlighted)
        self.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        self.titleLabel?.textColor = #colorLiteral(red: 0.5843137255, green: 0.5843137255, blue: 0.5843137255, alpha: 1)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.setTitleColor(ThemeManager.shared.selectionColor, for: .focused)
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
            self.titleLabel?.textColor = #colorLiteral(red: 0.5843137255, green: 0.5843137255, blue: 0.5843137255, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
    
    
}
