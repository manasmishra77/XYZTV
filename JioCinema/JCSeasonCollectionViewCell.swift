//
//  JCSeasonCollectionViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 21/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSeasonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var seasonNumberLabel: UILabel!
    var isDisney = false
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        self.layer.cornerRadius = 10.0
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            seasonNumberLabel.textColor = UIColor.white
            self.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
            if isDisney {
                self.backgroundColor = UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0)
            }
        }
        else
        {
            seasonNumberLabel.textColor = #colorLiteral(red: 0.8699558934, green: 0.8699558934, blue: 0.8699558934, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.backgroundColor = UIColor.clear

        }
        
    }
}
