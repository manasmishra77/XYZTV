//
//  CarouselCollectionViewCell.swift
//  JioCinema
//
//  Created by Shweta Adagale on 26/12/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rightSepration: NSLayoutConstraint!
    @IBOutlet weak var leftSepration: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
