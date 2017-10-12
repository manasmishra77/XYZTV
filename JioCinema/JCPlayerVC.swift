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
 import SDWebImage
 
 
 let URL_SCHEME_NAME = "skd"
 let URL_GET_KEY =  "http://prod.media.jio.com/apis/06758e99be484fca56fb/v3/fps/getkey"
 let URL_GET_CERT = "http://prod.media.jio.com/apis/06758e99be484fca56fb/v3/fps/getcert"
 
 let PLAYABLE_KEY = "playable"
 let STATUS_KEY = "status"
 let AVPLAYER_BUFFER_KEEP_UP = "playbackLikelyToKeepUp"
 let AVPLAYER_BUFFER_EMPTY = "playbackBufferEmpty"
 
 private var playerViewControllerKVOContext = 0
 
 private func globalNotificationQueue() -> DispatchQueue {
    var globalQueue = 0 as? DispatchQueue
    var getQueueOnce: Int = 0
    if (getQueueOnce == 0) {
        globalQueue = DispatchQueue(label: "tester notify queue")
    }
    getQueueOnce = 1
    return globalQueue!
 }
 
 
 class JCPlayerVC: UIViewController
 {
    @IBOutlet weak var nextVideoView                    :UIView!
    @IBOutlet weak var view_Recommendation              :UIView!
    @IBOutlet weak var nextVideoNameLabel               :UILabel!
    @IBOutlet weak var nextVideoPlayingTimeLabel        :UILabel!
    @IBOutlet weak var nextVideoThumbnail               :UIImageView!
    @IBOutlet weak var collectionView_Recommendation    :UICollectionView!
    
    var isVideoUrlFailedCount = 1
    
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

    var moreModal:More?
    
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        playerVC_Global = self
        addSwipeGesture()
        if metadata == nil
        {
            fetchRecommendationData()
        }
        else
        {
            
            if metadata?.app?.type == VideoType.TVShow.rawValue
            {
                print("metadata id = \(metadata?.id)")
                print("player id = \(playerId)")
                self.callWebServiceForPlaybackRights(id: playerId!)
                if metadata?.episodes != nil
                {
                    for i in 0 ..< (metadata?.episodes?.count)!
                    {
                        let model = metadata?.episodes?[i]
                        if model?.id == playerId
                        {
                            self.currentPlayingIndex = i
                            break
                        }
                    }
                    self.scrollCollectionViewToRow(row: self.currentPlayingIndex)
                }
            }
          else if metadata?.app?.type == VideoType.Movie.rawValue
            {
                self.callWebServiceForPlaybackRights(id: playerId!)
            }
        }
        self.collectionView_Recommendation.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let currentTime = player?.currentItem?.currentTime()
        {
            let currentTimeDuration = "\(CMTimeGetSeconds(currentTime))"
            let totalDuration = "\((CMTimeGetSeconds((player?.currentItem?.duration)!)))"
            
            if (CMTimeGetSeconds((player?.currentItem?.duration)!) - CMTimeGetSeconds(currentTime) < 300)
            {
                self.callWebServiceForRemovingResumedWatchlist()
            }
            else
            {
                self.callWebServiceForAddToResumeWatchlist(currentTimeDuration: currentTimeDuration, totalDuration: totalDuration)
            }
        }
        if isResumed == true
        {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    if self.moreModal != nil
                    {
                        self.isResumed = false
                        self.openMetaDataVC(model: self.moreModal!)
                    }
                }
            })
            // self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
        
        if (player != nil)
        {
            removePlayerObserver()
        }
        playerVC_Global = nil
        latestEpisodeId = "-1"
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
                    
                    if remainingTime <= 5
                    {
                        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
                        {
                            
                            if self?.metadata != nil
                            {
                                
                                if self?.metadata?.app?.type == VideoType.TVShow.rawValue, self?.metadata?.episodes != nil
                                {
                                    let index = (self?.currentPlayingIndex)! - 1
                               
                                    if index >= 0
                                    {
                                        let modal = self?.metadata?.episodes?[index]
                                        self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                    }
                                    else
                                    {
                                        self?.nextVideoView.isHidden = true
                                    }
                                }
                                else if self?.metadata?.app?.type == VideoType.Trailer.rawValue, self?.metadata?.more != nil
                                {
                                    let index = (self?.currentPlayingIndex)! + 1
                                    
                                    if index >= 0
                                    {
                                        let modal = self?.metadata?.more?[index]
                                        self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                    }
                                    else
                                    {
                                        self?.nextVideoView.isHidden = true
                                    }
                                }
                                else if self?.metadata?.app?.type == VideoType.Movie.rawValue, self?.metadata?.more != nil
                                {
                                    /* if index != self?.metadata?.more?.count
                                     {
                                     let modal = self?.metadata?.more?[index]
                                     self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                     }
                                     else
                                     {
                                     self?.nextVideoView.isHidden = true
                                     }
                                     */
                                }
                            }
                            else if let data = self?.item as? Item
                            {
                                let index = (self?.currentPlayingIndex)! + 1
                                
                                if data.isPlaylist!     // If Playlist exist
                                {
                                    if self?.playlistData != nil
                                    {
                                        if index != self?.playlistData?.more?.count
                                        {
                                            let modal = self?.playlistData?.more?[index]
                                            self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                        }
                                        else
                                        {
                                            self?.nextVideoView.isHidden = true
                                        }
                                    }
                                }
                                else
                                {
                                    if index != self?.arr_RecommendationList.count
                                    {
                                        let modal = self?.arr_RecommendationList[index]
                                        self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                    }
                                    else
                                    {
                                        self?.nextVideoView.isHidden = true
                                    }
                                }
                            }
                        }
                        else
                        {
                            self?.nextVideoView.isHidden = true
                        }
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
    
    func resetPlayer()
    {
        if((self.player) != nil) {
            self.player?.pause()
            self.removePlayerObserver()
            self.playerController = nil
        }
    }
    
    func instantiatePlayer(with url:String)
    {
        self.resetPlayer()
        if metadata != nil  // For Handling FPS URL
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue || metadata?.app?.type == VideoType.Movie.rawValue
            {
                handleFairPlayStreamingUrl(videoUrl: url)
            }
            else
            {
                handleAESStreamingUrl(videoUrl: url)
            }
        }
        else
        {
                handleAESStreamingUrl(videoUrl: url)
        }
    }
   
    //MARK:- Handle AES Video Url

    func handleAESStreamingUrl(videoUrl:String)
    {
        var videoAsset:AVURLAsset?
        if JCDataStore.sharedDataStore.cdnEncryptionFlag
        {
            let videoUrl = URL.init(string: videoUrl)
            if let absoluteUrlString = videoUrl?.absoluteString
            {
                let changedUrl = absoluteUrlString.replacingOccurrences(of: (videoUrl?.scheme!)!, with: "fakeHttp")
                let headerValues = ["ssotoken" : JCAppUser.shared.ssoToken]
                let header = ["AVURLAssetHTTPHeaderFieldsKey" : headerValues]
                videoAsset = AVURLAsset(url: URL.init(string: changedUrl)!, options: header)
                videoAsset?.resourceLoader.setDelegate(self, queue: DispatchQueue(label: "testVideo-delegateQueue"))
            }
        }
        else
        {
            videoAsset = AVURLAsset(url:URL.init(string: videoUrl)!)
        }
        playerItem = AVPlayerItem.init(asset: videoAsset!)
        self.playVideoWithPlayerItem()
    }
    
    //MARK:- Handle Fairplay Video Url
    func handleFairPlayStreamingUrl(videoUrl:String)
    {
        let url = URL(string: videoUrl)
        let asset = AVURLAsset(url: url!, options: nil)
        asset.resourceLoader.setDelegate(self, queue: globalNotificationQueue())
        let requestedKeys: [Any] = [PLAYABLE_KEY]
        // Tells the asset to load the values of any of the specified keys that are not already loaded.
        asset.loadValuesAsynchronously(forKeys: requestedKeys as? [String] ?? [String](), completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                self.prepare(toPlay: asset, withKeys: JCPlayerVC.assetKeysRequiredToPlay)
            })
        })
    }
    func prepare(toPlay asset: AVURLAsset, withKeys requestedKeys: [String]) {
        
        for key in JCPlayerVC.assetKeysRequiredToPlay {
            var error: NSError?
            if asset.statusOfValue(forKey: key, error: &error) == .failed {
                let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                let _ = String.localizedStringWithFormat(stringFormat, key)
                return
            }
        }
        
        // We can't play this asset.
        if !asset.isPlayable {
            let _ = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
            return
        }
        
        playerItem = AVPlayerItem(asset: asset)
        self.playVideoWithPlayerItem()
    }
    //MARK:- Play Video
    func playVideoWithPlayerItem()
    {
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
            
            if newRate == 0
            {
                swipeDownRecommendationView()
            }
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackBufferEmpty)
        {
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackLikelyToKeepUp)
        {
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
                self.scrollCollectionViewToRow(row: currentPlayingIndex)
                break
            case .failed:
                Log.DLog(message: "Failed" as AnyObject)
                print("AES URL Hit From Failed Case ==== \(String(describing: self.playbackRightsData?.aesUrl))")
                if isVideoUrlFailedCount == 0
                {
                    isVideoUrlFailedCount = 1
                    self.resetPlayer()
                    self.handleAESStreamingUrl(videoUrl: (self.playbackRightsData?.aesUrl)!)
                }
                else
                {
                    
                    let alert = UIAlertController(title: "Unable to process your request right now",
                                                  message: "",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                        DispatchQueue.main.async {
                            print("dismiss")
                            self.dismissPlayerVC()
                        }
                    }
                    
                    alert.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
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
                    handleEpisodeNextItem()
                }
                else if metadata?.app?.type == VideoType.Trailer.rawValue
                {
                    handleTrailerNextItem()
                }
                else if metadata?.app?.type == VideoType.Movie.rawValue
                {
                    dismissPlayerVC()
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
                    else if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue || data.app?.type == VideoType.Language.rawValue || data.app?.type == VideoType.Genre.rawValue
                    {
                        handleNextItem()
                    }
                }
                else if let data = self.item as? Episode {
                    Log.DLog(message: data as AnyObject)
                    Log.DLog(message: "$$$ Finish Episode" as AnyObject)
                }
            }
        }
        else
        {
            dismissPlayerVC()
        }
    }
   
    //MARK:- Handle Next Item
    func handleTrailerNextItem()
    {
        self.currentPlayingIndex = self.currentPlayingIndex + 1
        if self.currentPlayingIndex != self.metadata?.more?.count
        {
            let modal = self.metadata?.more?[self.currentPlayingIndex]
            self.currentItemImage = modal?.banner
            self.currentItemTitle = modal?.name
            self.currentItemDuration = String(describing: modal?.totalDuration)
            self.currentItemDescription = modal?.description
            self.callWebServiceForPlaybackRights(id: (modal?.id)!)
        }
        else
        {
            self.currentPlayingIndex = self.currentPlayingIndex - 1
            dismissPlayerVC()
        }
    }
    func handlePlayListNextItem()
    {
        self.currentPlayingIndex = self.currentPlayingIndex + 1
        if self.currentPlayingIndex != self.playlistData?.more?.count
        {
            let modal = self.playlistData?.more?[self.currentPlayingIndex]
            self.currentItemImage = modal?.banner
            self.currentItemTitle = modal?.name
            self.currentItemDuration = String(describing: modal?.totalDuration)
            self.currentItemDescription = modal?.description
            self.callWebServiceForPlaybackRights(id: (modal?.id)!)
        }
        else
        {
            self.currentPlayingIndex = self.currentPlayingIndex - 1
            dismissPlayerVC()
        }
    }
    
    func handleNextItem()
    {
        self.currentPlayingIndex = self.currentPlayingIndex + 1
        if self.currentPlayingIndex != self.arr_RecommendationList.count
        {
            let modal = arr_RecommendationList[self.currentPlayingIndex]
            self.currentItemImage = modal.banner
            self.currentItemTitle = modal.name
            self.currentItemDuration = String(describing: modal.totalDuration)
            self.currentItemDescription = modal.description
            self.callWebServiceForPlaybackRights(id: modal.id!)
        }
        else
        {
            self.currentPlayingIndex = self.currentPlayingIndex - 1
            dismissPlayerVC()
        }
    }
    
    func handleEpisodeNextItem()
    {
        self.currentPlayingIndex = self.currentPlayingIndex - 1
        if self.currentPlayingIndex >= 0 //
        {
            let modal = metadata?.episodes?[currentPlayingIndex]
            self.metadata?.latestEpisodeId = modal?.id
            self.currentItemImage = modal?.banner
            self.currentItemTitle = modal?.name
            self.currentItemDuration = String(describing: modal?.totalDuration)
            //self.currentItemDescription = modal?.description
            self.callWebServiceForPlaybackRights(id: (modal?.id!)!)
        }
        else
        {
            self.currentPlayingIndex = self.currentPlayingIndex + 1
            dismissPlayerVC()
        }
    }
    
    //MARK:- Custom Methods
    //MARK:- Scroll Collection View To Row
    var myPreferredFocusView:UIView? = nil
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        if myPreferredFocusView != nil
        {
            return [myPreferredFocusView!]
        }
        else
        {
            return []
        }
    }
    
    func scrollCollectionViewToRow(row:Int)
    {
        print("Scroll to Row is = \(row)")
        if row >= 0 {
            DispatchQueue.main.async {
                let path = IndexPath(row: row, section: 0)
                self.collectionView_Recommendation.scrollToItem(at: path, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
                let cell = self.collectionView_Recommendation.cellForItem(at: path)
                self.myPreferredFocusView = cell
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
//        DispatchQueue.main.async {
//            let cell = self.collectionView_Recommendation
//            self.myPreferredFocusView = cell
//            self.setNeedsFocusUpdate()
//            self.updateFocusIfNeeded()
//        }
    }
    
    //MARK:- Open MetaDataVC
    func openMetaDataVC(model:More)
    {
        Log.DLog(message: "openMetaDataVC" as AnyObject)
        if let topController = UIApplication.topViewController() {
            Log.DLog(message: "$$$$ Enter openMetaDataVC" as AnyObject)
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
    //MARK:- Hide/Unhide Now Playing
    func hideUnhideNowPlayingView(cell:JCItemCell,state:Bool)
    {
        DispatchQueue.main.async {
            cell.view_NowPlaying.isHidden = state
        }
    }
    //MARK:- Show Next Video View
    
    func showNextVideoView(videoName:String,remainingTime:Int,banner:String)
    {
        DispatchQueue.main.async {
            self.nextVideoView.isHidden = false
            self.nextVideoNameLabel.text = videoName
            self.nextVideoPlayingTimeLabel.text = "Playing in " + "\(Int(remainingTime))" + " Seconds"
            let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(banner)
            let url = URL(string: imageUrl!)
            self.nextVideoThumbnail.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
        
    }
    
    //MARK:- Custom Setting
    func setCustomRecommendationViewSetting(state:Bool)
    {
        
        self.collectionView_Recommendation.isScrollEnabled = state
        self.isRecommendationView = state
        self.collectionView_Recommendation.reloadData()
        if state
        {
            self.scrollCollectionViewToRow(row: currentPlayingIndex)
        }
        if !state {
            DispatchQueue.main.async {
                self.myPreferredFocusView = nil
                self.setNeedsFocusUpdate()
            }
        }
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
                let tempFrame = self.nextVideoView.frame
                self.nextVideoView.frame = CGRect(x: tempFrame.origin.x, y: tempFrame.origin.y - 300, width: tempFrame.size.width, height: tempFrame.size.height)
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
                let tempFrame = self.nextVideoView.frame
                self.nextVideoView.frame = CGRect(x: tempFrame.origin.x, y: tempFrame.origin.y + 300, width: tempFrame.size.width, height: tempFrame.size.height)
                self.view_Recommendation.frame = CGRect(x: 0, y: screenHeight-60, width: screenWidth, height: self.view_Recommendation.frame.height)
            }, completion: { (completed) in
                self.setCustomRecommendationViewSetting(state: false)
            })
        }
    }
    //MARK:- Show Alert
    func showAlert(alertTitle:String,alertMessage:String,completionHandler:(()->Void)?)
    {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
       // self.present(UIViewController, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        self.present(alert, animated: true, completion: completionHandler)
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
                print("data id is == \(data.id)")
                print("data App type is == \(data.app?.type)")

                if data.app?.type == VideoType.Movie.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: data.id!)
                    let url = metadataUrl.appending(data.id!)
                    self.callWebServiceForMoreLikeData(url: url)
                }
                else if data.app?.type == VideoType.TVShow.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: playerId!)
                    let url = metadataUrl.appending(data.id!).appending("/0/0")
                    self.callWebServiceForMoreLikeData(url: url)
                }
                else if data.app?.type == VideoType.Trailer.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: data.id!)
                    let url = metadataUrl.appending(data.id!)
                    self.callWebServiceForMoreLikeData(url: url)
                }
                else if data.app?.type == VideoType.Episode.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: data.id!)
                    let url = metadataUrl.appending(data.id!)
                    self.callWebServiceForMoreLikeData(url: url)
                }
                else if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue
                {
                    print("Item From View Controller is \(selectedItemFromViewController.rawValue)")
                    arr_RecommendationList.removeAll()
                    if selectedItemFromViewController == VideoType.Search
                    {
                        self.callWebServiceForPlaybackRights(id: data.id!)
                        let url = metadataUrl.appending(data.id!)
                        self.callWebServiceForMoreLikeData(url: url)
                    }
                   else if selectedItemFromViewController == VideoType.Music
                    {
                        self.callWebServiceForPlaybackRights(id: data.id!)

                        arr_RecommendationList = (JCDataStore.sharedDataStore.musicData?.data?[collectionIndex].items)!
                    }
                    else if selectedItemFromViewController == VideoType.Clip
                    {
                        self.callWebServiceForPlaybackRights(id: data.id!)

                        arr_RecommendationList = (JCDataStore.sharedDataStore.clipsData?.data?[collectionIndex].items)!
                    }
                    else if selectedItemFromViewController == VideoType.Home
                    {
                        arr_RecommendationList = (JCDataStore.sharedDataStore.mergedHomeData?[collectionIndex].items!)!
                    }
                    else if selectedItemFromViewController == VideoType.Language || selectedItemFromViewController == VideoType.Genre
                    {
                        arr_RecommendationList = (JCDataStore.sharedDataStore.languageGenreDetailModel?.data?.items)!
                    }
                    
                    reloadCollectionViewWithCurrentPlayingIndex()
                }
            }
        }
    }
    
    func reloadCollectionViewWithCurrentPlayingIndex()
    {
        if let data = self.item as? Item
        {
        for i in 0 ..< (arr_RecommendationList.count)
        {
            let modal = arr_RecommendationList[i]
            if modal.id == data.id
            {
                Log.DLog(message: data.id as AnyObject)
                self.currentPlayingIndex = i
                break
            }
        }
        self.collectionView_Recommendation.reloadData()
        self.scrollCollectionViewToRow(row: currentPlayingIndex)
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
                DispatchQueue.main.async {
                    weakSelf?.evaluateMoreLikeData(dictionaryResponseData: responseData)

                    weakSelf?.collectionView_Recommendation.reloadData()
                    weakSelf?.scrollCollectionViewToRow(row: (weakSelf?.currentPlayingIndex)!)
                    
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
            self.metadata = tempMetadata
            print("app is ====== \(self.metadata?.app?.type)")
            
            if let data = self.item as? Item
            {
                if data.app?.type == VideoType.Episode.rawValue
                {
                     for i in 0 ..< (self.metadata?.episodes?.count)!
                    {
                        let modal = self.metadata?.episodes![i]
                        if modal?.id == data.id
                        {
                            self.currentPlayingIndex = i
                            break
                        }
                    }
                }
                else if data.app?.type == VideoType.Trailer.rawValue
                {
                   
                    for i in 0 ..< (self.metadata?.more?.count)!
                    {
                        let modal = self.metadata?.more![i]
                        if modal?.id == data.id
                        {
                            self.currentPlayingIndex = i
                            break
                        }
                    }
                }
                
                print("### self.currentPlayingIndex is == \(self.currentPlayingIndex )")
                DispatchQueue.main.async {
                    self.collectionView_Recommendation.reloadData()
                    self.scrollCollectionViewToRow(row: self.currentPlayingIndex)
                }
            }
            
            
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
                        self.currentPlayingIndex = 0
                        if let data = self.item as? Item
                        {
                            for i in 0 ..< (self.playlistData?.more?.count)!
                            {
                                let modal = self.playlistData?.more?[i]
                                if modal?.id == data.id
                                {
                                    Log.DLog(message: data.id as AnyObject)
                                    self.currentPlayingIndex = i
                                    break
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionView_Recommendation.reloadData()
                            self.scrollCollectionViewToRow(row: self.currentPlayingIndex)
                        }

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
        print("Playback rights id is === \(id)")
        playerId = id
        let url = playbackRightsURL.appending(id)
        let params = ["id":id,"showId":"","uniqueId":JCAppUser.shared.unique,"deviceType":"stb"]
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
                    self.playbackRightsData = PlaybackRightsModel(JSONString: responseString)
                    DispatchQueue.main.async {
                        
                        if((self.player) != nil) {
                            self.player?.pause()
                            self.resetPlayer()
                        }
                        
                        if self.metadata != nil  // For Handling FPS URL
                        {
                            if self.metadata?.app?.type == VideoType.TVShow.rawValue || self.metadata?.app?.type == VideoType.Movie.rawValue
                            {
                                print("FPS URL Hit ==== \(String(describing: self.playbackRightsData?.url))")
                                self.instantiatePlayer(with: (self.playbackRightsData!.url!))
                            }
                            else
                            {
                                print("123 AES URL Hit ==== \(String(describing: self.playbackRightsData?.aesUrl))")
                                self.instantiatePlayer(with: (self.playbackRightsData!.aesUrl!))
                            }
                        }
                        else
                        {
                            print("AES URL Hit ==== \(String(describing: self.playbackRightsData?.aesUrl))")
                            self.instantiatePlayer(with: (self.playbackRightsData!.aesUrl!))
                        }
                    }
                }
                return
            }
        }
    }
    
    
    func callWebServiceForRemovingResumedWatchlist()
    {
        let json = ["id":playerId]
        let params = ["uniqueId":JCAppUser.shared.unique,"listId":"10","json":json] as [String : Any]
        let url = removeFromResumeWatchlistUrl
        let removeRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: removeRequest) { (data, response, error) in
            
            if let responseError = error
            {
                print(responseError)
                return
            }
            
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                let code = parsedResponse["code"]
                print("Removed from Resume Watchlist \(String(describing: code))")
                DispatchQueue.main.async {
                    weakSelf?.dismiss(animated: false, completion: nil)
                }
            }
        }
        
    }
    
    func callWebServiceForAddToResumeWatchlist(currentTimeDuration:String,totalDuration:String)
    {
        let url = addToResumeWatchlistUrl
        //let json: Dictionary<String, Any> = ["id":playerId!, "duration":currentTimeDuration, "totalduration": totalDuration]
        let id = latestEpisodeId == "-1" ? playerId! : latestEpisodeId
        let json: Dictionary<String, Any> = ["id":id, "duration":currentTimeDuration, "totalduration": totalDuration]
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
        
//        if !Utility.sharedInstance.isNetworkAvailable
//        {
//            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
//            return
//        }
        
        self.swipeDownRecommendationView()

        if self.currentPlayingIndex == indexPath.row {
            print("Video is already playing")
            return
        }
        self.currentPlayingIndex = indexPath.row
        
        // var url = ""
        if metadata != nil
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue
            {
                let model = metadata?.episodes?[indexPath.row]
                self.metadata?.latestEpisodeId = model?.id
                self.currentItemImage = model?.banner
                self.currentItemTitle = model?.name
                self.callWebServiceForPlaybackRights(id: (model?.id)!)
            }
            else if metadata?.app?.type == VideoType.Trailer.rawValue
            {
                let model = metadata?.more?[indexPath.row]
                self.currentItemImage = model?.banner
                self.currentItemTitle = model?.name
                self.currentItemDescription = model?.description
                print("playable id is.....\(model?.id)")
                self.callWebServiceForPlaybackRights(id: (model?.id)!)

            }
            else if metadata?.app?.type == VideoType.Movie.rawValue
            {
                let model = metadata?.more?[indexPath.row]
                self.currentItemImage = model?.banner
                self.currentItemTitle = model?.name
                self.currentItemDescription = model?.description
                
                moreModal = model
                if isResumed == true{
                    dismissPlayerVC()
                }
                else
                {
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                            self.openMetaDataVC(model: model!)
                        }
                    })
                }
                
                // self.callWebServiceForPlaybackRights(id: (model?.id)!)
                // url = metadataUrl.appending((model?.id!)!)
                return
            }
        }
        else
        {
            if let data = self.item as? Item
            {
                if data.isPlaylist! // If Playlist exist
                {
                    let model = self.playlistData?.more?[indexPath.row]
                    self.currentItemImage = model?.banner
                    self.currentItemTitle = model?.name
                    self.callWebServiceForPlaybackRights(id: (model?.id)!)
                }
                else
                    if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue || data.app?.type == VideoType.Language.rawValue || data.app?.type == VideoType.Genre.rawValue
                    {
                        let model = arr_RecommendationList[indexPath.row]
                        self.item = model
                        self.currentItemImage = model.banner
                        self.currentItemTitle = model.name
                        
                        if model.isPlaylist!
                        {
                            self.callWebServiceForPlayListData(id: model.playlistId!)
                        }
                        else
                        {
                            self.callWebServiceForPlaybackRights(id: (model.id)!)
                        }
                }
            }
        }
    }
 }
 //MARK:- UICOLLECTIONVIEW DATASOURCE
 
 extension JCPlayerVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if metadata != nil
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue, metadata?.episodes != nil
            {
                return (metadata?.episodes?.count)!
            }
            else if (metadata?.app?.type == VideoType.Movie.rawValue || metadata?.app?.type == VideoType.Trailer.rawValue), metadata?.more != nil
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
            metaDataID = playerId!
            modelID = (model?.id)!
            imageUrl = (model?.banner)!
            cell.nameLabel.text = model?.name
        }
        else if metadata?.app?.type == VideoType.Movie.rawValue || metadata?.app?.type == VideoType.Trailer.rawValue
        {
            let model = metadata?.more?[indexPath.row]
            metaDataID = playerId!
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
                    if model?.banner != nil
                    {
                        imageUrl = (model?.banner)!
                    }
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
                currentPlayingIndex = indexPath.row
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
                        currentPlayingIndex = indexPath.row
                        self.hideUnhideNowPlayingView(cell: cell, state: false)
                    }
                    else
                    {
                        self.hideUnhideNowPlayingView(cell: cell, state: true)
                    }
                }
                else
                {
                    if data.id == modelID
                    {
                        currentPlayingIndex = indexPath.row
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
                    currentPlayingIndex = indexPath.row
                    self.hideUnhideNowPlayingView(cell: cell, state: false)
                }
                else
                {
                    self.hideUnhideNowPlayingView(cell: cell, state: true)
                }
            }
        }
        
        let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
        cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
            (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
        });
        
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
 
 //MARK -- AVAssetResourceLoaderDelegate Methods
 
 extension JCPlayerVC: AVAssetResourceLoaderDelegate
 {
    //MARK -- Token Encryption Methods
    
    func MD5Hash(string:String) -> String {
        let stringData = string.data(using: .utf8)
        let MD5Data = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = MD5Data.withUnsafeBytes({ MD5Bytes in
            stringData?.withUnsafeBytes({ stringBytes in
                CC_MD5(stringBytes, CC_LONG((stringData?.count)!), UnsafeMutablePointer<UInt8>(mutating: MD5Bytes))
            })
        })
        print("MD5Hex: \(MD5Data.map {String(format: "%02hhx", $0)}.joined())")
        return MD5Data.base64EncodedString()
    }
    
    
    func getJCTKeyValue(with expiryTime:String) -> String
    {
        let jctToken = self.MD5Hash(string: JCDataStore.sharedDataStore.secretCdnTokenKey! + self.getSTKeyValue() + expiryTime)
        return filterMD5HashedStringFromSpecialCharacters(md5String:jctToken)
    }
    
    func getSTKeyValue() -> String
    {
        let stKeyValue = JCDataStore.sharedDataStore.secretCdnTokenKey! + JCAppUser.shared.ssoToken
        let md5StValue = self.MD5Hash(string: stKeyValue)
        let stKey = self.filterMD5HashedStringFromSpecialCharacters(md5String: md5StValue)
        return stKey
    }
    
    func filterMD5HashedStringFromSpecialCharacters(md5String:String) -> String
    {
        var filteredMD5 = md5String
        filteredMD5 = filteredMD5.replacingOccurrences(of: "=", with: "")
        filteredMD5 = filteredMD5.replacingOccurrences(of: "+", with: "-")
        filteredMD5 = filteredMD5.replacingOccurrences(of: "/", with: "_")
        return filteredMD5
    }
    
    func getExpireTime() -> String {
        let deviceTime = Date()
        let currentTimeInSeconds: Int = Int(ceil(deviceTime.timeIntervalSince1970)) + JCDataStore.sharedDataStore.cdnUrlExpiryDuration!
        return "\(currentTimeInSeconds)"
    }
    func generateRedirectURL(sourceURL: String)-> URLRequest? {
        
        let redirect = URLRequest(url: URL(string: sourceURL)!)
        return redirect
    }
    
    func getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest requestBytes: Data, contentIdentifierHost assetStr: String, leaseExpiryDuration expiryDuration: TimeInterval, error errorOut: Error?,completionHandler: @escaping(Data?)->Void)
    {
        let dict: [AnyHashable: Any] = [
            "spc" : requestBytes.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
            "id" : "whaterver",
            "leaseExpiryDuration" : Double(expiryDuration)
        ]
        
        var jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        
        let url = URL(string: URL_GET_KEY)
        let req = NSMutableURLRequest(url: url!)
        req.httpMethod = "POST"
        req.setValue("\(UInt((jsonData?.count)!))", forHTTPHeaderField: "Content-Length")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(JCAppUser.shared.ssoToken, forHTTPHeaderField: "ssotoken")
        req.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            //print("error: \(error!)")
            print("data: \(data!)")
            if (data != nil)
            {
                let decodedData = Data(base64Encoded: data!, options: [])
                completionHandler(decodedData!)
            }
            else
            {
                completionHandler(data)
            }
        })
        task.resume()
    }
    
    func getAppCertificateData(completionHandler:@escaping (Data?)->Void) {
        let url = URL(string: URL_GET_CERT)
        let req = NSMutableURLRequest(url: url!)
        req.setValue(JCAppUser.shared.ssoToken, forHTTPHeaderField: "ssotoken")
        let session = URLSession.shared
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            //print("error: \(error!)")
            print("ASYNC Certificate data: \(data!)")
            if (data != nil)
            {
                let decodedData = Data(base64Encoded: data!, options: [])
                completionHandler(decodedData!)
            }
            else
            {
                completionHandler(data)
            }
        })
        task.resume()
    }
    
    
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool
    {
        if metadata != nil  // For Handling FPS URL
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue || metadata?.app?.type == VideoType.Movie.rawValue
            {
                let dataRequest: AVAssetResourceLoadingDataRequest? = loadingRequest.dataRequest
                let url: URL? = loadingRequest.request.url
                let error: Error? = nil
                var handled: Bool = false
                
                // Must be a non-standard URI scheme for AVFoundation to invoke your AVAssetResourceLoader delegate
                // for help in loading it.
                
                if !(url?.scheme?.isEqual(URL_SCHEME_NAME))! {
                    return false
                }
                
                let assetStr: String = url!.host!
                var assetId: Data?
                var requestBytes: Data?
                
                assetId = NSData(bytes: assetStr.cString(using: String.Encoding.utf8), length: assetStr.lengthOfBytes(using: String.Encoding.utf8)) as Data
                if (assetId == nil) {
                    return handled
                }
                
                self.getAppCertificateData { (certificate) in
                    
                    
                    do {
                        requestBytes = try loadingRequest.streamingContentKeyRequestData(forApp: certificate!, contentIdentifier: assetId!, options: nil)
                        
                        print("Request Bytes is \(String(describing: requestBytes))")
                        //var responseData: Data? = nil
                        let expiryDuration = 0.0 as? TimeInterval
                        
                        
                        self.getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest: requestBytes!, contentIdentifierHost: assetStr, leaseExpiryDuration: expiryDuration!, error: error, completionHandler: { (responseData) in
                            print("Key  is \(String(describing: responseData))")
                            
                            
                            if (responseData != nil){
                                dataRequest?.respond(with: responseData!)
                                if expiryDuration != 0.0
                                {
                                    var infoRequest: AVAssetResourceLoadingContentInformationRequest? = loadingRequest.contentInformationRequest
                                    if (infoRequest != nil)
                                    {
                                        infoRequest?.renewalDate = Date(timeIntervalSinceNow: expiryDuration!)
                                        infoRequest?.contentType = "application/octet-stream"
                                        infoRequest?.contentLength = Int64(responseData!.count)
                                        infoRequest?.isByteRangeAccessSupported = false
                                    }
                                    
                                }
                                loadingRequest.finishLoading()
                            }
                            else{
                                if error != nil {
                                    try? loadingRequest.finishLoading()
                                }
                                else {
                                    loadingRequest.finishLoading()
                                }
                            }
                            
                            handled = true;	// Request has been handled regardless of whether server returned an error.
                            // completionHandler(responseData)
                            //  return handled
                        })
                        
                    }
                    catch {
                    }
                }
                return true
                
            }
        }
        
        var url = loadingRequest.request.url?.absoluteString
        print(url!)
        let contentRequest = loadingRequest.contentInformationRequest
        let dataRequest = loadingRequest.dataRequest
        //Check if the it is a content request or data request, we have to check for data request and do the m3u8 file manipulation
        
        if (contentRequest != nil) {
            
            contentRequest?.isByteRangeAccessSupported = true
        }
        if (dataRequest != nil) {
            //this is data request so processing the url. change the scheme to http
            if (url?.contains("fakeHttp"))!, (url?.contains("token"))! {
                url = url?.replacingOccurrences(of: "fakeHttp", with: "http")
                do{
                    let data = try Data(contentsOf: URL(string: url!)!)
                    dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                    
                }catch{
                }
                return true
            }
            if (url?.contains(".m3u8"))!
            {
                let expiryTime:String = self.getExpireTime()
                url = url?.replacingOccurrences(of: "fakeHttp", with: "http")
                let punctuation = (url?.contains(".m3u8?"))! ? "&" : "?"
                let stkeyValue = self.getSTKeyValue()
                let urlString = url! + "\(punctuation)jct=\(self.getJCTKeyValue(with: expiryTime))&pxe=\(expiryTime)&st=\(stkeyValue)"
                print("printing value of url \(urlString)")
                do{
                    let data = try Data(contentsOf: URL(string: urlString)!)
                    dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                    
                }catch{
                }
                return true
            }
            if(url?.contains(".ts"))!{
                url = url?.replacingOccurrences(of: "fakeHttp", with: "http")
                let redirect = self.generateRedirectURL(sourceURL: url!)
                if (redirect != nil) {
                    //Step 9 and 10:-
                    loadingRequest.redirect = redirect!
                    let response = HTTPURLResponse(url: URL(string: url!)!, statusCode: 302, httpVersion: nil, headerFields: nil)
                    loadingRequest.response = response
                    loadingRequest.finishLoading()
                }
                return true
            }
            return true
        }
        return true
    }
    
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool
    {
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        
        if metadata != nil  // For Handling FPS URL
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue || metadata?.app?.type == VideoType.Movie.rawValue
            {
                return self.resourceLoader(resourceLoader, shouldWaitForLoadingOfRequestedResource: renewalRequest)
            }
        }
        return true
    }
    
 }
