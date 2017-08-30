//
//  JCBaseTableViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCBaseTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    var data:[Item]?
    var moreLikeData:[More]?
    var episodes:[Episode]?
    var artistImages:[String:String]?
    var isResumeWatchCell = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableCellCollectionView.delegate = self
        tableCellCollectionView.dataSource = self
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        //For Home, Movies, Music etc
        if(data?[indexPath.row].banner != nil)
        {
            if isResumeWatchCell
            {
                let resumeWatchCell = collectionView.dequeueReusableCell(withReuseIdentifier: resumeWatchCellIdentifier, for: indexPath) as! JCResumeWatchCell
                if let imageUrl = data?[indexPath.row].banner!
                {
                    resumeWatchCell.nameLabel.text = data?[indexPath.row].name!
                    
                    let progress:Float?
                    if let duration = data![indexPath.row].duration, let totalDuration = data![indexPath.row].totalDuration
                        {
                            progress = Float(duration) / Float(totalDuration)!
                            resumeWatchCell.progressBar.setProgress(progress!, animated: false)
                    }
                    else
                    {
                        resumeWatchCell.progressBar.setProgress(0, animated: false)
                    }
                    
                    if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
                    {
                        resumeWatchCell.itemImageView.image = image;
                    }
                    else
                    {
                        self.downloadImageFrom(urlString: imageUrl, indexPath: indexPath)
                    }
                }
                return resumeWatchCell
            }
            else
            {
                if let imageUrl = data?[indexPath.row].banner!
                {
                    cell.nameLabel.text = data?[indexPath.row].name!
                    if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
                    {
                        cell.itemImageView.image = image;
                    }
                    else
                    {
                        self.downloadImageFrom(urlString: imageUrl, indexPath: indexPath)
                    }
                }
                return cell
            }
            
        }
            //For Metadata Controller More Like Data
        else if(episodes?[indexPath.row].banner != nil)
        {
            cell.nameLabel.text = episodes?[indexPath.row].name
            let imageUrl = episodes?[indexPath.row].banner!
            
            if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            {
                cell.itemImageView.image = image;
            }
            else
            {
                self.downloadImageFrom(urlString: imageUrl!, indexPath: indexPath)
            }
        }
            
        else if(moreLikeData?[indexPath.row].banner != nil)
        {
            cell.nameLabel.text = moreLikeData?[indexPath.row].name
            let imageUrl = moreLikeData?[indexPath.row].banner!
            
            if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            {
                cell.itemImageView.image = image;
            }
            else
            {
                self.downloadImageFrom(urlString: imageUrl!, indexPath: indexPath)
            }
        }
            
        else if(artistImages != nil)
        {
            
            let keys = Array(artistImages!.keys)
            let key = keys[indexPath.row]
            let imageUrl = artistImages?[key]
            
            if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            {
                cell.itemImageView.image = image;
            }
            else
            {
                self.downloadImageFrom(urlString: imageUrl!, indexPath: indexPath)
            }
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
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
            //open search screen
        }
        
    }
    
    fileprivate func downloadImageFrom(urlString:String,indexPath:IndexPath)
    {
        
        weak var weakSelf = self
        
        let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(urlString)
        RJILImageDownloader.shared.downloadImage(urlString: imageUrl!, shouldCache: true){
            
            image in
            
            if let img = image {
                
                DispatchQueue.main.async {
                    
                    if let cell = weakSelf?.tableCellCollectionView?.cellForItem(at: indexPath){
                        
                        if (weakSelf?.isResumeWatchCell)!
                        {
                        let itemCell = cell as! JCResumeWatchCell
                        itemCell.itemImageView.image = img
                        }
                        else
                        {
                            let itemCell = cell as! JCItemCell
                            itemCell.itemImageView.image = img
                        }
                    }
                }
            }
        }
    }
    
}
