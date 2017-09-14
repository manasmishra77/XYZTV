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
}
