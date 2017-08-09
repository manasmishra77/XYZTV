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
    
    @IBOutlet weak var titleLabel: UILabel!
    override func prepareForReuse() {
        self.itemImageView.image = #imageLiteral(resourceName: "itemCellPlaceholder.png")
    }
}
