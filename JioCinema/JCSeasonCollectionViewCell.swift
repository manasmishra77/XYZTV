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
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            seasonNumberLabel.textColor = UIColor.white
        }
        else
        {
            seasonNumberLabel.textColor = #colorLiteral(red: 0.8699558934, green: 0.8699558934, blue: 0.8699558934, alpha: 1)
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
        
    }
}
