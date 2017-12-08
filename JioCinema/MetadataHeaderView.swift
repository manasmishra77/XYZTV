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
}


class MetadataHeaderView: UIView {
    
    var delegate: MetadataHeaderCellDelegate? = nil
    
    @IBOutlet weak var addToWatchListButton: JCMetadataButton!
    @IBOutlet weak var directorStaticLabel: UILabel!
    @IBOutlet weak var playButton: JCMetadataButton!
    @IBOutlet weak var starringStaticLabel: UILabel!
    @IBOutlet weak var tvShowSubtitleLabel: UILabel!
    @IBOutlet weak var imdbImageLogo: UIImageView!
    @IBOutlet weak var starringLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchlistLabel: UILabel!
    @IBOutlet weak var constarintForContainer: NSLayoutConstraint!
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var monthsCollectionView: UICollectionView!
    @IBOutlet weak var seasonCollectionView: UICollectionView!
    @IBOutlet weak var seasonsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(self)
        if #available(tvOS 11.0, *) {
           // constarintForContainer.constant = -60
            
        } else {
            
        }
        
    }
    
    func resetView() -> UIView
    {
        titleLabel.text = ""
        ratingLabel.text = ""
        subtitleLabel.text = ""
        directorLabel.text = ""
        starringLabel.text = ""
        return self
    }
    
    @IBAction func didClickOnWatchNowButton(_ sender: Any)
    {
        delegate?.didClickOnWatchNowButton!(self)
        
    }
    
    
    @IBAction func didClickOnAddToWatchListButton(_ sender: Any)
    {
        if watchlistLabel.text == ADD_TO_WATCHLIST{
            delegate?.didClickOnAddOrRemoveWatchListButton!(self, isStatusAdd: true)
        }
        else{
            delegate?.didClickOnAddOrRemoveWatchListButton!(self, isStatusAdd: false)
        }
    }
}

