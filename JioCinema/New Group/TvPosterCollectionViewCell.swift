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
    //@IBOutlet weak var posterView: TVPosterView!
    var posterView: TVPosterView?
    var monogramView: TVMonogramView?
    var  cellItems: BaseItemCellModel?
    var layout: ItemCellLayoutType = .landscapeWithLabels
    
    func configureCell(_ cellItems: BaseItemCellModel, isPlayingNow: Bool = false) {
        layout = cellItems.layoutType ?? .landscapeWithLabels
        self.cellItems = cellItems
        setLayoutOfCell()
        setValuesToCell()
        
    }
    
    override func awakeFromNib() {
        posterView = TVPosterView(frame: self.bounds)
        posterView?.contentSize = CGSize(width: self.bounds.width - 120, height: self.bounds.height - 120)

        posterView?.focusSizeIncrease = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing:10)
        posterView?.addAsSubViewWithConstraints(self)
     }
    
    func setLayoutOfCell(){
        
    }
    
    func setValuesToCell(){
        setTitleSubtitleOfCell()
        setImageForPosterView()
    }
    func setTitleSubtitleOfCell(isFocused: Bool = false) {
//        switch layout {
//        case .potrait:
//            posterView?.subtitle = ""
//            if isFocused {
//                posterView?.title = cellItems?.item?.name ?? ""
//            } else {
//                posterView?.title = ""
//            }
//        case .landscapeWithTitleOnly:
//            posterView?.subtitle = ""
//            if isFocused {
//                posterView?.title = cellItems?.item?.name ?? ""
//            } else {
//                posterView?.title = ""
//            }
//        case .landscapeForResume:
//            break
//        case .landscapeForLangGenre:
//            posterView?.title = ""
//            posterView?.subtitle = ""
//            break
//        case .landscapeWithLabels:
//            if isFocused {
//                posterView?.title = cellItems?.item?.name ?? ""
//                posterView?.subtitle = cellItems?.item?.subtitle ?? ""
//            } else {
//                posterView?.title = ""
//                posterView?.subtitle = ""
//            }
//            break
//        case .landscapeWithLabelsAlwaysShow:
//            break
//        case .disneyCharacter:
//            posterView?.title = ""
//            posterView?.subtitle = ""
//            break
//        }
        posterView?.title = cellItems?.item?.name
        if let subtitle = cellItems?.item?.subtitle , subtitle != ""{
            posterView?.subtitle = subtitle
        } else {
            posterView?.subtitle = "asnf"
        }
    }
    func setImageForPosterView() {
        var imageUrl = ""
        if let charItem = cellItems?.charactorItems {
            imageUrl = charItem.LogoUrlForDisneyChar
        } else if let item = cellItems?.item {
            imageUrl = item.imageUrlLandscapContent
        }
        if let imageURL = URL(string: imageUrl) {
        
            SDWebImageManager.shared.loadImage(with: imageURL, options: .continueInBackground, progress: nil) { (image: UIImage?, data: Data?, error: Error?, sdImageCatcheType: SDImageCacheType, finished: Bool, imageUrl: URL?) in
                self.posterView?.image = image
            }
            
        }
    }
}
