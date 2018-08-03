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
            if let topVC = UIApplication.topViewController(), !(topVC is JCPlayerVC) {
                self.superview?.alpha = 1.0
            }

        } else {
            self.nameLabel.font = self.nameLabel.font.withSize(24)
            if let topVC = UIApplication.topViewController(), !(topVC is JCPlayerVC) {
                self.superview?.alpha = 0.5
            }
        }

    }
    
}
