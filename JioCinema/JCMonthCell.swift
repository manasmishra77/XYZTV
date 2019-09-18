//
//  JCMonthCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 22/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMonthCell: UICollectionViewCell
{
    @IBOutlet weak var monthLabel: UILabel!
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        self.layer.cornerRadius = 5.0
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.backgroundColor = ThemeManager.shared.selectionColor
            monthLabel.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        }
        else
        {
            monthLabel.textColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1)
            self.backgroundColor = UIColor.clear
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
}
