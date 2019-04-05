//
//  JCButton.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 13/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
protocol playerButtonDelegate: NSObject {
    func buttonWith(tag: Int?, isFocused: Bool)
}

class JCButton: UIButton
{
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.4361188412, green: 0.4361297488, blue: 0.4361238778, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
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
class JCDisneyButton: UIButton
{
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.layer.cornerRadius = 10
            self.layer.borderWidth = 5
            self.layer.borderColor = #colorLiteral(red: 0.2585663795, green: 0.7333371639, blue: 0.7917140722, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        }
        else
        {
            self.layer.borderWidth = 0
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
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
class JCPlayerButton: UIButton {
    weak var delegate: playerButtonDelegate?
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.743552012)
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
            delegate?.buttonWith(tag: self.tag, isFocused: true)
        }
        else
        {
            self.backgroundColor = .clear
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            delegate?.buttonWith(tag: nil, isFocused: false)
        }
        
    }
}
class JCRememberMe: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
}
