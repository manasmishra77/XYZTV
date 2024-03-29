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
    
    var metadata: MetadataModel?
    var item: Item?
    var userComingAfterLogin: Bool = false
    
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
   
        
        
        let imageUrl = ((metadata?.banner) != nil) ? (metadata?.banner)! : ""
        
        let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
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
               // print("id is === \(id!)")
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
        
        if (item?.app?.type == VideoType.TVShow.rawValue || item?.app?.type == VideoType.Episode.rawValue),metadata?.contentId != nil
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"13" ,"json":["id":(metadata?.contentId!)!]]
        }
        else if item?.app?.type == VideoType.Movie.rawValue,metadata?.contentId != nil
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"12" ,"json":["id":(metadata?.contentId!)!]]
        }
        
        if JCLoginManager.sharedInstance.isUserLoggedIn(){
            if metadata?.inQueue != nil {
                url = (metadata?.inQueue)! ? removeFromWatchListUrl : addToWatchListUrl
            }else{
                metadata?.inQueue = false
                url = addToWatchListUrl
            }
            
            
            callWebServiceToUpdateWatchlist(withUrl: url, andParameters: params)
            
        }else{
            isLoginPresentedFromAddToWatchlist = true
            userComingAfterLogin = true
            addToWatchListButton.isEnabled = true
            NotificationCenter.default.post(name: showLoginFromMetadataNotificationName, object: nil, userInfo: nil)
        }

    }
    
    func callWebServiceToUpdateWatchlist(withUrl url:String, andParameters params: Dictionary<String, Any>)
    {
        let updateWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: updateWatchlistRequest) { (data, response, error) in
            if let responseError = error as NSError?
            {
                //Refresh sso token call fails
                if responseError.code == 143{
                    print("Refresh sso token call fails")
                    DispatchQueue.main.async {
                        //JCLoginManager.sharedInstance.logoutUser()
                        //self.presentLoginVC()
                    }
                }
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
                        self.watchlistLabel.text = (self.metadata?.inQueue)! ? REMOVE_FROM_WATCHLIST : ADD_TO_WATCHLIST
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
                //print(responseError)
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
                if (JCDataStore.sharedDataStore.tvWatchList?.data?.items) != nil{
                    JCDataStore.sharedDataStore.tvWatchList?.data?.items?.insert(self.item!, at: 0)
                }
                else{
                    JCDataStore.sharedDataStore.tvWatchList?.data?.items = [self.item!]
                }
                //JCDataStore.sharedDataStore.tvWatchList?.data?.items?.insert(self.item!, at: 0)
            }
            else{
                JCDataStore.sharedDataStore.tvWatchList?.data?.items = JCDataStore.sharedDataStore.tvWatchList?.data?.items?.filter() { $0.id != self.metadata?.contentId
                    
                }
                
            }
            if let tvVC = JCAppReference.shared.tabBarCotroller?.viewControllers![2] as? JCTVVC{
                let indexpath = IndexPath(row: 0, section: 0)
                DispatchQueue.main.async {
                    if self.userComingAfterLogin{
                        self.userComingAfterLogin = false
                        tvVC.callWebServiceForTVWatchlist()
                        return
                    }
                    if JCDataStore.sharedDataStore.tvWatchList?.data?.items != nil{
                        if (JCDataStore.sharedDataStore.tvWatchList?.data?.items?.count)! > 1{
                            if tvVC.baseTableView != nil{
                                tvVC.baseTableView.reloadRows(at: [indexpath], with: .fade)
                            }
                            
                        }
                        else{
                            if (JCDataStore.sharedDataStore.tvWatchList?.data?.items?.count)! == 1{
                                tvVC.isTVWatchlistAvailable = true
                            }
                            if tvVC.baseTableView != nil{
                                tvVC.baseTableView.reloadData()
                            }
                            
                        }
                    }
                    
                }
               
            }
        }
        else if self.item?.app?.type == VideoType.Movie.rawValue{
            if (self.metadata?.inQueue)!{
                if (JCDataStore.sharedDataStore.moviesWatchList?.data?.items) != nil{
                    JCDataStore.sharedDataStore.moviesWatchList?.data?.items?.insert(self.item!, at: 0)
                }
                else{
                    JCDataStore.sharedDataStore.moviesWatchList?.data?.items = [self.item!]
                }
            }
            else{
                JCDataStore.sharedDataStore.moviesWatchList?.data?.items = JCDataStore.sharedDataStore.moviesWatchList?.data?.items?.filter() { $0.id != self.item?.id }
            }
            if let movieVC = JCAppReference.shared.tabBarCotroller?.viewControllers![1] as? JCMoviesVC{
                
                DispatchQueue.main.async {
                    if self.userComingAfterLogin{
                        self.userComingAfterLogin = false
                        movieVC.callWebServiceForMoviesWatchlist()
                        return
                    }
                   if JCDataStore.sharedDataStore.moviesWatchList?.data?.items != nil {
                        if (JCDataStore.sharedDataStore.moviesWatchList?.data?.items?.count)! > 1{
                            let indexpath = IndexPath(row: 0, section: 0)
                            if movieVC.baseTableView != nil {
                                movieVC.baseTableView.reloadRows(at: [indexpath], with: .fade)
                            }
                            
                        }
                        else{
                            if (JCDataStore.sharedDataStore.moviesWatchList?.data?.items?.count)! == 1{
                                movieVC.isMoviesWatchlistAvailable = true
                            }
                            if movieVC.baseTableView != nil {
                               movieVC.baseTableView.reloadData()
                            }
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    
    //Checking whether the item is in resume watch list or not
    func checkAndPlayItemInResumeWatchList() -> Bool
    {
        if let resumeWatchArray = JCDataStore.sharedDataStore.resumeWatchList?.data?.items, item?.id != nil
        {
            var newitem = self.item?.id
            if metadata?.type == VideoType.TVShow.rawValue{
                newitem = self.metadata?.latestEpisodeId
            }
            let itemMatched = resumeWatchArray.filter{ $0.id == newitem}.first
            // For resume watch, episode item type is 7
            if metadata?.type == VideoType.TVShow.rawValue{
                itemMatched?.app?.type = 7
            }
            if itemMatched != nil
            {
                self.item = itemMatched
                return true
            }
        }
        return false
    }
  
    
}

