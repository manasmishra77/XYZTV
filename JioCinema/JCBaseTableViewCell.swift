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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableCellCollectionView.delegate = self
        tableCellCollectionView.dataSource = self
        //self.alpha = 0.5
        self.tableCellCollectionView.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
        self.tableCellCollectionView.register(UINib.init(nibName: "JCArtistImageCell", bundle: nil), forCellWithReuseIdentifier: artistImageCellIdentifier)
        self.tableCellCollectionView.register(UINib.init(nibName: "JCResumeWatchCell", bundle: nil), forCellWithReuseIdentifier: resumeWatchCellIdentifier)
        // Initialization code
        
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
                if let imageUrl = data?[indexPath.row].banner!
                {
                    resumeWatchCell.nameLabel.text = data?[indexPath.row].name!
                    
                    let progress:Float?
                    if let duration = data![indexPath.row].duration, let totalDuration = data![indexPath.row].totalDuration
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
                
                if let imageUrl = data?[indexPath.row].banner!
                {
                    cell.nameLabel.text = (data?[indexPath.row].app?.type == VideoType.Language.rawValue || data?[indexPath.row].app?.type == VideoType.Genre.rawValue) ? "" : data?[indexPath.row].name
                    
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
            let imageUrl = episodes?[indexPath.row].banner!
            
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
            
        }
            
        else if(moreLikeData?[indexPath.row].banner != nil)
        {
            cell.nameLabel.text = moreLikeData?[indexPath.row].name
            let imageUrl = moreLikeData?[indexPath.row].banner!
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
            
        else if(artistImages != nil)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: artistImageCellIdentifier, for: indexPath) as! JCArtistImageCell
            DispatchQueue.main.async {
                cell.artistImageView.clipsToBounds = true
                let xAxis = collectionView.frame.height - cell.artistImageView.frame.size.height
                let newFrame = CGRect.init(x: xAxis/2, y: cell.artistImageView.frame.origin.y, width: cell.artistImageView.frame.size.height , height: cell.artistImageView.frame.size.height)
                cell.artistImageView.frame = newFrame
                cell.artistImageView.layer.cornerRadius = cell.artistImageView.frame.size.height / 2
                
                cell.artistNameLabel.textAlignment = .center
                let keys = Array(self.artistImages!.keys)
                let key = keys[indexPath.row]
                let imageUrl = self.artistImages?[key]
                
                let url = URL(string: imageUrl!)
                cell.artistImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                    (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                });
            }
            cell.isOpaque = true
            let artistDict = artistImages?.filter({$0.key != ""})
            let artistName = artistDict?[indexPath.row].key
            cell.artistNameLabel.text = artistName
            
            cell.backgroundColor = .clear
            return cell
        }
        
        return cell
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionIndex = collectionView.tag
        selectedItemFromViewController = self.itemFromViewController!
        
        if let topController = UIApplication.topViewController() {
            categoryTitle = ""
        }
        
        if data != nil
        {
            if isSearchOpenFromMetaData
            {
                let item = self.data?[indexPath.row]
                if item?.app?.type == VideoType.Movie.rawValue || item?.app?.type == VideoType.TVShow.rawValue
                {
                    isSearchOpenFromMetaData = false
                    if let topController = UIApplication.topViewController() {
                        topController.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                            DispatchQueue.main.async {
                                self.openMetaDataVC(item: item!)
                            }
                        })
                    }
                }
                else
                {
                    print("$$$$ Handle Player")
                    if JCLoginManager.sharedInstance.isUserLoggedIn()
                    {
                        self.openPlayerVC(item: item!)
                    }
                    else
                    {
                        currentPlayableItem = item
                        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: loginVCStoryBoardId)
                        loginVC.modalPresentationStyle = .overFullScreen
                        loginVC.modalTransitionStyle = .coverVertical
                        loginVC.view.layer.speed = 0.7
                        UIApplication.topViewController()?.present(loginVC, animated: false, completion: nil)
                    }
                    
                }
            }
            else
            {
                var itemToPlay = ["item":(data?[indexPath.row])!]
                if isResumeWatchCell
                {
                    let dataTemp = data?[indexPath.row]
                    if dataTemp?.app?.type == 1{
                        dataTemp?.app?.type = 7
                    }
                    
                    itemToPlay = ["item":dataTemp!]
                }
                NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
            }
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
            if let artistDict = artistImages?.filter({$0.key != ""})
            {
                isSearchOpenFromMetaData = true
                let artistName = artistDict[indexPath.row].key
                NotificationCenter.default.post(name: openSearchVCNotificationName, object: nil, userInfo: ["artist":artistName])
            }
        }
    }
    
    //MARK:- Custom Methods
    
    //MARK:- Open MetaDataVC
    func openMetaDataVC(item:Item)
    {
        Log.DLog(message: "openMetaDataVC" as AnyObject)
        if let topController = UIApplication.topViewController() {
            let metadataVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
            metadataVC.item = item
            metadataVC.modalPresentationStyle = .overFullScreen
            metadataVC.modalTransitionStyle = .coverVertical
            topController.present(metadataVC, animated: true, completion: nil)
        }
    }
    //MARK:- Open PlayerVC
    func openPlayerVC(item:Item)
    {
        Log.DLog(message: "openPlayerVC" as AnyObject)
        if playerVC_Global != nil {
            return
        }
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        playerVC.currentItemImage = item.banner
        playerVC.currentItemTitle = item.name
        playerVC.currentItemDuration = String(describing: item.totalDuration)
        playerVC.currentItemDescription = item.subtitle
        //OPTIMIZATION PLAYERVC
       // playerVC.callWebServiceForPlaybackRights(id: item.id!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        playerVC.playerId = item.id
        playerVC.item = item
        
        if let topController = UIApplication.topViewController() {
            topController.present(playerVC, animated: false, completion: nil)
        }
    }

    
}


extension JCBaseTableViewCell: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       
         if(artistImages != nil)
         {
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
        
//        self.cellWidth = self.headerCollectionView.frame.width - (spaceBetweenCells * 2) - 80
//        return CGSize(width: self.cellWidth, height: self.headerCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
//        if(artistImages != nil)
//        {
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
       // return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


