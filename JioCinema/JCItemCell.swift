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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var view_NowPlaying: UIView!
    @IBOutlet weak var nowPlayingLabel: UILabel!

    override func prepareForReuse() {
       // self.itemImageView.image = #imageLiteral(resourceName: "itemCellPlaceholder.png")
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self)
        {
            if let topVC = UIApplication.topViewController(), !(topVC is JCPlayerVC)
            {
                self.superview?.alpha = 1.0
            }
            
            self.nameLabel.font = self.nameLabel.font.withSize(30)
            self.view_NowPlaying.frame = itemImageView.focusedFrameGuide.layoutFrame
            self.view_NowPlaying.frame.origin.x = self.view_NowPlaying.frame.origin.x + 15
            self.view_NowPlaying.frame.size.height = self.view_NowPlaying.frame.size.height + 15
            
            let frame = CGRect.init(x: itemImageView.focusedFrameGuide.layoutFrame.width/2 - nowPlayingLabel.frame.width/2, y: itemImageView.focusedFrameGuide.layoutFrame.height/2 , width: nowPlayingLabel.frame.size.width, height: nowPlayingLabel.frame.size.height)
            nowPlayingLabel.frame.origin.x = frame.origin.x + 15
            nowPlayingLabel.frame.origin.y = frame.origin.y + 15
            
            
//            let frame = CGRect.init(x: 0, y: 0, width: self.view_NowPlaying.frame.size.width, height: self.view_NowPlaying.frame.size.height)
//            nowPlayingLabel.frame = frame

        }
        else
        {
            self.nameLabel.font = self.nameLabel.font.withSize(24)
            if let topVC = UIApplication.topViewController(), !(topVC is JCPlayerVC)
            {
                self.superview?.alpha = 0.4
            }
            self.view_NowPlaying.frame = itemImageView.frame
        }

    }
    
}
