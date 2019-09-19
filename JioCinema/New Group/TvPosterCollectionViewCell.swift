//
//  TvPosterCollectionViewCell.swift
//  JioCinema
//
//  Created by Shweta Adagale on 06/09/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import TVUIKit
import SDWebImage


class ItemCell: UICollectionViewCell {
    
}

@available(tvOS 12.1, *)

class TvPosterCollectionViewCell: ItemCell {
    var posterView: TVPosterView?
    var monogramView: TVMonogramView?
    
//    @IBOutlet weak var poserView: TVPosterView!
    func configureCell(_ cellItems: BaseItemCellModel, isPlayingNow: Bool = false) {
        setLayoutOfCell()
        setValuesToCell(cellItems)
        
    }
    override func prepareForReuse() {
        posterView?.removeFromSuperview()
        posterView?.image = nil
        posterView = nil
    }
    
    func setLayoutOfCell(){
    }
    
    func setValuesToCell(_ cellItems: BaseItemCellModel){
        posterView = TVPosterView(frame: self.bounds)
        setImageForPosterView(cellItem: cellItems)
//        if let imageURL = URL(string: cellItems.item?.imageUrlLandscapContent ?? "") {
//
//            SDWebImageManager.shared.loadImage(with: imageURL, options: .continueInBackground, progress: nil) { (image: UIImage?, data: Data?, error: Error?, sdImageCatcheType: SDImageCacheType, finished: Bool, imageUrl: URL?) in
//                self.posterView?.image = image
//                self.posterView?.contentMode = .scaleAspectFit
//            }
//
//        }
        posterView?.frame = self.bounds
        
        
        
        
        posterView?.title = cellItems.item?.name
        posterView?.subtitle = cellItems.item?.subtitle
    
//        posterView?.
        posterView?.imageView.contentMode = .scaleAspectFit
        posterView?.contentSize = self.bounds.size
        posterView?.footerView?.backgroundColor = .red
        posterView?.headerView?.backgroundColor = .yellow
        posterView?.contentView.backgroundColor = .green
        var stringAttribute : String.StringAttribute?
        stringAttribute?.fontSize = 10
//        posterView?.subtitle = posterView?.subtitle?.getFontifiedText(partOfTheStringNeedToConvert: [stringAttribute!])
        posterView?.backgroundColor = .blue
        self.addSubview(self.posterView!)
    }
    func setImageForPosterView(cellItem: BaseItemCellModel) {
        var imageUrl = ""
        if let charItem = cellItem.charactorItems{
            imageUrl = charItem.LogoUrlForDisneyChar
        } else if let item = cellItem.item {
            imageUrl = item.imageUrlLandscapContent
        }
        if let imageURL = URL(string: imageUrl) {
        
            SDWebImageManager.shared.loadImage(with: imageURL, options: .continueInBackground, progress: nil) { (image: UIImage?, data: Data?, error: Error?, sdImageCatcheType: SDImageCacheType, finished: Bool, imageUrl: URL?) in
                self.posterView?.image = image
                self.posterView?.contentMode = .scaleAspectFit
            }
            
        }
    }
}
