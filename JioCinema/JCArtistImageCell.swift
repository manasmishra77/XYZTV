//
//  JCArtistImageCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 22/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCArtistImageCell: UICollectionViewCell {
    @IBOutlet weak var artistNameInitialButton: JCButton!
    @IBOutlet weak var artistNameLabel: UILabel!
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self)
        {
            self.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
        }
        else
        {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
    }
}
