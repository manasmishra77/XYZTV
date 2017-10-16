//
//  MetadataHeaderViewCell.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 09/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage


class MetadataHeaderViewCell: UIView {
    
    var metadata:MetadataModel?
    var item:Item?
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
        
        if #available(tvOS 11.0, *) {
            constarintForContainer.constant = -60
            
        } else {
            
        }
        
    }
    
    func prepareView() ->UIView
    {
        
        self.titleLabel.text = metadata?.name
        self.subtitleLabel.text = metadata?.newSubtitle
        self.directorLabel.text = metadata?.directors?.joined(separator: ",")
        if metadata?.directors?.count == 0 || metadata?.directors == nil{
            directorStaticLabel.isHidden = true
        }
        if metadata?.artist?.count == 0 || metadata?.artist == nil{
            starringStaticLabel.isHidden = true
        }
        if metadata?.artist != nil{
                 self.starringLabel.text = (metadata?.artist?.joined(separator: ",").characters.count)! > 55 ? (metadata?.artist?.joined(separator: ",").subString(start: 0, end: 51))! + "...." : metadata?.artist?.joined(separator: ",")
        }
   
        
        
        let imageUrl = metadata?.banner
        let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl!))!)
        DispatchQueue.main.async {
            self.bannerImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in})
        }
        
        if item?.app?.type == VideoType.Movie.rawValue, metadata != nil
        {
            self.ratingLabel.text = metadata?.rating?.appending("/10 |")
            return self
        }
        else if item?.app?.type == VideoType.TVShow.rawValue, metadata != nil
        {
            self.titleLabel.text = metadata?.name
            self.imdbImageLogo.isHidden = true
            self.ratingLabel.isHidden = true
            self.subtitleLabel.isHidden = true
            self.tvShowSubtitleLabel.isHidden = false
            self.tvShowSubtitleLabel.text = metadata?.newSubtitle
            
            if (metadata?.isSeason) != nil
            {
                if (metadata?.isSeason)!
                {
                    seasonsLabel.isHidden = false
                    seasonCollectionView.isHidden = false
                    monthsCollectionView.isHidden = true
                }
                else
                {
                    seasonsLabel.isHidden = false
                    seasonsLabel.text = "Previous Episodes"
                    seasonCollectionView.isHidden = false
                    monthsCollectionView.isHidden = false
                }
            }
            
            return self
        }
        else
        {
            return UIView.init()
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
        if playerVC_Global == nil {
            let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
            var id:String?
            
            if checkAndPlayItemInResumeWatchList(){
                let playerItem = ["item": self.item , "isForResumeScreen": true] as [String : Any]
                 NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: playerItem)
                return
            }
            
            
            if item?.app?.type == VideoType.Movie.rawValue
            {
                if let itemId = item?.id
                {
                    id = itemId
                    playerVC.currentItemTitle = item?.name
                    playerVC.currentItemDescription = item?.description
                    playerVC.currentItemDuration = String(describing: item?.duration)
                    playerVC.currentItemImage = item?.banner
                }
            }
            else
            {
                if let latestId = metadata?.latestEpisodeId
                {
                    id = latestId
                    playerVC.currentItemTitle = metadata?.name
                    playerVC.currentItemDescription = metadata?.description
                    playerVC.currentItemImage = metadata?.banner
                }
            }
            if id != nil
            {
                if JCLoginManager.sharedInstance.isUserLoggedIn()
                {
                    //OPTIMIZATION PLAYERVC
                    // playerVC.callWebServiceForPlaybackRights(id: id!)
                }
                print("id is === \(id!)")
                playerVC.playerId = id!
                playerVC.item = item
                
                playerVC.modalPresentationStyle = .overFullScreen
                playerVC.modalTransitionStyle = .coverVertical
                latestEpisodeId = id!
                let playerItem = ["player":playerVC]
                NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: playerItem)
            }
        }
        
    }
    
    
    @IBAction func didClickOnAddToWatchListButton(_ sender: Any)
    {
        addToWatchlistButtonClicked()
    }
    
    func addToWatchlistButtonClicked()
    {
        addToWatchListButton.isEnabled = false
        var params = [String:Any]()
        var url = ""
        
        if item?.app?.type == VideoType.TVShow.rawValue,metadata?.contentId != nil
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"13" ,"json":["id":(metadata?.contentId!)!]]
        }
        else if item?.app?.type == VideoType.Movie.rawValue,metadata?.contentId != nil
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"12" ,"json":["id":(metadata?.contentId!)!]]
        }
        
        if JCLoginManager.sharedInstance.isUserLoggedIn(){
            url = (metadata?.inQueue)! ? removeFromWatchListUrl : addToWatchListUrl
            
            callWebServiceToUpdateWatchlist(withUrl: url, andParameters: params)
            
        }else{
            isLoginPresentedFromAddToWatchlist = true
            NotificationCenter.default.post(name: showLoginFromMetadataNotificationName, object: nil, userInfo: nil)
        }
        
        
        
        //        else
        //        {
        //            isLoginPresentedFromAddToWatchlist = true
        //            NotificationCenter.default.post(name: showLoginFromMetadataNotificationName, object: nil, userInfo: nil)
        //        }
    }
    
    func callWebServiceToUpdateWatchlist(withUrl url:String, andParameters params: Dictionary<String, Any>)
    {
        let updateWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: updateWatchlistRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data,let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                let code = parsedResponse["code"] as? Int
                if(code == 200)
                {
                    self.metadata?.inQueue = !(self.metadata?.inQueue)!
 
                    DispatchQueue.main.async {
                        self.addToWatchListButton.isEnabled = true
                        self.watchlistLabel.text = (self.metadata?.inQueue)! ? "Remove from watchlist" : "Add to watchlist"
                    }
                    //ChangingTheDataSourceForWatchListItems
                    self.changingDataSourceForWatchList()
                }
                return
            }
        }
        
    }
    
    func callWebServiceForWatchlistStatus()
    {
        let url = playbackRightsURL.appending((item?.id)!)
        let params : [String : Any] = ["id":item?.id as Any,"showId":"","uniqueId":JCAppUser.shared.unique,"deviceType":"stb"]
        let watchlistStatusRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: watchlistStatusRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    let playbackRightsData = PlaybackRightsModel(JSONString: responseString)
                    weakSelf?.metadata?.inQueue = playbackRightsData?.inqueue
                    
                    DispatchQueue.main.async {
                        self.addToWatchlistButtonClicked()
                    }
                }
                return
                
            }
            
        }
        
    }
    //ChangingTheDataSourceForWatchListItems
    func changingDataSourceForWatchList() {
        if self.item?.app?.type == VideoType.TVShow.rawValue{
            if (self.metadata?.inQueue)!{
                JCDataStore.sharedDataStore.tvWatchList?.data?.items?.insert(self.item!, at: 0)
            }
            else{
                JCDataStore.sharedDataStore.tvWatchList?.data?.items?.filter() { $0.id != self.metadata?.contentId }
            }
            
            
        }
    }
    
    //Checking whether the item is in resume watch list or not
    func checkAndPlayItemInResumeWatchList() -> Bool
    {
        if let resumeWatchArray = JCDataStore.sharedDataStore.resumeWatchList?.data?.items, item?.id != nil
        {
            let newitem = self.metadata?.latestEpisodeId
            let itemMatched = resumeWatchArray.filter{ $0.id == newitem}.first
            if itemMatched != nil
            {
                // For resume watch, item type is 7
                itemMatched?.app?.type = 7
                self.item = itemMatched
                return true
            }
        }
        return false
    }
  
    
}
extension String {
    func subString(start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: end)
        
        let finalString = self.substring(from: startIndex)
        return finalString.substring(to: endIndex)
    }}
