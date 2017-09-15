//
//  JCCarouselCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCCarouselCell: UICollectionViewCell
{
    @IBOutlet weak var carouselImageView: UIImageView!
    
    override func prepareForReuse() {
       // self.carouselImageView.image = #imageLiteral(resourceName: "carousel_placeholder-min.png")
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if (context.nextFocusedView == self)
        {
            self.superview?.alpha = 1.0
        }
        else
        {
            self.superview?.alpha = 0.5
        }
        
    }

}
