//
//  JCItemCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 27/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCItemCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var nowPlayingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func prepareForReuse() {
        // self.itemImageView.image = #imageLiteral(resourceName: "itemCellPlaceholder.png")
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
            self.nameLabel.isHidden = false
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.nameLabel.isHidden = true
        }
    }
    
}
