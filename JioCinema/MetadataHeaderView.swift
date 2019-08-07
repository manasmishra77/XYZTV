//
//  MetadataHeaderViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 09/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol MetadataHeaderCellDelegate {
    @objc optional func didClickOnWatchNowButton(_ headerView: MetadataHeaderView?)
    @objc optional func didClickOnAddOrRemoveWatchListButton(_ headerView: MetadataHeaderView, isStatusAdd: Bool)
    @objc optional func didClickOnShowMoreDescriptionButton(_ headerView: MetadataHeaderView, toShowMore: Bool)
}


class MetadataHeaderView: UIView {
    
    weak var delegate: MetadataHeaderCellDelegate? = nil
    
    var isDisney = false
    @IBOutlet weak var tvShowLabel: UILabel!
    @IBOutlet weak var maturityRating: UILabel!
    @IBOutlet weak var addToWatchListButton: JCMetadataButton!
    @IBOutlet weak var directorStaticLabel: UILabel!
    @IBOutlet weak var playButton: JCMetadataButton!
    @IBOutlet weak var starringStaticLabel: UILabel!
    @IBOutlet weak var audioStaticLabel: UILabel!
    @IBOutlet weak var tvShowSubtitleLabel: UILabel!
    @IBOutlet weak var starringLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var multiAudioLanguge: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchlistLabel: UILabel!
    @IBOutlet weak var constarintForContainer: NSLayoutConstraint!
    
    //@IBOutlet weak var backgroudImage: UIImageView!
    
    @IBOutlet weak var heightOFDirectorStatic: NSLayoutConstraint!
    @IBOutlet weak var heightOfStarringStatic: NSLayoutConstraint!
    @IBOutlet weak var heightOfAudioStatic: NSLayoutConstraint!
    
    @IBOutlet weak var monthCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var heightOfContainerView: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showMoreDescriptionLabel: UILabel!
    @IBOutlet weak var showMoreDescription: UIButton!
    @IBOutlet weak var descriptionContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionContainerview: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var monthsCollectionView: UICollectionView!
    @IBOutlet weak var seasonCollectionView: UICollectionView!
    @IBOutlet weak var seasonsLabel: UILabel!
    
    
    //Constraints for all the view
    @IBOutlet weak var sseparationBetweenDirectorStaticAndDescView: NSLayoutConstraint!
    
    @IBOutlet weak var sseparationBetweenSeasonLabelAndSeasonCollView: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfSeasonStaticLabel: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(self)
    }
    
    func configureViews(_ isDisney : Bool = false) {
        let colors = isDisney ? ViewColor.disneyBackground : ViewColor.commonBackground
        var colorsArray = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor, colors.withAlphaComponent(0.5).cgColor, colors.cgColor]
        var startPoint = CGPoint(x: 1.0, y: 0.0)
        var endPoint = CGPoint(x: 0.0, y: 0.0)
        Utility.applyGradient(self.bannerImageView, startPoint: startPoint, endPoint: endPoint, colorArray: colorsArray)
        
        colorsArray = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor, colors.withAlphaComponent(0.5).cgColor, colors.cgColor]
        endPoint = CGPoint(x: 0.0, y: 1.0)
        startPoint = CGPoint(x: 0.0, y: 0.0)
        Utility.applyGradient(self.bannerImageView, startPoint: startPoint, endPoint: endPoint, colorArray: colorsArray, atIndex: 1)
    }
    
    func resetView() -> UIView {
        titleLabel.text = ""
        subtitleLabel.text = ""
        directorLabel.text = ""
        starringLabel.text = ""
        return self
    }
    
    @IBAction func didClickOnWatchNowButton(_ sender: Any) {
        delegate?.didClickOnWatchNowButton?(self)
    }

    @IBAction func didClickOnAddToWatchListButton(_ sender: Any) {
        if watchlistLabel.text == ADD_TO_WATCHLIST{
            delegate?.didClickOnAddOrRemoveWatchListButton?(self, isStatusAdd: true)
        }
        else{
            delegate?.didClickOnAddOrRemoveWatchListButton?(self, isStatusAdd: false)
        }
    }
    @IBAction func didClickOnShowMoreDescriptionButton(_ sender: Any) {
        if showMoreDescriptionLabel.text == SHOW_MORE {
            delegate?.didClickOnShowMoreDescriptionButton?(self, toShowMore: true)
        } else {
            delegate?.didClickOnShowMoreDescriptionButton?(self, toShowMore: false)
        }
    }
    
}

