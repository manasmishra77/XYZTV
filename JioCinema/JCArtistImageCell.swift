//
//  JCArtistImageCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 22/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCArtistImageCell: UICollectionViewCell {
    
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistNameInitialButton: JCButton!
    
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self)
        {
//            if let topVC = UIApplication.topViewController(), !(topVC is JCPlayerVC)
//            {
//                //self.superview?.alpha = 1.0
//            }
            if !artistNameInitialButton.isHidden{
                artistNameInitialButton.titleLabel?.font = artistNameInitialButton.titleLabel?.font.withSize(80)
            }
        }
        else
        {
//            if let topVC = UIApplication.topViewController(), !(topVC is JCPlayerVC)
//            {
//                //self.superview?.alpha = 0.4
//            }
            if !artistNameInitialButton.isHidden{
                artistNameInitialButton.titleLabel?.font = artistNameInitialButton.titleLabel?.font.withSize(70)
            }
        }
        
    }
}
