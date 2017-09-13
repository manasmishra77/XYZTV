 //
//  JCPlayerVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import ObjectMapper
import AVKit
import AVFoundation

private var playerViewControllerKVOContext = 0

class JCPlayerVC: UIViewController
{
    @IBOutlet weak var nextVideoView                    :UIView!
    @IBOutlet weak var view_Recommendation              :UIView!
    @IBOutlet weak var nextVideoNameLabel               :UILabel!
    @IBOutlet weak var nextVideoPlayingTimeLabel        :UILabel!
    @IBOutlet weak var nextVideoThumbnail               :UIImageView!
    @IBOutlet weak var collectionView_Recommendation    :UICollectionView!


    var playerTimeObserverToken     :Any?
    var item                        :Any?

    var metadata                    :MetadataModel?

    var player                      :AVPlayer?
    var playerItem                  :AVPlayerItem?
    var playerController            :AVPlayerViewController?
    
    var playbackRightsData          :PlaybackRightsModel?
    var playlistData                :PlaylistDataModel?
    
    var currentItemImage            :String?
    var currentItemTitle            :String?
    var currentItemDuration         :String?
    var currentItemDescription      :String?
    var playerId                    :String?
    
    var isRecommendationView        = false
    var isResumed                   :Bool?

    var currentPlayingIndex         = -1
    
    var duration                    = 0.0
    
    var arr_RecommendationList = [Item]()

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        if metadata == nil
        {
            fetchRecommendationData()
        }
        
        self.collectionView_Recommendation.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let currentTime = player?.currentItem?.currentTime()
        {
            let currentTimeDuration = "\(CMTimeGetSeconds(currentTime))"
            let totalDuration = "\((CMTimeGetSeconds((player?.currentItem?.duration)!)))"
            self.callWebServiceForAddToResumeWatchlist(currentTimeDuration: currentTimeDuration, totalDuration: totalDuration)
        }
        if isResumed != nil
        {
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }

        if (player != nil)
        {
            removePlayerObserver()
        }
    }
    override func viewDidLayoutSubviews() {
        if self.view_Recommendation.frame.origin.y >= screenHeight - 30
        {
            self.setCustomRecommendationViewSetting(state: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Add Player Observer
    func addPlayerNotificationObserver () {
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        addObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.isPlaybackLikelyToKeepUp), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    func addPlayerPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        
        // Add time observer
        playerTimeObserverToken =
            self.player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
                [weak self] time in
                
                if self?.player != nil {
                    let currentPlayerTime = Double(CMTimeGetSeconds(time))
                    let remainingTime = (self?.getPlayerDuration())! - currentPlayerTime
                    
                    if UserDefaults.standard.bool(forKey: isAutoPlayOnKey),self?.playlistData != nil
                    {
                        let index = (self?.currentPlayingIndex)! + 1
                        
                        if index != self?.playlistData?.more?.count
                        {
                            if remainingTime <= 5
                            {
                                self?.nextVideoView.isHidden = false
                                self?.nextVideoNameLabel.text = self?.playlistData?.more?[index].name
                                self?.nextVideoPlayingTimeLabel.text = "Playing in " + "\(Int(remainingTime))" + " Seconds"
                                let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending( (self?.playlistData?.more?[index].banner)!)
                                RJILImageDownloader.shared.downloadImage(urlString: imageUrl!, shouldCache: false){
                                    
                                    image in
                                    
                                    if let img = image {
                                        DispatchQueue.main.async {
                                            self?.nextVideoThumbnail.image = img
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            self?.nextVideoView.isHidden = true
                        }
                    }
                    else
                    {
                        self?.nextVideoView.isHidden = true
                    }
                }
                else
                {
                    self?.playerTimeObserverToken = nil
                }
                
        }
    }
    
    //MARK:- Remove Player Observer
    func removePlayerObserver() {
        self.player?.pause()
        if let timeObserverToken = playerTimeObserverToken {
            self.player?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        removeObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.duration), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.rate), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.status), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.isPlaybackBufferEmpty), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(JCPlayerVC.player.currentItem.isPlaybackLikelyToKeepUp), context: &playerViewControllerKVOContext)
        self.playerTimeObserverToken = nil
        self.player = nil
    }

    //MARK:- AVPlayerViewController Methods
    
    func instantiatePlayer(with url:String)
    {
        if((self.player) != nil) {
            self.removePlayerObserver()
        }
        
        let videoUrl = URL(string: url)
        playerItem = AVPlayerItem(url: videoUrl!)
        
        self.addMetadataToPlayer()
        player = AVPlayer(playerItem: playerItem)
        
        if playerController == nil {
            
            playerController = AVPlayerViewController()
            if isResumed != nil, isResumed!
            {
                player?.seek(to: CMTimeMakeWithSeconds(duration, (player?.currentItem?.asset.duration.timescale)!))
            }
            self.addChildViewController(playerController!)
            self.view.addSubview((playerController?.view)!)
            playerController?.view.frame = self.view.frame
        }
        addPlayerNotificationObserver()
        
        playerController?.player = player
        player?.play()
        
        self.view.bringSubview(toFront: self.nextVideoView)
        self.view.bringSubview(toFront: self.view_Recommendation)
        self.nextVideoView.isHidden = true
        
        //self.collectionView_Recommendation.reloadData()
        
    }
    
    func addMetadataToPlayer()
    {
        let titleMetadataItem = AVMutableMetadataItem()
        titleMetadataItem.identifier = AVMetadataCommonIdentifierTitle
        titleMetadataItem.extendedLanguageTag = "und"
        titleMetadataItem.locale = NSLocale.current
        titleMetadataItem.key = AVMetadataCommonKeyTitle as NSCopying & NSObjectProtocol
        titleMetadataItem.keySpace = AVMetadataKeySpaceCommon
        if currentItemTitle != nil
        {
            titleMetadataItem.value = currentItemTitle! as NSCopying & NSObjectProtocol
        }
        
        let descriptionMetadataItem = AVMutableMetadataItem()
        descriptionMetadataItem.identifier = AVMetadataCommonIdentifierDescription
        descriptionMetadataItem.extendedLanguageTag = "und"
        descriptionMetadataItem.locale = NSLocale.current
        descriptionMetadataItem.key = AVMetadataCommonKeyDescription as NSCopying & NSObjectProtocol
        descriptionMetadataItem.keySpace = AVMetadataKeySpaceCommon
        if currentItemDescription != nil
        {
            descriptionMetadataItem.value = currentItemDescription! as NSCopying & NSObjectProtocol
        }
        
        
        let imageMetadataItem = AVMutableMetadataItem()
        imageMetadataItem.identifier = AVMetadataCommonIdentifierArtwork
        imageMetadataItem.extendedLanguageTag = "und"
        imageMetadataItem.locale = NSLocale.current
        imageMetadataItem.key = AVMetadataCommonKeyArtwork as NSCopying & NSObjectProtocol
        imageMetadataItem.keySpace = AVMetadataKeySpaceCommon
        if currentItemImage != nil
        {
            let imageUrl = (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(currentItemImage!))!
            
            
            RJILImageDownloader.shared.downloadImage(urlString: imageUrl, shouldCache: false){
                
                image in
                
                if let img = image {
                    DispatchQueue.main.async {
                        let pngData = UIImagePNGRepresentation(img)
                        imageMetadataItem.value = pngData as (NSCopying & NSObjectProtocol)?
                    }
                }
            }
        }
        
        //        let durationMetadataItem = AVMutableMetadataItem()
        //        durationMetadataItem.key = AVMetadatacommonkey as NSCopying & NSObjectProtocol
        //        durationMetadataItem.keySpace = AVMetadataKeySpaceCommon
        //        durationMetadataItem.value = currentItemDescription! as NSCopying & NSObjectProtocol
        
        
        
        playerItem?.externalMetadata.append(titleMetadataItem)
        playerItem?.externalMetadata.append(descriptionMetadataItem)
        playerItem?.externalMetadata.append(imageMetadataItem)
        
    }
    func getPlayerDuration() -> Double {
        guard let currentItem = self.player?.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(JCPlayerVC.player.currentItem.duration) {
            // Update timeSlider and enable/disable controls when duration > 0.0
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = kCMTimeZero
            }
            Log.DLog(message: newDuration as AnyObject)
        }
        else if keyPath == #keyPath(JCPlayerVC.player.rate) {
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            //  self.playerDelegate?.didILinkPlayerStatusRate(rate: newRate)
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackBufferEmpty)
        {
            // self.playerDelegate?.didILinkPlayerStatusBufferEmpty()
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackLikelyToKeepUp)
        {
            //  self.playerDelegate?.didILinkPlayerStatusPlaybackLikelyToKeepUp()
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.status) {
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
            }
            switch newStatus {
            case .readyToPlay:
                self.addPlayerPeriodicTimeObserver()
                self.collectionView_Recommendation.reloadData()
                break
            case .failed:
                Log.DLog(message: "Failed" as AnyObject)
            default:
                print("unknown")
            }
            
            if newStatus == .failed {
            }
        }
    }
    //MARK:- AVPlayer Finish Playing Item
    func playerDidFinishPlaying(note: NSNotification) {
        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
        {
            if metadata != nil
            {
                if metadata?.app?.type == VideoType.TVShow.rawValue
                {
//                    let model = metadata?.episodes?[indexPath.row]
//                    metaDataID = (metadata?.latestEpisodeId)!
//                    modelID = (model?.id)!
//                    imageUrl = (model?.banner)!
//                    cell.nameLabel.text = model?.name
                }
                else if metadata?.app?.type == VideoType.Movie.rawValue
                {
//                    let model = metadata?.more?[indexPath.row]
//                    // metaDataID = (metadata?.id)!
//                    modelID = (model?.id)!
//                    imageUrl = (model?.banner)!
//                    cell.nameLabel.text = model?.name
                }
                return
            }
            else // For Clips,Music or Playlist
            {
                if let data = self.item as? Item
                {
                    if data.isPlaylist!
                    {
                        handlePlayListNextItem()
                    }
                    else {
                    
                    }
                }
                else if let data = self.item as? Episode {
                
                }

            }
        }
        else
        {
            dismissPlayerVC()
        }
    }

    func handlePlayListNextItem()
    {
        self.currentPlayingIndex = self.currentPlayingIndex + 1
        if self.currentPlayingIndex != self.playlistData?.more?.count
        {
            let moreId = self.playlistData?.more?[self.currentPlayingIndex].id
            self.currentItemImage = self.playlistData?.more?[self.currentPlayingIndex].banner
            self.currentItemTitle = self.playlistData?.more?[self.currentPlayingIndex].name
            self.currentItemDuration = String(describing: self.playlistData?.more?[self.currentPlayingIndex].totalDuration)
            self.currentItemDescription = self.playlistData?.more?[self.currentPlayingIndex].description
            self.callWebServiceForPlaybackRights(id: moreId!)
        }
        else
        {
            dismissPlayerVC()
        }
    }
    
    //MARK:- Custom Methods
    //MARK:- Download Image
    func downloadImageFrom(urlString:String,completionHandler:@escaping (UIImage)->Void)
    {
        let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(urlString)
        RJILImageDownloader.shared.downloadImage(urlString: imageUrl!, shouldCache: true){
            image in
            if let img = image {
                completionHandler(img)
            }
        }
    }

    //MARK:- Open MetaDataVC
    func openMetaDataVC(model:More)
    {
        if let topController = UIApplication.topViewController() {
            let tempItem = Item()
            tempItem.id = model.id
            tempItem.name = model.name
            tempItem.banner = model.banner
            let app = App()
            app.type = VideoType.Movie.rawValue
            tempItem.app = app
            
            let metadataVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
            metadataVC.item = tempItem
            metadataVC.modalPresentationStyle = .overFullScreen
            metadataVC.modalTransitionStyle = .coverVertical
            topController.present(metadataVC, animated: true, completion: nil)
        }
    }
    func hideUnhideNowPlayingView(cell:JCItemCell,state:Bool)
    {
        DispatchQueue.main.async {
            cell.view_NowPlaying.isHidden = state
            cell.isUserInteractionEnabled = state
        }
    }
    //MARK:- Custom Setting
    func setCustomRecommendationViewSetting(state:Bool)
    {
        self.collectionView_Recommendation.isScrollEnabled = state
        self.isRecommendationView = state
        self.collectionView_Recommendation.reloadData()
    }
    
    
    //MARK:- Dismiss Viewcontroller
    func dismissPlayerVC()
    {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:- Add Swipe Gesture
    func addSwipeGesture()
    {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandler))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandler))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)

    }
    
    func swipeGestureHandler(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                self.swipeUpRecommendationView()
                break
            case UISwipeGestureRecognizerDirection.down:
                self.swipeDownRecommendationView()
            break
            default:
                break
            }
        }
    }
    
    //MARK:- Swipe Up Recommendation View
    func swipeUpRecommendationView()
    {
        Log.DLog(message: "swipeUpRecommendationView" as AnyObject)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view_Recommendation.frame = CGRect(x: 0, y: screenHeight-300, width: screenWidth, height: self.view_Recommendation.frame.height)
            }, completion: { (completed) in
                self.setCustomRecommendationViewSetting(state: true)
            })
        }
    }
    //MARK:- Swipe Down Recommendation View
    func swipeDownRecommendationView()
    {
        Log.DLog(message: "swipeDownRecommendationView" as AnyObject)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view_Recommendation.frame = CGRect(x: 0, y: screenHeight-30, width: screenWidth, height: self.view_Recommendation.frame.height)
            }, completion: { (completed) in
                self.setCustomRecommendationViewSetting(state: false)
            })
        }
    }
    
    //MARK:- Webservice Methods
    func fetchRecommendationData()
    {
        if let data = self.item as? Item
        {
            if data.isPlaylist!
            {
                self.callWebServiceForPlayListData(id: data.playlistId!)
            }
            else{
            
            if data.app?.type == VideoType.Movie.rawValue
            {
                let url = metadataUrl.appending(data.id!)
                self.callWebServiceForMoreLikeData(url: url)
            }
            else if data.app?.type == VideoType.TVShow.rawValue
            {
                let url = metadataUrl.appending(data.id!).appending("/0/0")
                self.callWebServiceForMoreLikeData(url: url)
            }
            else if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue
            {
                if selectedItemFromViewController == VideoType.Music
                {
                    arr_RecommendationList = (JCDataStore.sharedDataStore.musicData?.data?[collectionIndex].items)!
                }
                else if selectedItemFromViewController == VideoType.Clip
                {
                    arr_RecommendationList = (JCDataStore.sharedDataStore.clipsData?.data?[collectionIndex].items)!
                }
                else if selectedItemFromViewController == VideoType.Home
                {
                    arr_RecommendationList = (JCDataStore.sharedDataStore.mergedHomeData?[collectionIndex].items!)!
                }
                self.collectionView_Recommendation.reloadData()
            }
            }
        }
    }
    
    
    func callWebServiceForMoreLikeData(url:String)
    {
        let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMoreLikeData(dictionaryResponseData: responseData)
                DispatchQueue.main.async {
                    weakSelf?.collectionView_Recommendation.reloadData()
                }
                return
            }
        }
    }
    
    func evaluateMoreLikeData(dictionaryResponseData responseData:Data)
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            let tempMetadata = MetadataModel(JSONString: responseString)
            
            
//            if let data = self.item as? Item
//            {
//                
//                
//                if data.app?.type == VideoType.Movie.rawValue
//                {
//                    let url = metadataUrl.appending(data.id!)
//                    self.callWebServiceForMoreLikeData(url: url)
//                }
//                else if data.app?.type == VideoType.TVShow.rawValue
//                {
//                    let url = metadataUrl.appending(data.id!).appending("/0/0")
//                    self.callWebServiceForMoreLikeData(url: url)
//                }
//            }
//
            
            
            self.metadata = tempMetadata
        }
    }
    
    func callWebServiceForPlayListData(id:String)
    {
        playerId = id
        let url = String(format:"%@%@/%@",playbackDataURL,JCAppUser.shared.userGroup,id)
        let params = ["id":id,"contentId":""]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { (data, response, error) in
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
                    self.playlistData = PlaylistDataModel(JSONString: responseString)
                    if (self.playlistData?.more?.count)! > 0
                    {
                        self.collectionView_Recommendation.reloadData()
                        self.currentPlayingIndex = 0
                        let moreId = self.playlistData?.more?[self.currentPlayingIndex].id
                        self.currentItemImage = self.playlistData?.more?[self.currentPlayingIndex].banner
                        self.currentItemTitle = self.playlistData?.more?[self.currentPlayingIndex].name
                        self.currentItemDuration = String(describing: self.playlistData?.more?[self.currentPlayingIndex].totalDuration)
                        self.currentItemDescription = self.playlistData?.more?[self.currentPlayingIndex].description
                        self.callWebServiceForPlaybackRights(id: moreId!)
                    }
                }
                return
            }
        }
    }
    
    func callWebServiceForPlaybackRights(id:String)
    {
        playerId = id
        let url = playbackRightsURL.appending(id)
        let params = ["id":id,"showId":"","uniqueId":JCAppUser.shared.unique,"deviceType":"stb"]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { (data, response, error) in
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
                    self.playbackRightsData = PlaybackRightsModel(JSONString: responseString)
                    DispatchQueue.main.async {
                        weakSelf?.instantiatePlayer(with: (weakSelf?.playbackRightsData!.aesUrl!)!)
                    }
                }
                return
            }
        }
    }
    
    func callWebServiceForAddToResumeWatchlist(currentTimeDuration:String,totalDuration:String)
    {
        let url = addToResumeWatchlistUrl
        let json: Dictionary<String, Any> = ["id":playerId!, "duration":currentTimeDuration, "totalduration": totalDuration]
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = JCAppUser.shared.unique
        params["listId"] = 10
        params["json"] = json
        params["id"] = playerId
        params["duration"] = currentTimeDuration
        params["totalduration"] = totalDuration
        
        let addToResumeWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: addToResumeWatchlistRequest) { (data, response, error) in
            if let responseError = error
            {
                print(responseError)
                return
            }
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                //                let code = parsedResponse["code"] as? Int
                print("Added to Resume Watchlist")
                return
            }
        }
    }
    
    
  }
 
 //MARK:- UICOLLECTIONVIEW DELEGATE
 extension JCPlayerVC: UICollectionViewDelegate
 {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return isRecommendationView
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.swipeDownRecommendationView()
       // var url = ""
        if metadata != nil
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue
                {
                        let model = metadata?.episodes?[indexPath.row]
                        self.currentItemImage = model?.banner
                        self.currentItemTitle = model?.name
                        self.callWebServiceForPlaybackRights(id: (model?.id)!)
                       // url = metadataUrl.appending((model?.id!)!)
                       // self.callWebServiceForMoreLikeData(url: url)
                }
            else if metadata?.app?.type == VideoType.Movie.rawValue
                {
                        let model = metadata?.more?[indexPath.row]
                        self.currentItemImage = model?.banner
                        self.currentItemTitle = model?.name
                        self.currentItemDescription = model?.description
                    
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                              self.openMetaDataVC(model: model!)
                        }
                    })
                        // self.callWebServiceForPlaybackRights(id: (model?.id)!)
                        // url = metadataUrl.appending((model?.id!)!)
                        return
                }
        }
        else
        {
            if let data = self.item as? Item
            {
                if data.isPlaylist!     // If Playlist exist
                {
                    self.currentPlayingIndex = indexPath.row
                    let model = self.playlistData?.more?[indexPath.row]
                    self.currentItemImage = model?.banner
                    self.currentItemTitle = model?.name
                    self.callWebServiceForPlaybackRights(id: (model?.id)!)
                }
                else
                if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue
                {
                    let model = arr_RecommendationList[indexPath.row]
                    self.item = model
                    self.currentItemImage = model.banner
                    self.currentItemTitle = model.name
                    self.callWebServiceForPlaybackRights(id: (model.id)!)
                }
            }
        }
    }
 }
 //MARK:- UICOLLECTIONVIEW DATASOURCE

 extension JCPlayerVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if metadata != nil, metadata?.more != nil
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue
            {
                return (metadata?.episodes?.count)!
            }
            else if metadata?.app?.type == VideoType.Movie.rawValue

            {
                return (metadata?.more?.count)!
            }
        }
       else if let data = self.item as? Item
        {
            if data.isPlaylist!     // If Playlist exist
            {
                if playlistData != nil
                {
                    return (playlistData?.more?.count)!
                }
            }
            else
            {
                return arr_RecommendationList.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        
        var imageUrl    = ""
        var modelID     = ""
        var metaDataID  = ""
        
        if metadata?.app?.type == VideoType.TVShow.rawValue
        {
            let model = metadata?.episodes?[indexPath.row]
            metaDataID = (metadata?.latestEpisodeId)!
            modelID = (model?.id)!
            imageUrl = (model?.banner)!
            cell.nameLabel.text = model?.name
        }
        else if metadata?.app?.type == VideoType.Movie.rawValue
        {
            let model = metadata?.more?[indexPath.row]
           // metaDataID = (metadata?.id)!
            modelID = (model?.id)!
            imageUrl = (model?.banner)!
            cell.nameLabel.text = model?.name
        }
        else // For Clips,Music or Playlist
        {
            if let data = self.item as? Item
            {
                if data.isPlaylist!
                {
                    let model = self.playlistData?.more?[indexPath.row]
                    modelID = (model?.id)!
                    imageUrl = (model?.banner)!
                    cell.nameLabel.text = model?.name
                }
                else
                {
                    let model = arr_RecommendationList[indexPath.row]
                    modelID = (model.id)!
                    imageUrl = (model.banner)!
                    cell.nameLabel.text = model.name
                }
            }
        }
        
        if metadata != nil
        {
            if metaDataID == modelID
            {
                self.hideUnhideNowPlayingView(cell: cell, state: false)
            }
            else
            {
                self.hideUnhideNowPlayingView(cell: cell, state: true)
            }
        }
        else // For Clips,Music or Playlist item
        {
            if let data = self.item as? Item
            {
                if data.isPlaylist!
                {
                    let currentPlayingPlayListItemID = self.playlistData?.more?[self.currentPlayingIndex].id
                    if currentPlayingPlayListItemID == modelID
                    {
                        self.hideUnhideNowPlayingView(cell: cell, state: false)
                    }
                    else
                    {
                        self.hideUnhideNowPlayingView(cell: cell, state: true)
                    }
                }
                else{
                
                if data.id == modelID
                {
                    self.hideUnhideNowPlayingView(cell: cell, state: false)
                }
                else
                {
                    self.hideUnhideNowPlayingView(cell: cell, state: true)
                }
            }
            }
            else if let data = self.item as? Episode
            {
                if data.id == modelID
                {
                    self.hideUnhideNowPlayingView(cell: cell, state: false)
                }
                else
                {
                    self.hideUnhideNowPlayingView(cell: cell, state: true)
                }
            }
        }
        
        if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
        {
            cell.itemImageView.image = image
        }
        else
        {
            self.downloadImageFrom(urlString: imageUrl, completionHandler: { (downloadImage) in
                cell.itemImageView.image = downloadImage
            })
        }
        return cell
    }
 
 }
 //MARK:- PlaybackRight Model

class PlaybackRightsModel:Mappable
{
    var code:Int?
    var message:String?
    var duration:Float?
    var inqueue:Bool?
    var totalDuration:String?
    var isSubscribed:Bool?
    var subscription:Subscription?
    var aesUrl:String?
    var url:String?
    var tinyUrl:String?
    var text:String?
    var contentName:String?
    var thumb:String?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        duration <- map["duration"]
        inqueue <- map["inqueue"]
        totalDuration <- map["totalDuration"]
        totalDuration <- map["totalDuration"]
        isSubscribed <- map["isSubscribed"]
        subscription <- map["subscription"]
        aesUrl <- map["aesUrl"]
        url <- map["url"]
        tinyUrl <- map["tinyUrl"]
        text <- map["text"]
        contentName <- map["contentName"]
        thumb <- map["thumb"]
        
    }
}
 //MARK:- Subscription Model

class Subscription:Mappable
{
    var isSubscribed:Bool?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        isSubscribed <- map["isSubscribed"]
    }
}
 //MARK:- PlaylistDataModel Model

class PlaylistDataModel: Mappable {
    
    var more: [More]?
    
    required init(map:Map) {
    }
    
    func mapping(map:Map)
    {
        
        more <- map["more"]
    }
    
}
