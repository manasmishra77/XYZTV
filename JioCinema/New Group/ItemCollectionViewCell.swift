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
    @IBOutlet weak var heightConstraintForProgressBar: NSLayoutConstraint!
    

    func configureView(_ cellItems: BaseItemCellModels) {
        //Load Image
        if let imageURL = URL(string: cellItems.item.imageUrlString) {
            setImageOnCell(url: imageURL)
        }
        nameLabel.text = cellItems.item.name ?? ""
        progressBar.isHidden = true
        heightConstraintForProgressBar.constant = 0
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
            self.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
enum ItemCellType {
    case base
    case resumeWatch
    case resumeWatchDisney
    case artist
    case player
}

enum ItemCellLayoutType {
    case potrait
    case landscape
}
