//
//  ItemCollectionViewCell.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

typealias BaseItemCellModels = (item: Item, cellType: ItemCellType, layoutType: ItemCellLayoutType)

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var heightConstraintForProgressBar: NSLayoutConstraint!
    

    func configureView(_ cellItems: BaseItemCellModels) {
        nameLabel.text = cellItems.item.name ?? ""
        progressBar.isHidden = true
        heightConstraintForProgressBar.constant = 0
        
        
        //Load Image
        self.setImageForLayoutType(cellItems)
        
        switch cellItems.cellType {
        case .base:
            return
        case .resumeWatch:
            setProgressbarForResumeWatchCell(cellItems)
            return
        case .resumeWatchDisney:
            setProgressbarForResumeWatchCell(cellItems)
            return
        case .artist:
            return
        case .player:
            return
        case .disneyCommon:
            return
        case .disneyArtist:
            return
        case .disneyPlayer:
            return
        }
    }
    
    
    func setImageForLayoutType(_ cellItems: BaseItemCellModels) {
        //Load Image
        
        switch cellItems.layoutType {
        case .potrait:
            if let imageURL = URL(string: cellItems.item.imageUrlPortraitContent) {
                setImageOnCell(url: imageURL)
            }
        case .landscape:
            if let imageURL = URL(string: cellItems.item.imageUrlLandscapContent) {
                setImageOnCell(url: imageURL)
            }
        case .landscapeForResume:
            if let imageURL = URL(string: cellItems.item.imageUrlLandscapContent) {
                setImageOnCell(url: imageURL)
            }
        case .landscapeForLangGenre:
            break
        case .landscapeWithLabels:
            break
        }
    }
    
    
    private func setProgressbarForResumeWatchCell(_ cellItems: BaseItemCellModels) {
         heightConstraintForProgressBar.constant = 10
        let progressColor: UIColor = (cellItems.cellType == .resumeWatch) ? #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1) : #colorLiteral(red: 0.05882352941, green: 0.4392156863, blue: 0.8431372549, alpha: 1)
        let progressDefaultColor: UIColor = (cellItems.cellType == .resumeWatch) ? .gray : .white
        progressBar.isHidden = false
        progressBar.progressTintColor = progressColor
        progressBar.trackTintColor = progressDefaultColor
        var progress: Float = 0.0
        if let duration = cellItems.item.duration, let totalDuration = cellItems.item.totalDuration {
            progress = Float(duration) / Float(totalDuration)
            self.progressBar.setProgress(progress, animated: false)
        } else {
            self.progressBar.setProgress(0, animated: false)
        }
    }

   fileprivate func setImageOnCell(url: URL) {
        imageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            //print(error)
        })
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView == self) {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.nameLabel.isHidden = false
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.nameLabel.isHidden = true
        }
    }
}
enum ItemCellType {
    case base
    case disneyCommon
    case resumeWatch
    case resumeWatchDisney
    case artist
    case disneyArtist
    case player
    case disneyPlayer
}

enum ItemCellLayoutType {
    case potrait
    case landscape
    case landscapeForResume
    case landscapeForLangGenre
    case landscapeWithLabels
}
