//
//  JCBaseTableViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol JCBaseTableViewCellDelegate {
    @objc optional func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int)
}

class JCBaseTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    var data:[Item]?
    var moreLikeData:[More]?
    var episodes:[Episode]?
    var artistImages:[String: String]?
    var isResumeWatchCell = false
    var itemFromViewController: VideoType?
    weak var cellDelgate: JCBaseTableViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableCellCollectionView.delegate = self
        tableCellCollectionView.dataSource = self
        //self.alpha = 0.5
        self.tableCellCollectionView.register(UINib(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
        self.tableCellCollectionView.register(UINib(nibName: "JCArtistImageCell", bundle: nil), forCellWithReuseIdentifier: artistImageCellIdentifier)
        self.tableCellCollectionView.register(UINib(nibName: "JCResumeWatchCell", bundle: nil), forCellWithReuseIdentifier: resumeWatchCellIdentifier)
        // Initialization code
        
        //tvOS11 adjustment
        if #available(tvOS 11.0, *) {
            let collectionFrame = CGRect.init(x: tableCellCollectionView.frame.origin.x - 70, y: tableCellCollectionView.frame.origin.y, width: tableCellCollectionView.frame.size.width, height: tableCellCollectionView.frame.size.height)
            tableCellCollectionView.frame = collectionFrame
            
            let labelFrame = CGRect(x: categoryTitleLabel.frame.origin.x - 70, y: categoryTitleLabel.frame.origin.y, width: categoryTitleLabel.frame.size.width, height: categoryTitleLabel.frame.size.height)
            
            categoryTitleLabel.frame = labelFrame
            
            
        } else {
            // or use some work around
        }

    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- UICollectionView Delegate and Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = data?.count
        {
            return count
        }
        else if let moreLikeDataCount = moreLikeData?.count
        {
            return moreLikeDataCount
        }
        else if let episodesCount = episodes?.count
        {
            return episodesCount
        }
        else if let artistsCount = artistImages?.count
        {
            return artistsCount
        }
            
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        //For Home, Movies, Music etc
        if(data?[indexPath.row].banner != nil)
        {
            if isResumeWatchCell
            {
                let resumeWatchCell = collectionView.dequeueReusableCell(withReuseIdentifier: resumeWatchCellIdentifier, for: indexPath) as! JCResumeWatchCell
                if let imageUrl = data?[indexPath.row].banner
                {
                    resumeWatchCell.nameLabel.text = data?[indexPath.row].name!
                    
                    let progress:Float?
                    if let duration = data?[indexPath.row].duration, let totalDuration = data?[indexPath.row].totalDuration
                    {
                        progress = Float(duration)! / Float(totalDuration)!
                        resumeWatchCell.progressBar.setProgress(progress!, animated: false)
                    }
                    else
                    {
                        resumeWatchCell.progressBar.setProgress(0, animated: false)
                    }
                    
                    let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
                    resumeWatchCell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                        (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    });
                }
                return resumeWatchCell
            }
            else
            {
                
                var thumbnailTitle = ""
                if let nameOfThumbnail = data?[indexPath.row].name, nameOfThumbnail != ""{
                    thumbnailTitle = nameOfThumbnail
                }else if let shownameOfThumbnail = data?[indexPath.row].showname{
                    thumbnailTitle = shownameOfThumbnail
                }
                
                if let imageUrl = data?[indexPath.row].banner {
                    cell.nameLabel.text = (data?[indexPath.row].app?.type == VideoType.Language.rawValue || data?[indexPath.row].app?.type == VideoType.Genre.rawValue) ? "" : thumbnailTitle
                    
                    let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
                    cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                        (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    });
                }
                return cell
            }
            
        }
            //For Metadata Controller More Like Data
        else if(episodes?[indexPath.row].banner != nil)
        {
            cell.nameLabel.text = episodes?[indexPath.row].name
            let imageUrl = episodes?[indexPath.row].banner ?? ""
            
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
            
        }
            
        else if(moreLikeData?[indexPath.row].banner != nil)
        {
            cell.nameLabel.text = moreLikeData?[indexPath.row].name
            let imageUrl = moreLikeData?[indexPath.row].banner ?? ""
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
            
        else if(artistImages != nil)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: artistImageCellIdentifier, for: indexPath) as! JCArtistImageCell
//            DispatchQueue.main.async {
                cell.artistImageView.clipsToBounds = true
                let xAxis = collectionView.frame.height - cell.artistImageView.frame.size.height
                let newFrame = CGRect.init(x: xAxis/2, y: cell.artistImageView.frame.origin.y, width: cell.artistImageView.frame.size.height , height: cell.artistImageView.frame.size.height)
                cell.artistImageView.frame = newFrame
                cell.artistImageView.layer.cornerRadius = cell.artistImageView.frame.size.height / 2
                
                cell.artistNameLabel.textAlignment = .center
                if let artistImagesDict = self.artistImages {
                    let artistNameKey = Array(artistImagesDict.keys)[indexPath.row]
                    let imageUrl = artistImagesDict[artistNameKey] ?? ""
                    
                    cell.artistNameLabel.text = artistNameKey
                    let artistNameSubGroup = artistNameKey.components(separatedBy: " ")
                    var artistInitial = ""
                    for each in artistNameSubGroup{
                        if each.first != nil{
                            artistInitial = artistInitial + String(describing: each.first!)
                        }
                    }
                    cell.artistImageView.isHidden = true
                    cell.artistNameInitialButton.isHidden = false
                    let url = URL(string: imageUrl)
                    cell.artistImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                        (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                        
                        if error != nil{
                            cell.artistImageView.isHidden = true
                            cell.artistNameInitialButton.isHidden = false
                            cell.artistNameInitialButton.setTitle(String(describing: artistInitial), for: .normal)
                        }
                        else{
                            cell.artistNameInitialButton.isHidden = true
                            cell.artistImageView.isHidden = false
                        }
                    })
                }
//            }
            
            cell.isOpaque = true
            cell.backgroundColor = .clear
            return cell
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let items = data{
            cellDelgate?.didTapOnItemCell?(self, items[indexPath.row], self.tag)
        }
        else if let moreItems = moreLikeData{
            cellDelgate?.didTapOnItemCell?(self, moreItems[indexPath.row], self.tag)
        }
        else if let artistImageDict = artistImages{
            let artistNameDict = artistImageDict.filter({$0.key != ""})
            cellDelgate?.didTapOnItemCell?(self, Array(artistNameDict.keys)[indexPath.row], self.tag)
        }
        else if let episodes = episodes{
            cellDelgate?.didTapOnItemCell?(self, episodes[indexPath.row], self.tag)
        }
    }
}


extension JCBaseTableViewCell: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if(artistImages != nil) {
            return 15
        }
        
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(artistImages != nil)
        {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        }
        
        return CGSize(width: 392, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedIndexPath != nil {
            if let tableCell = collectionView.superview?.superview as? JCBaseTableViewCell {
                tableCell.categoryTitleLabel.textColor = .white
            }
        } else if context.previouslyFocusedIndexPath != nil {
            if let tableCell = collectionView.superview?.superview as? JCBaseTableViewCell {
                tableCell.categoryTitleLabel.textColor = #colorLiteral(red: 0.5843137255, green: 0.5843137255, blue: 0.5843137255, alpha: 1)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
}


