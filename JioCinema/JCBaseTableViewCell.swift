//
//  JCBaseTableViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class JCBaseTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    var data:[Item]?
    var moreLikeData:[More]?
    var episodes:[Episode]?
    var artistImages:[String:String]?
    var isResumeWatchCell = false
    var itemFromViewController:VideoType?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.data?.removeAll()
        self.moreLikeData?.removeAll()
        self.episodes?.removeAll()
        self.artistImages?.removeAll()
        self.isResumeWatchCell = false
       // self.tableCellCollectionView = nil
        self.categoryTitleLabel.text = ""
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        tableCellCollectionView.delegate = self
        tableCellCollectionView.dataSource = self
        //self.alpha = 0.5
        self.tableCellCollectionView.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
        self.tableCellCollectionView.register(UINib.init(nibName: "JCResumeWatchCell", bundle: nil), forCellWithReuseIdentifier: resumeWatchCellIdentifier)
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
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
        
        //For Home, Movies, Music etc
        if(data?[indexPath.row].banner != nil)
        {
            if isResumeWatchCell
            {
                let resumeWatchCell = collectionView.dequeueReusableCell(withReuseIdentifier: resumeWatchCellIdentifier, for: indexPath) as! JCResumeWatchCell
                if let imageUrl = data?[indexPath.row].banner!
                {
                    DispatchQueue.main.async {
                        
                    
                    resumeWatchCell.nameLabel.text = self.data?[indexPath.row].name!
                    
                    let progress:Float?
                    if let duration = self.data![indexPath.row].duration, let totalDuration = self.data![indexPath.row].totalDuration
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
                }
                resumeWatchCell.isOpaque = true

                return resumeWatchCell
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
                if let imageUrl = data?[indexPath.row].banner!
                {
                    
                    DispatchQueue.main.async {
                        
                        if !(self.data?[indexPath.row].app?.type == VideoType.Language.rawValue || self.data?[indexPath.row].app?.type == VideoType.Genre.rawValue)
                        {
                    cell.nameLabel.text = self.data?[indexPath.row].name!
                        }
                        else
                        {
                            cell.nameLabel.text = ""
                        }
                    
                    let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
                    cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                        (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    });
                    }
                }
                cell.isOpaque = true

                return cell
            }
            
        }
            //For Metadata Controller More Like Data
        else if(episodes?[indexPath.row].banner != nil)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
            
            DispatchQueue.main.async {

            cell.nameLabel.text = self.episodes?[indexPath.row].name
            let imageUrl = self.episodes?[indexPath.row].banner!
            
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
            }
            cell.isOpaque = true

            return cell

            
        }
            
        else if(moreLikeData?[indexPath.row].banner != nil)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
            
            DispatchQueue.main.async {

            cell.nameLabel.text = self.moreLikeData?[indexPath.row].name
            let imageUrl = self.moreLikeData?[indexPath.row].banner!
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
            }
            cell.isOpaque = true

            return cell

        }
        
        else if(artistImages != nil)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
            DispatchQueue.main.async {

            let keys = Array(self.artistImages!.keys)
            let key = keys[indexPath.row]
            let imageUrl = self.artistImages?[key]
           
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
            }
            cell.isOpaque = true
                let artistDict = artistImages?.filter({$0.key != ""})
                let artistName = artistDict?[indexPath.row].key
                //let initals = artistName
                cell.nameLabel.text = artistName
            
           // let tempFrame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.size.height, height: cell.frame.size.height)
            //cell.frame = tempFrame
            
            //cell.nowPlayingLabel.text =
            //cell.clipsToBounds = true
            //cell.layer.cornerRadius = tempFrame.size.height / 2
            
            
            return cell

        }
        
        
        //        let finalCellFrame = cell.frame
        //        let translation:CGPoint = collectionView.panGestureRecognizer.translation(in: collectionView.superview)
        //        if translation.x > 0
        //        {
        //            cell.frame = CGRect.init(x: finalCellFrame.origin.x - 500, y: -500.0, width: 0, height: 0)
        //        }
        //        else
        //        {
        //            cell.frame = CGRect.init(x: finalCellFrame.origin.x + 500, y: -500.0, width: 0, height: 0)
        //        }
        //        UIView.animate(withDuration: 0.5) {
        //            cell.frame = finalCellFrame
        //        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        cell.isOpaque = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionIndex = collectionView.tag
        selectedItemFromViewController = self.itemFromViewController!
        
        if data != nil
        {
            let itemToPlay = ["item":(data?[indexPath.row])!]
            NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
        }
        else if moreLikeData != nil
        {
            let itemToPlay = ["item":(moreLikeData?[indexPath.row])!]
            NotificationCenter.default.post(name: metadataCellTapNotificationName, object: nil, userInfo: itemToPlay)
        }
        else if episodes != nil
        {
            let itemToPlay = ["item":(episodes?[indexPath.row])!]
            NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
        }
        else if artistImages != nil
        {
            if let artistDict = artistImages?.filter({$0.key != ""})
            {
                let artistName = artistDict[indexPath.row].key
                let artistToSearch = ["artist":artistName]
                NotificationCenter.default.post(name: openSearchVCNotificationName, object: nil, userInfo: artistToSearch)
            }
        }
        
    }
    
}
