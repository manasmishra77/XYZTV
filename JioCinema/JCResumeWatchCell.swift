//
//  JCResumeWatchCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 28/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCResumeWatchCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    override func prepareForReuse() {
       // self.itemImageView.image = #imageLiteral(resourceName: "itemCellPlaceholder.png")
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
        }
        else
        {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
    }

}
