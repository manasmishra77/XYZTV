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
        self.layer.cornerRadius = 15.0
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            self.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
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
