//
//  JCButton.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 13/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
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

}
class JCMetadataButton: UIButton {
    
//    var focusedBGColor : UIColor = #colorLiteral(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1)
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = ThemeManager.shared.selectionColor
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.5843137255, blue: 0.5843137255, alpha: 0.3525736924)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
}

class CustomButton: UIButton
{
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = ThemeManager.shared.selectionColor
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
        }
        else
        {
            self.backgroundColor = #colorLiteral(red: 0.4361188412, green: 0.4361297488, blue: 0.4361238778, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
    
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
    
}
class JCPlayerButton: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = ThemeManager.shared.selectionColor
//            self.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }
        else
        {
            self.backgroundColor = .clear
//            self.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }
        
    }
}
class JCRememberMe: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
            self.titleLabel?.font = UIFont(name: "JioType-Medium", size: 30)
            self.titleLabel?.textColor = .white
            self.backgroundColor = ThemeManager.shared.selectionColor
        }
        else
        {
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.titleLabel?.textColor = .lightGray
            self.titleLabel?.font = UIFont(name: "JioType-Medium", size: 30)
            self.backgroundColor = .clear
        }
        
    }
}
class SkipIntroButton: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.backgroundColor = ThemeManager.shared.selectionColor
            self.borderWidth = 0
        }
        else
        {
            self.backgroundColor = .clear
            self.borderWidth = 1
        }
    }
}

class HeaderButtons: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.backgroundColor = ThemeManager.shared.selectionColor
            self.setTitleColor(.white, for: .normal)
        }
        else
        {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.setTitleColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: .normal)
            self.backgroundColor = #colorLiteral(red: 0.8274509804, green: 0.831372549, blue: 0.8078431373, alpha: 1)
        }
    }
}
