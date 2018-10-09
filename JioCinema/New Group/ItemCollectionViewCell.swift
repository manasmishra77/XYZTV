//
//  ItemCollectionViewCell.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

typealias BaseItemCellModels = (item: Item, cellType: ItemCellType)

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    

    func configureView(_ cellItems: BaseItemCellModels) {
        //Load Image
        if let imageURL = URL(string: cellItems.item.imageUrlString) {
            setImageOnCell(url: imageURL)
        }
        nameLabel.text = cellItems.item.name ?? ""
//        switch cellItems.cellType {
//        case .base:
//            return
//        case .resumeWatch:
//            return
//        case .artist:
//            return
//        case .player:
//            return
//        }
    }

   fileprivate func setImageOnCell(url: URL) {
        imageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            //print(error)
        })
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self) {
            self.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
enum ItemCellType {
    case base
    case resumeWatch
    case artist
    case player
    
}
