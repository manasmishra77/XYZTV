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
            self.superview?.alpha = 1.0
            self.nameLabel.font = self.nameLabel.font.withSize(30)
            let frame = CGRect.init(x: itemImageView.focusedFrameGuide.layoutFrame.origin.x+15, y: progressBar.frame.origin.y + 20, width: itemImageView.focusedFrameGuide.layoutFrame.size.width, height: progressBar.frame.size.height)
            self.progressBar.frame = frame
        }
        else
        {
            self.superview?.alpha = 0.5
            self.nameLabel.font = self.nameLabel.font.withSize(24)
            let frame = CGRect.init(x: itemImageView.frame.origin.x, y: progressBar.frame.origin.y - 20, width: itemImageView.frame.size.width, height: progressBar.frame.size.height)
            self.progressBar.frame = frame
        }
        
    }

}
