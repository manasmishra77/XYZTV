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
    let item: Item?
    let cellType: ItemCellType!
    let layoutType: ItemCellLayoutType!
    var charactorItems: DisneyCharacterItems?
    init(item: Item?, cellType: ItemCellType = .base, layoutType: ItemCellLayoutType = .landscapeWithLabels, charactorItems : DisneyCharacterItems?) {
        self.item = item
        self.cellType = cellType
        self.layoutType = layoutType
        self.charactorItems = charactorItems
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
    
    var cellItem : BaseItemCellModel?
    
    override func prepareForReuse() {
        self.resetNameLabel()
    }
    
    

    func configureView(_ cellItems: BaseItemCellModel) {
        if (cellItems.charactorItems?.items?.count ?? 0) > 0 {
            imageView.backgroundColor = #colorLiteral(red: 0.02352941176, green: 0.1294117647, blue: 0.2470588235, alpha: 1)
        }
        cellItem = cellItems
        //configureView(cellItems)
        configureNameLabelPatchView(cellItems)
        nameLabel.text = cellItems.item?.name ?? ""
        subtitle.text = cellItems.item?.subtitle
        
//        self.backgroundColor = .brown
//        if let newSubtitle = cellItems.item.subtitle?.split(separator: "|"){
//        if cellItems.cellType == .resumeWatch || cellItems.cellType == .resumeWatchDisney{
//            if newSubtitle[1].trimmingCharacters(in: .whitespaces) == cellItems.item.language && newSubtitle.count == 3 {
//            subtitle.text = "\(newSubtitle[0])" + "|\(newSubtitle[2])"
//            }
//        }
//        }
        //subtitle.text = "\(newSubtitle[0])" + "\(newSubtitle[3])"
        
        progressBar.isHidden = true
        nameLabel.isHidden = false
        subtitle.isHidden = false
        heightConstraintForProgressBar.constant = 0
        
        //Load Image
        self.setImageForLayoutType(cellItems)
        configureCellLabelVisibility(cellItems.layoutType)

        guard let cellType = cellItems.cellType else {
            return
        }
        switch cellType {
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
    func configureNameLabelPatchView(_ cellItems: BaseItemCellModel) {
        guard let cellType = cellItems.cellType else {
            return
        }
        switch cellType {
        case .search:
            patchForTitleLabelLeading.backgroundColor = ViewColor.searchBackGround
        case .disneyPlayer, .player:
            patchForTitleLabelLeading.backgroundColor = ViewColor.clearBackGround
        default:
            if cellItems.cellType.isDisney {
                patchForTitleLabelLeading.backgroundColor = ViewColor.disneyBackground
            } else {
                patchForTitleLabelLeading.backgroundColor = ViewColor.commonBackground
            }
        }
    }
    
    
    private func setImageForLayoutType(_ cellItems: BaseItemCellModel) {
        //Load Image
        guard let layoutType = cellItems.layoutType else {
            return
        }
        switch layoutType {
        case .potrait, .potraitWithLabelAlwaysShow:
            if let imageURL = URL(string: cellItems.item?.imageUrlPortraitContent ?? "") {
                setImageOnCell(url: imageURL)
            }
        case .landscapeWithTitleOnly, .landscapeForLangGenre, .landscapeForResume, .landscapeWithLabels, .landscapeWithLabelsAlwaysShow:
            if let imageURL = URL(string: cellItems.item?.imageUrlLandscapContent ?? "") {
                setImageOnCell(url: imageURL)
            }
        case .disneyCharacter:
            if let logoURL = URL(string: cellItems.charactorItems?.LogoUrlForDisneyChar ?? ""){
                setImageOnCell(url: logoURL)
            }
        }
    }
    
    private func configureCellLabelVisibility(_ layoutType: ItemCellLayoutType, isFocused: Bool = false) {
        switch layoutType {
        case .potrait:
            subtitle.text = ""
            if isFocused {
                nameLabel.text = cellItem?.item?.name ?? ""
            } else {
                nameLabel.text = ""
            }
        case .potraitWithLabelAlwaysShow:
            subtitle.text = ""
        case .landscapeWithTitleOnly:
            subtitle.text = ""
            if isFocused {
               nameLabel.text = cellItem?.item?.name ?? ""
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
                nameLabel.text = cellItem?.item?.name ?? ""
                subtitle.text = cellItem?.item?.subtitle ?? ""
            } else {
                nameLabel.text = ""
                subtitle.text = ""
            }
        case .landscapeWithLabelsAlwaysShow:
            break
        case .disneyCharacter:
            nameLabel.text = ""
            subtitle.text = ""
        }
        
    }
    private func setProgressbarForResumeWatchCell(_ cellItems: BaseItemCellModel) {
         heightConstraintForProgressBar.constant = 10
        let progressColor: UIColor = (cellItems.cellType == .resumeWatch) ? #colorLiteral(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1) : #colorLiteral(red: 0.05882352941, green: 0.4392156863, blue: 0.8431372549, alpha: 1)
        let progressDefaultColor: UIColor = (cellItems.cellType == .resumeWatch) ? .gray : .white
        progressBar.isHidden = false
        progressBar.progressTintColor = progressColor
        progressBar.trackTintColor = progressDefaultColor
        var progress: Float = 0.0
        if let duration = cellItems.item?.duration, let totalDuration = cellItems.item?.totalDuration {
            progress = Float(duration) / Float(totalDuration)
            self.progressBar.setProgress(progress, animated: false)
        } else {
            self.progressBar.setProgress(0, animated: false)
        }
    }

    private func setImageOnCell(url: URL) {
//        imageView.backgroundColor = .green
       imageView.sd_setImage(with: url) { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            //print(error)
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        resetNameLabel()
        if (context.nextFocusedView == self) {
            
            if cellItem?.layoutType == ItemCellLayoutType.potrait || cellItem?.layoutType == ItemCellLayoutType.potraitWithLabelAlwaysShow{
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
            configureCellLabelVisibility(cellItem?.layoutType ?? .landscapeWithLabels, isFocused: true)
            imageView.borderWidth = 5
            if cellItem?.cellType.isDisney ?? false {
                imageView.borderColor = #colorLiteral(red: 0.2585663795, green: 0.7333371639, blue: 0.7917140722, alpha: 1)
            } else {
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
            self.borderWidth = 0
        }
    }
    
    func resetNameLabel() {
        self.nameLabel.clipsToBounds = true
        self.nameLabel.layer.masksToBounds = true
        self.clipsToBounds = true
        nameLabelLeadingConstraint.constant = 15
        timer?.invalidate()
        timer = nil
        nameLabel.text = cellItem?.item?.name ?? ""
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
    func startTimer() {
            self.timer?.invalidate()
            self.timer = nil
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
    var isDisney: Bool {
        return(self == .disneyCommon || self == .disneyPlayer || self == .disneyArtist || self == .resumeWatchDisney)
    }
}

enum ItemCellLayoutType {
    case potrait
    case potraitWithLabelAlwaysShow
    case landscapeWithTitleOnly
    case landscapeForResume
    case landscapeForLangGenre
    case landscapeWithLabels
    case landscapeWithLabelsAlwaysShow
    case disneyCharacter
    
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
