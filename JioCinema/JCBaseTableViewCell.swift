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
        self.tableCellCollectionView.register(UINib.init(nibName: "JCResumeWatchCell", bundle: nil), forCellWithReuseIdentifier: resumeWatchCellIdentifier)
        // Initialization code
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
            DispatchQueue.main.async {
                
                let xAxis = 2 * cell.itemImageView.frame.origin.x
                let newFrame = CGRect.init(x: xAxis, y: cell.itemImageView.frame.origin.y, width: cell.itemImageView.frame.size.height , height: cell.itemImageView.frame.size.height)
                cell.itemImageView.frame = newFrame
                cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2

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
            cell.nameLabel.text = artistName
            
            cell.backgroundColor = UIColor.black
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
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionIndex = collectionView.tag
        selectedItemFromViewController = self.itemFromViewController!
        
        if data != nil
        {
            if isSearchOpenFromMetaData
            {
                isSearchOpenFromMetaData = false
                
                let item = self.data?[indexPath.row]
                print("Tap item is \(item)")
                if item?.app?.type == VideoType.Movie.rawValue || item?.app?.type == VideoType.TVShow.rawValue
                {
                    if let topController = UIApplication.topViewController() {
                        topController.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
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
            let itemToPlay = ["item":(data?[indexPath.row])!]
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
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        playerVC.currentItemImage = item.banner
        playerVC.currentItemTitle = item.name
        playerVC.currentItemDuration = String(describing: item.totalDuration)
        playerVC.currentItemDescription = item.subtitle
        playerVC.callWebServiceForPlaybackRights(id: item.id!)
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
        
        return CGSize(width: 320, height: collectionView.frame.height)
        
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


