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
    var autoScrollLabel: AutoScrollLabel?
    override func prepareForReuse() {
        self.removeLabel()
        // self.itemImageView.image = #imageLiteral(resourceName: "itemCellPlaceholder.png")
    }
    
    func addLabel() {
        autoScrollLabel = AutoScrollLabel.init(frame: self.nameLabel.frame)
        autoScrollLabel?.tag = 1001
//        autoScrollLabel.setLabelText("Some lengthy text to be scrolled")
        self.addSubview(autoScrollLabel!)
    }
    
    func removeLabel() {
        autoScrollLabel = self.viewWithTag(1001) as? AutoScrollLabel
        autoScrollLabel?.removeFromSuperview()
        autoScrollLabel = nil
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            autoScrollLabel?.setLabelText("Some lengthy text to be scrolled")
            self.nameLabel.isHidden = true
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.nameLabel.isHidden = true
        }
    }
    
}
