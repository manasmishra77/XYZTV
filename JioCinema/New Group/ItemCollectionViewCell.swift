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


//To be used in place of BaseItemCellModels Tuple
struct BaseItemCellModel {
    let item: Item!
    let cellType: ItemCellType!
    let layoutType: ItemCellLayoutType!
    init(item: Item, cellType: ItemCellType = .base, layoutType: ItemCellLayoutType = .landscapeWithLabels) {
        self.item = item
        self.cellType = cellType
        self.layoutType = layoutType
    }
}


class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var patchForTitleLabelLeading: UIView!
    @IBOutlet weak var heightConstraintForProgressBar: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabelLeadingConstraint: NSLayoutConstraint!
    
    var timer:Timer?
    var nameLabelMaxWidth: Int = 0
    
    var cellItem : BaseItemCellModels?
    
    override func prepareForReuse() {
        self.resetNameLabel()
    }
    
    

    func configureView(_ cellItems: BaseItemCellModels) {
        cellItem = cellItems
        //configureView(cellItems)
        configureNameLabelPatchView(cellItems)
        nameLabel.text = cellItems.item.name ?? ""
        subtitle.text = cellItems.item.subtitle
        progressBar.isHidden = true
        nameLabel.isHidden = false
        subtitle.isHidden = false
        heightConstraintForProgressBar.constant = 0
        
        //Load Image
        self.setImageForLayoutType(cellItems)
        configureCellLabelVisibility(cellItems.layoutType)

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
        case .disneyPlayer, .search:
            return
        }

    }
    
    //Used for background color of namelabel patchview
    func configureNameLabelPatchView(_ cellItems: BaseItemCellModels) {
        //patchForTitleLabelLeading.isHidden = true
        if cellItems.cellType == .disneyCommon || cellItems.cellType == .disneyPlayer || cellItems.cellType == .disneyArtist {
            patchForTitleLabelLeading.backgroundColor = ViewColor.disneyBackground
        } else if cellItems.cellType == .search {
            patchForTitleLabelLeading.backgroundColor = ViewColor.searchBackGround
        } else {
            patchForTitleLabelLeading.backgroundColor = ViewColor.commonBackground
        }
    }
    
    
    private func setImageForLayoutType(_ cellItems: BaseItemCellModels) {
        //Load Image
        switch cellItems.layoutType {
        case .potrait, .potraitWithLabelAlwaysShow:
            if let imageURL = URL(string: cellItems.item.imageUrlPortraitContent) {
                setImageOnCell(url: imageURL)
            }
        case .landscapeWithTitleOnly, .landscapeForLangGenre, .landscapeForResume, .landscapeWithLabels, .landscapeWithLabelsAlwaysShow:
            if let imageURL = URL(string: cellItems.item.imageUrlLandscapContent) {
                setImageOnCell(url: imageURL)
            }
        }
    }
    
    private func configureCellLabelVisibility(_ layoutType: ItemCellLayoutType, isFocused: Bool = false) {
        switch layoutType {
        case .potrait:
            subtitle.text = ""
            if isFocused {
                nameLabel.text = cellItem?.item.name ?? ""
            } else {
                nameLabel.text = ""
            }
        case .potraitWithLabelAlwaysShow:
            subtitle.text = ""
        case .landscapeWithTitleOnly:
            subtitle.text = ""
            if isFocused {
               nameLabel.text = cellItem?.item.name ?? ""
            } else {
               nameLabel.text = ""
            }
        case .landscapeForResume:
            break
        case .landscapeForLangGenre:
            nameLabel.text = ""
            subtitle.text = ""
        case .landscapeWithLabels:
            if isFocused {
                nameLabel.text = cellItem?.item.name ?? ""
                subtitle.text = cellItem?.item.subtitle ?? ""
            } else {
                nameLabel.text = ""
                subtitle.text = ""
            }
        case .landscapeWithLabelsAlwaysShow:
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

    private func setImageOnCell(url: URL) {
        imageView.sd_setImage(with: url) { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            //print(error)
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        resetNameLabel()
        if (context.nextFocusedView == self) {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            configureCellLabelVisibility(cellItem?.layoutType ?? .landscapeWithLabels, isFocused: true)
            if cellItem?.layoutType == .landscapeForLangGenre {
                imageView.borderWidth = 5
                imageView.borderColor = #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1)
            }
            if (nameLabel.intrinsicContentSize.width > (nameLabel.frame.width)) {
                nameLabel.text =  "  " + nameLabel.text!
                nameLabelMaxWidth = Int(nameLabel.intrinsicContentSize.width)
                startTimer()
            }
        } else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            configureCellLabelVisibility(cellItem?.layoutType ?? .landscapeWithLabels, isFocused: false)
            imageView.borderWidth = 0
        }
    }
    
    func resetNameLabel() {
        self.nameLabel.clipsToBounds = true
        self.nameLabel.layer.masksToBounds = true
        self.clipsToBounds = true
        nameLabelLeadingConstraint.constant = 15
        timer?.invalidate()
        timer = nil
        nameLabel.text = cellItem?.item.name ?? ""
    }
    
    @objc func moveText() {
        if (Int(self.nameLabelLeadingConstraint.constant) < (-self.nameLabelMaxWidth)) {
            resetNameLabel()
            startTimer()
        }
        else {
            self.nameLabelLeadingConstraint.constant = self.nameLabelLeadingConstraint.constant - 1
        }
    }
    func startTimer(){
            self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.moveText), userInfo: nil, repeats: true)
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
    case search
}

enum ItemCellLayoutType {
    case potrait
    case potraitWithLabelAlwaysShow
    case landscapeWithTitleOnly
    case landscapeForResume
    case landscapeForLangGenre
    case landscapeWithLabels
    case landscapeWithLabelsAlwaysShow
    
    init(layout : Int) {
        switch layout {
        //case 1,9: self = .Carousel
        case 2,4,7,5: self = .landscapeWithTitleOnly
        //case 12: self = .Square
        case 3:  self = .potrait
        default: self = .landscapeWithTitleOnly
        }
    }
}
