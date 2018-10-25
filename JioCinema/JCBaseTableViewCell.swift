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

enum ItemArrayType {
    case item
    case resumeWatch
    case more
    case episode
    case artistImages
}

class JCBaseTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    var data:[Item]?
    var moreLikeData:[More]?
    var episodes:[Episode]?
    var artistImages:[String: String]?
    
    var itemsArray: [Any]?
    var itemArrayType: ItemArrayType = .item
    
    var isResumeWatchCell = false
    var itemFromViewController: VideoType?
    weak var cellDelgate: JCBaseTableViewCellDelegate? = nil
    let imageBaseURL = JCDataStore.sharedDataStore.configData?.configDataUrls?.image ?? ""
    
    var isDisney = false
    
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
    

//    override func prepareForReuse() {
//        self.tableCellCollectionView.reloadData()
//    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- UICollectionView Delegate and Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch itemArrayType {
        case .item:
            return itemCellLoading(collectionView, cellForItemAt: indexPath)
        case .more:
            return moreLikeCellLoading(collectionView, cellForItemAt: indexPath)
        case .episode:
            return episodesCellLoading(collectionView, cellForItemAt: indexPath)
        case .artistImages:
            return artistImageCellLoading(collectionView, cellForItemAt: indexPath)
        case .resumeWatch:
            return resumeCellLoading(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func resumeCellLoading(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resumeWatchCell = collectionView.dequeueReusableCell(withReuseIdentifier: resumeWatchCellIdentifier, for: indexPath) as! JCResumeWatchCell
        let items = itemsArray as! [Item]
        resumeWatchCell.nameLabel.text = items[indexPath.row].name ?? ""
        
        if let imageUrl = items[indexPath.row].banner {
            let progress: Float?
            if let duration = items[indexPath.row].duration, let totalDuration = items[indexPath.row].totalDuration {
                progress = Float(duration) / Float(totalDuration)
                resumeWatchCell.progressBar.setProgress(progress ?? 0, animated: false)
            } else {
                resumeWatchCell.progressBar.setProgress(0, animated: false)
            }
            
            let url = URL(string: imageBaseURL + imageUrl)
            resumeWatchCell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
        return resumeWatchCell
    }
    
    func itemCellLoading(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        let items = itemsArray as! [Item]
        var thumbnailTitle = ""
        if let nameOfThumbnail = items[indexPath.row].name, nameOfThumbnail != ""{
            thumbnailTitle = nameOfThumbnail
        } else if let shownameOfThumbnail = items[indexPath.row].showname {
            thumbnailTitle = shownameOfThumbnail
        }

        cell.nameLabel.text = (items[indexPath.row].app?.type == VideoType.Language.rawValue || items[indexPath.row].app?.type == VideoType.Genre.rawValue) ? "" : thumbnailTitle
        
        if items[indexPath.row].appType == .Movie {
            if let imageUrl = items[indexPath.row].image {
                self.setImageOnThumbnail(urlString: imageUrl, on: cell)
            }
        }else if let imageUrl = items[indexPath.row].banner {
            self.setImageOnThumbnail(urlString: imageUrl, on: cell)
        }
        
        return cell
    }
    
    func setImageOnThumbnail(urlString: String, on cell: JCItemCell) {
        let url = URL(string: imageBaseURL + urlString)
        cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
        });
    }
    
    func episodesCellLoading(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        let episodes = itemsArray as! [Episode]
        cell.nameLabel.text = episodes[indexPath.row].name
        let imageUrl = episodes[indexPath.row].banner ?? ""
        
        let url = URL(string: imageBaseURL + imageUrl)
        cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
        });
        return cell
    }
    
    func moreLikeCellLoading(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        let moreArray = itemsArray as! [Item]
        cell.nameLabel.text = moreArray[indexPath.row].name
        let imageUrl = moreArray[indexPath.row].banner ?? ""
        let url = URL(string: imageBaseURL + imageUrl)
        cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
        });
        return cell
    }
    
    func artistImageCellLoading(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: artistImageCellIdentifier, for: indexPath) as! JCArtistImageCell
        cell.artistNameInitialButton.clipsToBounds = true
        let xAxis = collectionView.frame.height - cell.artistNameInitialButton.frame.size.height
        let newFrame = CGRect.init(x: xAxis/2, y: cell.artistNameInitialButton.frame.origin.y, width: cell.artistNameInitialButton.frame.size.height , height: cell.artistNameInitialButton.frame.size.height)
        cell.artistNameInitialButton.frame = newFrame
        cell.artistNameInitialButton.layer.cornerRadius = cell.artistNameInitialButton.frame.size.height / 2
        
        cell.artistNameLabel.textAlignment = .center
        let artistImagesArray = self.itemsArray as! [(String, String)]
        let artistNameKey = artistImagesArray[indexPath.row].0
        let imageUrl = artistImagesArray[indexPath.row].1
        
        cell.artistNameLabel.text = artistNameKey
        let artistNameSubGroup = artistNameKey.components(separatedBy: " ")
        var artistInitial = ""
        for each in artistNameSubGroup {
            if each.first != nil{
                artistInitial = artistInitial + String(describing: each.first!)
            }
        }
        cell.artistNameInitialButton.isHidden = false
        let url = URL(string: imageUrl)
        cell.artistNameInitialButton.sd_setBackgroundImage(with: url, for: .normal, completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            if error != nil{
                cell.artistNameInitialButton.setTitle(String(describing: artistInitial), for: .normal)
            }
            else{
                cell.artistNameInitialButton.setTitle("", for: .normal)
            }
        })
        
        cell.isOpaque = true
        cell.backgroundColor = .clear
        if isDisney {
            cell.artistNameInitialButton.backgroundColor = UIColor(red: 0.0/255.0, green: 30.0/255.0, blue: 66.0/255.0, alpha: 1.0)
        }
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch itemArrayType {
        case .item, .resumeWatch:
            let items = itemsArray as! [Item]
            cellDelgate?.didTapOnItemCell?(self, items[indexPath.row], self.tag)
        case .more:
            let items = itemsArray as! [Item]
            cellDelgate?.didTapOnItemCell?(self, items[indexPath.row], self.tag)
        case .episode:
            let items = itemsArray as! [Episode]
            cellDelgate?.didTapOnItemCell?(self, items[indexPath.row], self.tag)
        case .artistImages:
            let items = itemsArray as! [(String, String)]
            cellDelgate?.didTapOnItemCell?(self, items[indexPath.row].0, self.tag)
        }
    }
}


extension JCBaseTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(itemArrayType == .artistImages) {
            return 15
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        var width = height * widthToHeightPropertionForLandScape
        
        switch itemArrayType {
        case .resumeWatch:
            break
        case .item, .more:
            if let items = itemsArray as? [Item] {
                let itemAppType = items[0].appType
                if itemAppType == .Movie {
                    width = height * widthToHeightPropertionForPotrat
                }
            }
        case .episode:
            break
        case .artistImages:
            width = height
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
