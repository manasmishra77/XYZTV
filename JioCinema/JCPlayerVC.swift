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
    var globalQueue: DispatchQueue? = nil
    var getQueueOnce: Int = 0
    if (getQueueOnce == 0) {
        globalQueue = DispatchQueue(label: "tester notify queue")
    }
    getQueueOnce = 1
    return globalQueue!
 }
 
 
 class JCPlayerVC: UIViewController, AVPlayerViewControllerDelegate
 {
    
    @IBOutlet weak var textOnLoaderCoverView: UILabel!
    @IBOutlet weak var activityIndicatorOfLoaderView: UIActivityIndicatorView!
    @IBOutlet weak var loaderCoverView: UIView!
    
    @IBOutlet weak var nextVideoView                    :UIView!
    @IBOutlet weak var view_Recommendation              :UIView!
    @IBOutlet weak var nextVideoNameLabel               :UILabel!
    @IBOutlet weak var nextVideoPlayingTimeLabel        :UILabel!
    @IBOutlet weak var nextVideoThumbnail               :UIImageView!
    @IBOutlet weak var collectionView_Recommendation    :UICollectionView!
    
    var isVideoUrlFailedCount = 0
    
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
    var startTime_BufferDuration    :Date?
    var totalBufferDurationTime      = 0.0
    
    var videoViewingLapsedTime = 0.0

    var currentPlayingIndex         = -1
    
    var duration                    = 0.0
    var bufferCount                 = 0.0
    
    var arr_RecommendationList = [Item]()
    
    var moreModal:More?
    var didSeek :Bool?
    
    fileprivate var playBackRightsTappedAt = Date()
    fileprivate var videoStartingDuration = 0
    
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    var bitrate:String{
        get{
            var bitrateString:String = ""
            //var unit = "kBps"
            if let observedBitrate = playerItem?.accessLog()?.events.last?.observedBitrate as? Double
            {
                
                let bitrate : Int =  Int(observedBitrate / (8*1024))
//            if bitrate > 1000 {
//                //Make it Mbps
//                bitrate = bitrate / 1024
//                    unit = "MBps"
//                }
            bitrateString = bitrate > 0 ? String(bitrate) : "0"
            }
         return bitrateString
            }
        }
    
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
               // print("metadata id = \(metadata?.id)")
               // print("player id = \(playerId)")
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
            dismissPlayerVC()
//            self.dismiss(animated: true, completion: {
////                DispatchQueue.main.async {
////                    if self.moreModal != nil
////                    {
////                        self.isResumed = false
////                        self.openMetaDataVC(model: self.moreModal!)
////                    }
////                }
//            })
            // self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
        
        if (player != nil)
        {
            sendMediaEndAnalyticsEvent()
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
                                        let imageUrl = ((modal?.banner) != nil) ? (modal?.banner)! : ""
                                        self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: imageUrl)
                                    }
                                    else
                                    {
                                        self?.nextVideoView.isHidden = true
                                    }
                                }
                                else if (self?.metadata?.app?.type == VideoType.Trailer.rawValue || self?.metadata?.app?.type == VideoType.Music.rawValue || self?.metadata?.app?.type == VideoType.Clip.rawValue), self?.metadata?.more != nil
                                {
                                    let index = (self?.currentPlayingIndex)! + 1
                                    
                                    if index >= 0, index < (self?.metadata?.more?.count)!
                                    {
                                        let modal = self?.metadata?.more?[index]
                                        //self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                        let imageUrl = ((modal?.banner) != nil) ? (modal?.banner)! : ""
                                        self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: imageUrl)
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
                                
                                if data.isPlaylist != nil, data.isPlaylist!  // If Playlist exist
                                {
                                    if self?.playlistData != nil
                                    {
                                        if index != self?.playlistData?.more?.count
                                        {
                                            let modal = self?.playlistData?.more?[index]
                                            //self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
                                            let imageUrl = ((modal?.banner) != nil) ? (modal?.banner)! : ""
                                            self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: imageUrl)
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
                                        let imageUrl = ((modal?.banner) != nil) ? (modal?.banner)! : ""
                                        self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: imageUrl)
                                        //self?.showNextVideoView(videoName: (modal?.name)!, remainingTime: Int(remainingTime), banner: (modal?.banner)!)
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
        //sendMediaEndAnalyticsEvent()
        categoryTitle = referenceFromPlayerVC
        referenceFromPlayerVC = ""
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
            self.playerController?.delegate = nil
        }
    }
    
    func instantiatePlayer(with url:String)
    {
        self.resetPlayer()
        didSeek = true
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
            if let data = self.item as? Item
            {
               // if !data.isPlaylist! {
                    
                    if data.app?.type == VideoType.Movie.rawValue || data.app?.type == VideoType.TVShow.rawValue || data.app?.type == VideoType.Episode.rawValue
                    {
                        handleFairPlayStreamingUrl(videoUrl: url)
                    }
                    else
                    {
                        handleAESStreamingUrl(videoUrl: url)
                    }
               // }
        }
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
            playerController?.delegate = self
            self.addChildViewController(playerController!)
            self.view.addSubview((playerController?.view)!)
            playerController?.view.frame = self.view.frame
        }
        addPlayerNotificationObserver()
        playerController?.player = player
        player?.play()
        if isResumed != nil, isResumed!{
           player?.seek(to: CMTimeMakeWithSeconds(duration, 1))
        }
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
        
        playerItem?.externalMetadata.append(titleMetadataItem)
        playerItem?.externalMetadata.append(descriptionMetadataItem)
        playerItem?.externalMetadata.append(imageMetadataItem)
        
    }
    func getPlayerDuration() -> Double {
        guard let currentItem = self.player?.currentItem else { return 0.0 }
        //print(currentItem.duration)
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
            startTime_BufferDuration = Date()
            bufferCount = bufferCount + 0.5
            
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackLikelyToKeepUp)
        {
            let difference =  Date().timeIntervalSince(startTime_BufferDuration!)
            totalBufferDurationTime = difference + totalBufferDurationTime
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
                self.videoStartingDuration = Int(Date().timeIntervalSince(playBackRightsTappedAt))
                self.seekPlayer()
                self.addPlayerPeriodicTimeObserver()
                self.collectionView_Recommendation.reloadData()
                self.scrollCollectionViewToRow(row: currentPlayingIndex)
                self.sendMediaStartAnalyticsEvent()
                
                break
            case .failed:
                
                Log.DLog(message: "Failed" as AnyObject)
                var failureType = "FPS"
                var type = ""
                var title = ""
                var episodeDetail = ""
                if metadata == nil
                {
                    if let data = self.item as? Item
                    {
                        if (data.app?.type == VideoType.Movie.rawValue || data.app?.type == VideoType.Episode.rawValue), isVideoUrlFailedCount == 0
                        {
                            failureType = "FPS"
                            type = (data.app?.type == VideoType.Movie.rawValue) ? VideoType.Movie.name : VideoType.TVShow.name
                            title = data.name!
                            if data.description != nil{
                                episodeDetail = (data.app?.type == VideoType.Episode.rawValue) ? data.description! : ""
                            }
                            
                        }
                    }
                }
                else
                {
                    if (metadata?.app?.type == VideoType.Movie.rawValue || metadata?.app?.type == VideoType.Episode.rawValue), isVideoUrlFailedCount == 0
                    {
                        failureType = "AES"
                        type = (metadata?.app?.type == VideoType.Movie.rawValue) ? VideoType.Movie.name : VideoType.TVShow.name
                        title = (metadata?.name)!
                        episodeDetail = (metadata?.app?.type == VideoType.Episode.rawValue) ? (metadata?.description)! : ""
                    }
                }
                
                let eventProperties = ["Error Code":"-1","Error Message":String(describing: playerItem?.error?.localizedDescription),"Type":type,"Title":title,"Content ID":playerId!,"Bitrate":bitrate,"Episode":episodeDetail,"Platform":"TVOS","Failure":failureType] as [String : Any]
                
                sendPlaybackFailureEvent(eventProperties: eventProperties)
                
                if isVideoUrlFailedCount == 0
                {
                    isVideoUrlFailedCount = 1
                    self.resetPlayer()
                    self.handleAESStreamingUrl(videoUrl: (self.playbackRightsData?.aesUrl)!)
                  //  print("AES URL Hit From Failed Case ==== \(String(describing: self.playbackRightsData?.aesUrl))")
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
                else if metadata?.app?.type == VideoType.Trailer.rawValue || metadata?.app?.type == VideoType.Music.rawValue || metadata?.app?.type == VideoType.Clip.rawValue
                {
                    handleTrailerOrMusicNextItem()
                }
                else if metadata?.app?.type == VideoType.Movie.rawValue || metadata?.app?.type == VideoType.Music.rawValue
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
    func handleTrailerOrMusicNextItem()
    {
        
        self.currentPlayingIndex = self.currentPlayingIndex + 1
        if self.currentPlayingIndex != self.metadata?.more?.count
        {
            sendMediaEndAnalyticsEvent()
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
            sendMediaEndAnalyticsEvent()
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
            sendMediaEndAnalyticsEvent()
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
            sendMediaEndAnalyticsEvent()
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
    //MARK:- Analytics Events
    func sendMediaStartAnalyticsEvent()
    {
        if categoryTitle == ""{
            setCategoryTitle()
        }
        let mbid = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss") + UIDevice.current.identifierForVendor!.uuidString
        
        let mediaStartInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaStartEventForInternalAnalytics(contentId: playerId!, mbid: mbid, mediaStartTime: String(duration), categoryTitle: categoryTitle, rowPosition: String(collectionIndex))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaStartInternalEvent)
    }
    
    func sendBufferingEvent(eventProperties:[String:Any])
    {
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Buffering", properties: eventProperties)
    }
    
    func sendPlaybackFailureEvent(eventProperties:[String:Any])
    {
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Media Error", properties: eventProperties)
        self.sendMediaErrorAnalyticsEvent()

    }
    
    func sendMediaEndAnalyticsEvent()
    {
        
        if let currentTime = player?.currentItem?.currentTime()
        {
            var isPlayList = "false"
            if let data = self.item as? Item{
                if let playList = data.isPlaylist, playList{
                    isPlayList = "true"
                }
            }
            
            let currentTimeDuration = "\(Int(CMTimeGetSeconds(currentTime)))"
            let timeSpent = CMTimeGetSeconds(currentTime) - duration - totalBufferDurationTime - videoViewingLapsedTime
            
            let mediaEndInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaEndEventForInternalAnalytics(contentId: playerId!, playerCurrentPositionWhenMediaEnds: currentTimeDuration, ts: "\(Int(timeSpent))", videoStartPlayingTime: "\(videoStartingDuration)", bufferDuration: String(describing: Int(totalBufferDurationTime)) , bufferCount: String(Int(bufferCount)), screenName: selectedItemFromViewController.name, bitrate: bitrate, playList: isPlayList, rowPosition: String(collectionIndex), categoryTitle: categoryTitle)
            
            JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaEndInternalEvent)
            
            bufferCount = 0
        }
        self.sendVideoViewedEventToCleverTap()
    }
    
    func sendMediaErrorAnalyticsEvent()
    {
        let mediaErrorInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: "", errorCode: "", videoType: String(selectedItemFromViewController.rawValue), contentTitle: categoryTitle, contentId: playerId!, videoQuality: "Auto", bitrate: bitrate, episodeSubtitle: "", playerErrorMessage: "", apiFailureCode: "", message: "", fpsFailure: "")
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaErrorInternalEvent)
    }
    
    func sendVideoViewedEventToCleverTap()
    {
        var title = ""
        var episodeNum = 0
        var language = ""
        var type:VideoType = .None
        var isPlaylist = "false"
        if metadata == nil
        {
            if let data = self.item as? Item
            {
                title = data.name ?? ""
                language = data.language ?? ""
                type = VideoType(rawValue: (data.app?.type)!)!
                isPlaylist = String(describing: data.isPlaylist!)
                if data.app?.type == VideoType.Episode.rawValue
                {
                    //episode = data.name ?? ""
                    if let episode = self.item as? Episode{
                        episodeNum = episode.episodeNo ?? 0
                    }
                }
            }
        }
        else
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue
            {
                if let episode = self.item as? Episode{
                    episodeNum = episode.episodeNo ?? 0
                }
            }
            
            title = (metadata?.name) ?? ""
            language = (metadata?.language) ?? ""
            type = VideoType(rawValue: (metadata?.app?.type)!)!
        }
        
        if let currentTime = player?.currentItem?.currentTime()
        {
            let currentTimeDuration = "\(Int(CMTimeGetSeconds(currentTime)))"
//            if categoryTitle == ""{
//                setCategoryTitle()
//            }
            
            //sendMediaEndAnalyticsEvent()
            let eventProperties:[String:Any] = ["Content ID":playerId!,"Type": type.rawValue,"Threshold Duration": currentTimeDuration,"Title":title,"Episode": episodeNum,"Language":language,"Source": categoryTitle,"screenName":selectedItemFromViewController.name,"Bitrate":bitrate,"Playlist":isPlaylist,"Row Position":String(collectionIndex),"Error Message":"","Genre":"","Platform":"TVOS"]
            categoryTitle = ""
            JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Video Viewed", properties:eventProperties )
            
            let bufferEventProperties = ["Buffer Count":String(describing: Int(bufferCount)),"Buffer Duration": String(describing:Int(totalBufferDurationTime)),"Content ID":playerId!,"Type":type.rawValue,"Title":title,"Episode":episodeNum,"Bitrate": bitrate,"Platform": "TVOS"] as [String : Any]
            sendBufferingEvent(eventProperties: bufferEventProperties)
            //
            videoViewingLapsedTime = 0
            totalBufferDurationTime = 0
            duration = 0
            bufferCount = 0
        }
        
    }
    func setCategoryTitle()  {
        let vc = JCAppReference.shared.tabBarCotroller?.selectedViewController
        if let vc = vc as? JCHomeVC{
            categoryTitle = vc.dataItemsForTableview[collectionIndex].title ?? ""
        }
        else if let vc = vc as? JCMoviesVC{
            categoryTitle = vc.dataItemsForTableview[collectionIndex].title ?? ""
        }
        else if let vc = vc as? JCTVVC{
            categoryTitle = vc.dataItemsForTableview[collectionIndex].title ?? ""
        }
        else if let vc = vc as? JCClipsVC{
            categoryTitle = (JCDataStore.sharedDataStore.clipsData?.data?[collectionIndex].title ?? "")
        }
        else if let vc = vc as? JCMusicVC{
            categoryTitle = (JCDataStore.sharedDataStore.musicData?.data?[collectionIndex].title ?? "")
        }
       
    }
    
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
      //  print("Scroll to Row is = \(row)")
        if row >= 0 {
            DispatchQueue.main.async {
                let path = IndexPath(row: row, section: 0)
                self.collectionView_Recommendation.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
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
            
            let metadataVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
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
            let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(banner) ?? ""
            let url = URL(string: imageUrl)
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
        self.present(alert, animated: true, completion: completionHandler)
    }
    
    
    //MARK:- Webservice Methods
    func fetchRecommendationData()
    {
        if let data = self.item as? Item
        {
            
            if data.isPlaylist != nil, data.isPlaylist!
            {
                self.callWebServiceForPlayListData(id: data.playlistId!)
            }
            else
            {
                //print("data id is == \(data.id)")
               // print("data App type is == \(data.app?.type)")
                
                if data.app?.type == VideoType.Movie.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: data.id!)
                   // let url = metadataUrl.appending(data.id!)
                }
                else if data.app?.type == VideoType.TVShow.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: playerId!)
                   // let url = metadataUrl.appending(data.id!).appending("/0/0")
                }
                else if data.app?.type == VideoType.Trailer.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: data.id!)
                  //  let url = metadataUrl.appending(data.id!)
                }
                else if data.app?.type == VideoType.Episode.rawValue
                {
                    self.callWebServiceForPlaybackRights(id: data.id!)
                   // let url = metadataUrl.appending(data.id!)
                }
                else if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue
                {
                    //print("Item From View Controller is \(selectedItemFromViewController.rawValue)")
                    arr_RecommendationList.removeAll()
                    self.callWebServiceForPlaybackRights(id: data.id!)
                    
                    if selectedItemFromViewController == VideoType.Clip
                    {
                        arr_RecommendationList = (JCDataStore.sharedDataStore.clipsData?.data?[collectionIndex].items) ?? [Item]()
                    }
                    else if selectedItemFromViewController == VideoType.Home
                    {
                        arr_RecommendationList = (JCDataStore.sharedDataStore.homeData?.data?[collectionIndex].items) ?? [Item]()
                    }

                    else if selectedItemFromViewController == VideoType.Language || selectedItemFromViewController == VideoType.Genre
                    {
                        arr_RecommendationList = (JCDataStore.sharedDataStore.languageGenreDetailModel?.data?.items) ?? [Item]()
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
                    weakSelf?.scrollCollectionViewToRow(row: (weakSelf?.currentPlayingIndex) ?? 0)
                    
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
            
            
            
//            if self.metadata?.app?.type == VideoType.TVShow.rawValue || self.metadata?.app?.type == VideoType.Movie.rawValue
//            {
//                print("FPS URL Hit ==== \(String(describing: self.playbackRightsData?.url))")
//                self.instantiatePlayer(with: (self.playbackRightsData?.url)!)
//
//                //For simulator
//                //print("AES URL Hit ==== \(String(describing: self.playbackRightsData?.aesUrl))")
//                //self.instantiatePlayer(with: (self.playbackRightsData?.aesUrl)!)
//            }
//            else
//            {
//                print("123 AES URL Hit ==== \(String(describing: self.playbackRightsData?.aesUrl))")
//                self.instantiatePlayer(with: (self.playbackRightsData!.aesUrl!))
//            }
            
            
            
            if let data = self.item as? Item
            {
                if data.app?.type == VideoType.Episode.rawValue
                {
                    if ((self.metadata?.episodes) != nil){
                        for i in 0 ..< (self.metadata?.episodes?.count)!
                        {
                            let modal = self.metadata?.episodes?[i]
                            if modal?.id == data.id
                            {
                                self.currentPlayingIndex = i
                                break
                            }
                        }
                    }
                }
                else if data.app?.type == VideoType.Trailer.rawValue
                {
                    
                    for i in 0 ..< ((self.metadata?.more?.count) ?? 1)
                    {
                        let modal = self.metadata?.more?[i]
                        if modal?.id == data.id
                        {
                            self.currentPlayingIndex = i
                            break
                        }
                    }
                }
                
                
               // print("### self.currentPlayingIndex is == \(self.currentPlayingIndex )")
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
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                //Sending media error event
                let failureType = "Play list data error"
                var type = ""
                var title = ""
                var episodeDetail = ""
                if weakSelf?.metadata == nil
                {
                    if let data = self.item as? Item
                    {
                        if (data.app?.type == VideoType.Movie.rawValue || data.app?.type == VideoType.Episode.rawValue)
                        {
                            //failureType = "FPS"
                            type = (data.app?.type == VideoType.Movie.rawValue) ? VideoType.Movie.name : VideoType.TVShow.name
                            title = data.name!
                            if data.description != nil{
                                episodeDetail = (data.app?.type == VideoType.Episode.rawValue) ? data.description! : ""
                            }
                        }
                    }
                }
                else
                {
                    if (weakSelf?.metadata?.app?.type == VideoType.Movie.rawValue || weakSelf?.metadata?.app?.type == VideoType.Episode.rawValue)
                    {
                        //failureType = "AES"
                        type = (weakSelf?.metadata?.app?.type == VideoType.Movie.rawValue) ? VideoType.Movie.name : VideoType.TVShow.name
                        title = (weakSelf?.metadata?.name)!
                        episodeDetail = (weakSelf?.metadata?.app?.type == VideoType.Episode.rawValue) ? (weakSelf?.metadata?.description)! : ""
                    }
                }
                let eventProperties = ["Error Code":"-1","Error Message":String(describing: responseError.localizedDescription),"Type":type, "Title":title, "Content ID": weakSelf?.playerId ?? "", "Bitrate":"0","Episode":episodeDetail,"Platform":"TVOS","Failure":failureType] as [String : Any]
                weakSelf?.sendPlaybackFailureEvent(eventProperties: eventProperties)
                return
            }
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    self.playlistData = PlaylistDataModel(JSONString: responseString)
                    if (self.playlistData?.more?.count) != nil, (self.playlistData?.more?.count)! > 0
                    {
                        self.currentPlayingIndex = 0
                        if let data = self.item as? Item
                        {
                            for i in 0 ..< ((self.playlistData?.more?.count) ?? 1)
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
        playBackRightsTappedAt = Date()
        DispatchQueue.main.async {
            //self.activityIndicatorOfLoaderView.startAnimating()
        }
        print("Playback rights id is === \(id)")
        playerId = id
        let url = playbackRightsURL.appending(id)
        let params = ["id":id,"showId":"","uniqueId":JCAppUser.shared.unique,"deviceType":"stb"]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.activityIndicatorOfLoaderView.stopAnimating()
                
            }
            if let responseError = error
            {
                //TODO: handle error
               // print(responseError)
                DispatchQueue.main.async {
                    self.activityIndicatorOfLoaderView.stopAnimating()
                    self.activityIndicatorOfLoaderView.isHidden = true
                    self.textOnLoaderCoverView.text = "Some problem occured!!"//, please login again!!"
                    Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(JCPlayerVC.dismissPlayerVC), userInfo: nil, repeats: true)
                }
                
                //Sending media error event
                let failureType = "Play back rights error"
                var type = ""
                var title = ""
                var episodeDetail = ""
                if weakSelf?.metadata == nil
                {
                    if let data = self.item as? Item
                    {
                        if (data.app?.type == VideoType.Movie.rawValue || data.app?.type == VideoType.Episode.rawValue)
                        {
                            //failureType = "FPS"
                            type = (data.app?.type == VideoType.Movie.rawValue) ? VideoType.Movie.name : VideoType.TVShow.name
                            title = data.name!
                            if data.description != nil{
                                episodeDetail = (data.app?.type == VideoType.Episode.rawValue) ? data.description! : ""
                            }
                        }
                    }
                }
                else
                {
                    if (weakSelf?.metadata?.app?.type == VideoType.Movie.rawValue || weakSelf?.metadata?.app?.type == VideoType.Episode.rawValue)
                    {
                        //failureType = "AES"
                        type = (weakSelf?.metadata?.app?.type == VideoType.Movie.rawValue) ? VideoType.Movie.name : VideoType.TVShow.name
                        title = (weakSelf?.metadata?.name)!
                        episodeDetail = (weakSelf?.metadata?.app?.type == VideoType.Episode.rawValue) ? (weakSelf?.metadata?.description)! : ""
                    }
                }
                
                let eventProperties = ["Error Code":"-1","Error Message":String(describing: responseError.localizedDescription),"Type":type, "Title":title, "Content ID": weakSelf?.playerId ?? "", "Bitrate":"0","Episode":episodeDetail,"Platform":"TVOS","Failure":failureType] as [String : Any]
                weakSelf?.sendPlaybackFailureEvent(eventProperties: eventProperties)
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
                                //print("FPS URL Hit ==== \(String(describing: self.playbackRightsData?.url))")
                                self.instantiatePlayer(with: (self.playbackRightsData?.url)!)
                                
                                //For simulator
                                //print("AES URL Hit ==== \(String(describing: self.playbackRightsData?.aesUrl))")
                                //self.instantiatePlayer(with: (self.playbackRightsData?.aesUrl)!)
                            }
                            else
                            {
                                //print("123 AES URL Hit ==== \(String(describing: self.playbackRightsData?.aesUrl))")
                                
                                self.instantiatePlayer(with: (self.playbackRightsData!.aesUrl!))
                            }
                        }
                        else
                        {
                            //self.instantiatePlayer(with: (self.playbackRightsData!.aesUrl!))
                            
                            if let data = self.item as? Item
                            {
                              //  if !data.isPlaylist! {
                                   // print("data id is == \(data.id)")
                                    //print("data App type is == \(data.app?.type)")
                                    
                                    if data.app?.type == VideoType.Movie.rawValue
                                    {
                                        self.instantiatePlayer(with: (self.playbackRightsData?.url) ?? "")
                                        let url = metadataUrl.appending(data.id!)
                                        self.callWebServiceForMoreLikeData(url: url)
                                    }
                                    else if data.app?.type == VideoType.TVShow.rawValue
                                    {
                                        self.instantiatePlayer(with: (self.playbackRightsData?.url) ?? "")
                                        let url = metadataUrl.appending(data.id!).appending("/0/0")
                                        self.callWebServiceForMoreLikeData(url: url)
                                    }
                                    else if data.app?.type == VideoType.Trailer.rawValue
                                    {
                                        self.instantiatePlayer(with: (self.playbackRightsData?.aesUrl) ?? "")
                                        let url = metadataUrl.appending(data.id!)
                                        self.callWebServiceForMoreLikeData(url: url)
                                    }
                                    else if data.app?.type == VideoType.Episode.rawValue {
                                        self.instantiatePlayer(with: (self.playbackRightsData?.url) ?? "")
                                        let url = metadataUrl.appending(data.id!)
                                        self.callWebServiceForMoreLikeData(url: url)
                                    }
                                    else if data.app?.type == VideoType.Music.rawValue || data.app?.type == VideoType.Clip.rawValue
                                    {
                                        //print("Item From View Controller is \(selectedItemFromViewController.rawValue)")
                                        
                                        if selectedItemFromViewController == VideoType.Search || selectedItemFromViewController == VideoType.Music
                                        {
                                            self.instantiatePlayer(with: (self.playbackRightsData?.aesUrl) ?? "")
                                            let url = metadataUrl.appending(data.id!)
                                            if !data.isPlaylist! {
                                            self.callWebServiceForMoreLikeData(url: url)
                                            }
                                        }
                                        else  if selectedItemFromViewController == VideoType.Clip || selectedItemFromViewController == VideoType.Home || selectedItemFromViewController == VideoType.Language || selectedItemFromViewController == VideoType.Genre
                                        {
                                            self.instantiatePlayer(with: (self.playbackRightsData?.aesUrl) ?? "")
                                        }
                                   }
                                
                            }
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
                //print(responseError)
                return
            }
            
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                let code = parsedResponse["code"]
               // print("Removed from Resume Watchlist \(String(describing: code))")
                //JCDataStore.sharedDataStore.resumeWatchList?.data?.items = JCDataStore.sharedDataStore.resumeWatchList?.data?.items?.filter() { $0.id != self.playerId }
                if let homeVC = JCAppReference.shared.tabBarCotroller?.viewControllers![0] as? JCHomeVC{
                    homeVC.callWebServiceForResumeWatchData()
                }
                DispatchQueue.main.async {
                    //To remove from resume watch list and reload home vc
                    weakSelf?.dismiss(animated: false, completion: nil)
                }
            }
        }
        
    }
    
    func callWebServiceForAddToResumeWatchlist(currentTimeDuration:String,totalDuration:String)
    {
        let url = addToResumeWatchlistUrl
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
                //print(responseError)
                return
            }
            if let responseData = data, let _:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                //print("Added to Resume Watchlist")
                //To add in homevc and update resume watchlist data
                if let homeVC = JCAppReference.shared.tabBarCotroller?.viewControllers![0] as? JCHomeVC{
                    homeVC.callWebServiceForResumeWatchData()
                }
                
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
            //print("Video is already playing")
            return
        }
        
        self.currentPlayingIndex = indexPath.row
        referenceFromPlayerVC = "Player Recommendation"
        
        
        // var url = ""
        if metadata != nil
        {
            if metadata?.app?.type == VideoType.TVShow.rawValue
            {
                sendMediaEndAnalyticsEvent()
                let model = metadata?.episodes?[indexPath.row]
                self.metadata?.latestEpisodeId = model?.id
                self.currentItemImage = model?.banner
                self.currentItemTitle = model?.name
                duration = self.checkInResumeWatchList((model?.id)!)
                self.callWebServiceForPlaybackRights(id: (model?.id)!)
            }
            else if metadata?.app?.type == VideoType.Trailer.rawValue || metadata?.app?.type == VideoType.Music.rawValue || metadata?.app?.type == VideoType.Clip.rawValue
            {
                sendMediaEndAnalyticsEvent()
                let model = metadata?.more?[indexPath.row]
                self.currentItemImage = model?.banner
                self.currentItemTitle = model?.name
                self.currentItemDescription = model?.description
                //print("playable id is.....\(model?.id)")
                self.callWebServiceForPlaybackRights(id: (model?.id)!)
                
            }
            else if metadata?.app?.type == VideoType.Movie.rawValue
            {
                let model = metadata?.more?[indexPath.row]
                self.currentItemImage = model?.banner
                self.currentItemTitle = model?.name
                self.currentItemDescription = model?.description
                
                moreModal = model
                
                if let vc = self.presentingViewController as? JCMetadataVC{
                    vc.presentingViewController?.dismiss(animated: false, completion: {
                    DispatchQueue.main.async {
                    self.openMetaDataVC(model: model!)
                    }
                    })
                    
                }
                else
                {
                    
                    self.presentingViewController?.dismiss(animated: false, completion: {
                        DispatchQueue.main.async {
                            self.openMetaDataVC(model: model!)
                        }
                    })
                
                
//                if isResumed == true{
//                    self.dismiss(animated: true, completion: {
//                         self.openMetaDataVC(model: model!)
//                    })
//
//                }
//                else
//                {
//                    if let vc = self.presentingViewController?.presentingViewController as? JCMetadataVC{
//                        vc.dismiss(animated: true, completion: {
//                            DispatchQueue.main.async {
//                                self.openMetaDataVC(model: model!)
//                            }
//                        })
//                    }
//                    else
//                    {
//                            self.openMetaDataVC(model: model!)
//                    }
//
//                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
//                        DispatchQueue.main.async {
//                            self.openMetaDataVC(model: model!)
//                        }
//                    })
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
            else if (metadata?.app?.type == VideoType.Movie.rawValue || metadata?.app?.type == VideoType.Trailer.rawValue || metadata?.app?.type == VideoType.Music.rawValue || metadata?.app?.type == VideoType.Clip.rawValue), metadata?.more != nil
            {
                return (metadata?.more?.count)!
            }
        }
        else if let data = self.item as? Item
        {
            if data.isPlaylist != nil, data.isPlaylist!     // If Playlist exist
            {
                if playlistData != nil
                {
                    return (playlistData?.more?.count) ?? 0
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
            if let img = model?.banner{
                imageUrl = img
            }
            cell.nameLabel.text = model?.name
        }
        else if metadata?.app?.type == VideoType.Movie.rawValue || metadata?.app?.type == VideoType.Trailer.rawValue || metadata?.app?.type == VideoType.Music.rawValue || metadata?.app?.type == VideoType.Clip.rawValue
        {
            let model = metadata?.more?[indexPath.row]
            metaDataID = playerId!
            modelID = (model?.id)!
            if let img = model?.banner{
                imageUrl = img
            }
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
                    if let dataId = model.id{
                        modelID = dataId
                    }
                    if let img = model.banner{
                        imageUrl = img
                    }else if let thumb = model.image{
                        imageUrl = thumb
                    }
                   
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
        //totalDuration <- map["totalDuration"]
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
       // print("MD5Hex: \(MD5Data.map {String(format: "%02hhx", $0)}.joined())")
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
            //print("data: \(data!)")
            if (data != nil)
            {
                if let decodedData = Data(base64Encoded: data!, options: []){
                    completionHandler(decodedData)
                }else{
                    completionHandler(nil)
                }
                
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
            if error != nil {
                print(error)
                return
            }
            
            if (data != nil)
            {
               // print("ASYNC Certificate data: \(data!)")
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
                        
                       // print("Request Bytes is \(String(describing: requestBytes))")
                        //var responseData: Data? = nil
                        let expiryDuration = 0.0
                        
                        
                        self.getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest: requestBytes!, contentIdentifierHost: assetStr, leaseExpiryDuration: expiryDuration, error: error, completionHandler: { (responseData) in
                          //  print("Key  is \(String(describing: responseData))")
                            
                            
                            if (responseData != nil){
                                dataRequest?.respond(with: responseData!)
                                if expiryDuration != 0.0
                                {
                                    let infoRequest: AVAssetResourceLoadingContentInformationRequest? = loadingRequest.contentInformationRequest
                                    if (infoRequest != nil)
                                    {
                                        infoRequest?.renewalDate = Date(timeIntervalSinceNow: expiryDuration)
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
       // print(url!)
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
                //print("printing value of url \(urlString)")
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
    
    func checkInResumeWatchList(_ itemIdToBeChecked: String) -> Double{
        if let resumeWatchArray = JCDataStore.sharedDataStore.resumeWatchList?.data?.items
        {
            let itemMatched = resumeWatchArray.filter{ $0.id == itemIdToBeChecked}.first
            if itemMatched != nil
            {
                if let drn = itemMatched?.duration?.floatValue(){
                    return Double(drn)
                }
                
            }
        }
        return 0.0
    }
    
    func seekPlayer() {
        if duration >= (self.player?.currentItem?.currentTime().seconds)!, didSeek!{
                self.player?.seek(to: CMTimeMakeWithSeconds(duration, 1))
            }
        else{
            didSeek = false
        }
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        let lapseTime = CMTimeGetSeconds(targetTime) - CMTimeGetSeconds(oldTime)
        videoViewingLapsedTime = videoViewingLapsedTime + lapseTime
    }
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
