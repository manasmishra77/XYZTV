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
 
 enum AudioLanguage: String {
    case english
    case hindi
    case tamil
    case telugu
    case marathi
    case bengali
    case none
    
    var code: String {
        return self.rawValue.subString(start: 0, end: 1)
    }
    var name: String {
        return self.rawValue.capitalized
    }
    
 }
 class JCPlayerVC: UIViewController {

    @IBOutlet weak var textOnLoaderCoverView: UILabel!
    @IBOutlet weak var resumeWatchView: UIView!
    @IBOutlet weak var activityIndicatorOfLoaderView: UIActivityIndicatorView!
    @IBOutlet weak var loaderCoverView: UIView!
    @IBOutlet weak var nextVideoView                    :UIView!
    @IBOutlet weak var view_Recommendation              :UIView!
    @IBOutlet weak var nextVideoNameLabel               :UILabel!
    @IBOutlet weak var nextVideoPlayingTimeLabel        :UILabel!
    @IBOutlet weak var nextVideoThumbnail               :UIImageView!
    @IBOutlet weak var collectionView_Recommendation    :UICollectionView!
    
    //Player changes
    var id: String = ""
    var bannerUrlString: String = ""
    var itemTitle: String = ""
    var itemDescription: String = ""
    var totalDuration: Float = 0.0
    var currentDuration: Float = 0.0
    var appType: VideoType = VideoType.Clip
    var isPlayList: Bool = false
    var episodeArray = [Episode]()
    var moreArray = [More]()
    var isMoreDataAvailable = false
    var isEpisodeDataAvailable = false
    var playListId: String = ""
    
    var fromScreen = ""
    var fromCategory = ""
    var fromCategoryIndex = 0
    var itemLanguage = ""
    var director = ""
    var starCast = ""
    var vendor = ""
    
    fileprivate var isPlayListFirstItemToBePlayed = false
    fileprivate var videoViewingLapsedTime = 0.0
    fileprivate var totalBufferDurationTime = 0.0
    fileprivate var didSeek :Bool = false
    
    //For Resume watch update
    //fileprivate var lastItemId = ""
    fileprivate var isVideoUrlFailedOnce = false
    fileprivate var isItemToBeAddedInResumeWatchList = true
    fileprivate var isMediaStartEventSent = false
    fileprivate var isMediaEndAnalyticsEventNotSent = true
    fileprivate var startTime_BufferDuration    :Date?
    fileprivate var episodeNumber :Int? = nil
    
    fileprivate var isSwipingAllowed_RecommendationView = true
    fileprivate var playerTimeObserverToken     :Any?
    //For player controller
    @objc fileprivate var player                      :AVPlayer?
    fileprivate var playerItem                  :AVPlayerItem?
    fileprivate weak var playerController            :AVPlayerViewController?
    
    fileprivate var playbackRightsData          :PlaybackRightsModel?
    fileprivate var playlistData                :PlaylistDataModel?
    fileprivate var isRecommendationView        = false
    fileprivate var currentPlayingIndex         = -1
    fileprivate var bufferCount                 = 0
    fileprivate var isRecommendationViewVisible = false
    fileprivate var isFpsUrl = false
    fileprivate var videoStartingTime = Date()
    fileprivate var videoStartingTimeDuration = 0
    fileprivate var isRecommendationCollectionViewEnabled = false
    
    fileprivate var enterParentalPinView: EnterParentalPinView?
    fileprivate var enterPinViewModel: EnterPinViewModel?
    
    
    
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    var bitrate: String {
        get {
            var bitrateString:String = ""
            //var unit = "kBps"
            if let observedBitrate = playerItem?.accessLog()?.events.last?.observedBitrate {
                let bitrate =  observedBitrate / (8*1024)
                bitrateString = bitrate > 0 ? String(Int(bitrate)) : "0"
            }
            return bitrateString
        }
    }
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resumeWatchView.isHidden = true
        loaderCoverView.isHidden = true
        preparePlayerVC()
        addSwipeGesture()
        self.collectionView_Recommendation.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
    }
    deinit {
        print("In Player deinit")
    }
    override func viewWillDisappear(_ animated: Bool) {
        if isMediaEndAnalyticsEventNotSent {
            sendMediaEndAnalyticsEvent()
        }
        resetPlayer()
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
                        let autoPlayOn = UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
                        if autoPlayOn, (self?.isPlayList ?? false), (self?.nextVideoView.isHidden ?? false){
                            if self?.appType == .Music || self?.appType == .Clip || self?.appType == .Trailer{
                                if (self?.currentPlayingIndex)! + 1 < (self?.moreArray.count)! {
                                    let nextItem = self?.moreArray[(self?.currentPlayingIndex)! + 1]
                                    self?.showNextVideoView(videoName: nextItem?.name ?? "", remainingTime: Int(remainingTime), banner: nextItem?.banner ?? "")
                                }
                            }
                            else if self?.appType == .Episode {
                                if let nextItem = self?.gettingNextEpisode(episodes: (self?.episodeArray ?? [Episode]()), index: (self?.currentPlayingIndex ?? -1)) {
                                    self?.showNextVideoView(videoName: nextItem.name ?? "", remainingTime: Int(remainingTime), banner: nextItem.banner ?? "")
                                }
                            }
                        }
                    }
                } else {
                    self?.playerTimeObserverToken = nil
                }
        }
    }
    
    //MARK:- Autoplay handler
    private func gettingNextEpisode(episodes: [Episode], index: Int) -> Episode? {
        guard episodes.count > 1 else {return nil}
        if let firstEpisodeNum = episodes[0].episodeNo, let seconEpisodeNum = episodes[1].episodeNo {
            if firstEpisodeNum < seconEpisodeNum {
                //For handling Original Case
                if index < episodes.count - 1 {
                    let nextEpisode = episodes[index + 1]
                    return nextEpisode
                }
            } else {
                if (index - 1) > -1 {
                    let nextEpisode = episodes[index - 1]
                    return nextEpisode
                }
            }
        }
        return nil
    }
    
    
    //MARK:- Remove Player Observer
    func removePlayerObserver() {
        //sendMediaEndAnalyticsEvent()
        if (appType == .Movie || appType == .Episode), isItemToBeAddedInResumeWatchList {
            updateResumeWatchList()
        }
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
    
    func updateResumeWatchList() {
        if let currentTime = player?.currentItem?.currentTime(), let totalTime = player?.currentItem?.duration, (totalTime.timescale != 0), (currentTime.timescale != 0) {
            let currentTimeDuration = "\(Int(CMTimeGetSeconds(currentTime)))"
            let currentLanguage = ""
            let timeDifference = CMTimeGetSeconds(currentTime)
            let totalDuration = "\(Int(CMTimeGetSeconds(totalTime)))"
            
            if timeDifference < 300 {
                self.callWebServiceForRemovingResumedWatchlist(id)
            } else {
                self.callWebServiceForAddToResumeWatchlist(id, currentTimeDuration: currentTimeDuration, totalDuration: totalDuration ,currentLanguage: currentLanguage)
                
            }
        }
    }
    
    //MARK:- AVPlayerViewController Methods
    
    func resetPlayer() {
        if let player = player {
            player.pause()
            self.removePlayerObserver()
            playerController?.delegate = nil
            playerController?.willMove(toParentViewController: nil)
            playerController?.removeFromParentViewController()
            self.playerController = nil
        }
    }
    

   fileprivate func intantiatePlayerAfterParentalCheck(with url: String, isFps: Bool) {
        player = nil
        didSeek = true
        isFpsUrl = isFps
        //var newUrl = "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8"
        //       var newUrl = "http://vod.hdi.cdn.ril.com/vod1/_definst_/smil:vod1/92/57/5e3614904c4f11e89f355ddb50ec3dc2_HD_TESTANKIT.smil/playlist1.m3u8"
        //        newUrl = "http:///vod.hdi.cdn.ril.com/vod1/_definst_/smil:vod1/58/34/53ce62104c7111e8a913515d9b91c49a_audio_1530011632940.smil/playlist_SD_PHONE_HDP_H.m3u8"
        //        newUrl = "http://vod.hdi.cdn.ril.com/vod1/_definst_/smil:vod1/92/57/5e3614904c4f11e89f355ddb50ec3dc2_HD_TEST2.smil/playlist.m3u8"
        //        newUrl = "http://rcpems02.cdnsrv.ril.com/vod.hdi.cdn.ril.com/vod1/_definst_/smil:vod1/75/41/b52802404ce511e8a913515d9b91c49a_audio_1530176450916.smil/playlist.m3u8"
        //newUrl = "http://wvserver.jio.ril.com/live/_definst_/fpstest.stream/chunklist_w1266344597.m3u8"
        if isFps {
            handleFairPlayStreamingUrl(videoUrl: url)
        } else {
            handleAESStreamingUrl(videoUrl: url)
        }

    }
    
    //MARK:- Handle AES Video Url
    
    func handleAESStreamingUrl(videoUrl: String) {
        var videoAsset: AVURLAsset?
        if JCDataStore.sharedDataStore.cdnEncryptionFlag {
            let videoUrl = URL(string: videoUrl)
            if let absoluteUrlString = videoUrl?.absoluteString {
                let changedUrl = absoluteUrlString.replacingOccurrences(of: (videoUrl?.scheme ?? ""), with: "fakeHttp")
                let headerValues = ["ssotoken" : JCAppUser.shared.ssoToken]
                _ = playbackRightsData?.isSubscribed
                let header = ["AVURLAssetHTTPHeaderFieldsKey": headerValues]
                guard let assetUrl = URL(string: changedUrl) else {
                    return
                }
                videoAsset = AVURLAsset(url: assetUrl, options: header)
                videoAsset?.resourceLoader.setDelegate(self, queue: DispatchQueue(label: "testVideo-delegateQueue"))
            }
        } else {
            guard let assetUrl = URL(string: videoUrl) else { return }
            videoAsset = AVURLAsset(url: assetUrl)
        }
        guard let asset = videoAsset else {
            return
        }
        playerItem = AVPlayerItem(asset: asset)
        self.playVideoWithPlayerItem()
    }
    
    //MARK:- Handle Fairplay Video Url
    func handleFairPlayStreamingUrl(videoUrl: String) {
//                guard let url = URL(string: "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8") else {return}
        guard let url = URL(string: videoUrl) else {return}
        let asset = AVURLAsset(url: url, options: nil)
        asset.resourceLoader.setDelegate(self, queue: globalNotificationQueue())
        let requestedKeys: [Any] = [PLAYABLE_KEY]
        // Tells the asset to load the values of any of the specified keys that are not already loaded.
        asset.loadValuesAsynchronously(forKeys: requestedKeys as? [String] ?? [String](), completionHandler: {[weak self]() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                self?.prepare(toPlay: asset, withKeys: JCPlayerVC.assetKeysRequiredToPlay)
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
    func playVideoWithPlayerItem() {
        self.addMetadataToPlayer()
        if playerController == nil {
            playerController = AVPlayerViewController()
            playerController?.delegate = self
            if let player = player, let timeScale = player.currentItem?.asset.duration.timescale {
                player.seek(to: CMTimeMakeWithSeconds(Float64(currentDuration), timeScale))
            }
            
            self.addChildViewController(playerController!)
            self.view.addSubview((playerController?.view)!)
            playerController?.view.frame = self.view.frame
        }
        if let player = player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            resetPlayer()
            player = AVPlayer(playerItem: playerItem)
        }
        self.autoPlaySubtitle(IsAutoSubtitleOn)
        self.playerAudioLanguage("HINDI")
        addPlayerNotificationObserver()
        playerController?.player = player
        player?.play()
        handleForPlayerReference()
        
        self.view.bringSubview(toFront: self.nextVideoView)
        self.view.bringSubview(toFront: self.view_Recommendation)      
        
        self.nextVideoView.isHidden = true
    }

    
    private func autoPlaySubtitle(_ isAutoPlaySubtitle: Bool) {
        guard isAutoPlaySubtitle else {return}
        let subtitles = player?.currentItem?.tracks(type: .subtitle)
        // Select track with displayName
        guard (subtitles?.count ?? 0) > 0 else {return}
        _ = player?.currentItem?.select(type: .subtitle, name: (subtitles?.first)!)
    }
    
    private func playerAudioLanguage(_ audioLanguage: String?) {
        
        guard let audioLanguage = audioLanguage else {
            return
        }
        let audioes = player?.currentItem?.tracks(type: .audio)
        // Select track with displayName
        guard (audioes?.count ?? 0) > 0 else {return}
        
        
        if let langIndex = audioes?.index(where: {$0.lowercased() == audioLanguage.lowercased()}), let language = audioes?[langIndex] {
            _ = player?.currentItem?.select(type: .audio, name: language)
        }
    }
    
    func handleForPlayerReference() {
        if isMoreDataAvailable{
            collectionView_Recommendation.reloadData()
            if isPlayList{
                var i = 0
                var isMatched = false
                for each in moreArray{
                    if each.id == id{
                        isMatched = true
                        break
                    }
                    i = i + 1
                }
                if isMatched,i == moreArray.count{
                    i = i - 1
                }
                else if i == moreArray.count{
                    i = 0
                }
                scrollCollectionViewToRow(row: i)
            }else{
                scrollCollectionViewToRow(row: 0)
            }
            
        }
        else if isEpisodeDataAvailable{
            var i = 0
            var isMatched = false
            for each in episodeArray{
                if each.id == id{
                    isMatched = true
                    episodeNumber = each.episodeNo
                    break
                }
                i = i + 1
            }
            if i == episodeArray.count{
                if isMatched{
                    i = i - 1
                }else{
                    i = 0
                }
            }
            collectionView_Recommendation.reloadData()
            scrollCollectionViewToRow(row: i)
        } else {
            if isPlayList, appType == .Episode {
                callWebServiceForMoreLikeData(id: playListId)
            } else if isPlayList {
                callWebServiceForPlayListData(id: playListId)
            } else {
                callWebServiceForMoreLikeData(id: id)
            }
        }
        
    }
    
    func addMetadataToPlayer() {
        let titleMetadataItem = AVMutableMetadataItem()
        titleMetadataItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
        titleMetadataItem.extendedLanguageTag = "und"
        titleMetadataItem.locale = NSLocale.current
        titleMetadataItem.key = AVMetadataKey.commonKeyTitle as NSCopying & NSObjectProtocol
        titleMetadataItem.keySpace = AVMetadataKeySpace.common
        titleMetadataItem.value = itemTitle as NSCopying & NSObjectProtocol
        
        
        let descriptionMetadataItem = AVMutableMetadataItem()
        descriptionMetadataItem.identifier = AVMetadataIdentifier.commonIdentifierDescription
        descriptionMetadataItem.extendedLanguageTag = "und"
        descriptionMetadataItem.locale = NSLocale.current
        descriptionMetadataItem.key = AVMetadataKey.commonKeyDescription as NSCopying & NSObjectProtocol
        descriptionMetadataItem.keySpace = AVMetadataKeySpace.common
        
        descriptionMetadataItem.value = itemDescription as NSCopying & NSObjectProtocol
        
        
        
        let imageMetadataItem = AVMutableMetadataItem()
        imageMetadataItem.identifier = AVMetadataIdentifier.commonIdentifierArtwork
        imageMetadataItem.extendedLanguageTag = "und"
        imageMetadataItem.locale = NSLocale.current
        imageMetadataItem.key = AVMetadataKey.commonKeyArtwork as NSCopying & NSObjectProtocol
        imageMetadataItem.keySpace = AVMetadataKeySpace.common
        let imageUrl = (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(bannerUrlString)) ?? ""
        
        RJILImageDownloader.shared.downloadImage(urlString: imageUrl, shouldCache: false){
            image in
            
            if let img = image {
                DispatchQueue.main.async {
                    let pngData = UIImagePNGRepresentation(img)
                    imageMetadataItem.value = pngData as (NSCopying & NSObjectProtocol)?
                }
            }
        }
        
        
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
        guard self.player != nil else {
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
            let newRate = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.doubleValue ?? 0
            
            if newRate == 0
            {
                swipeDownRecommendationView()
            }
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackBufferEmpty)
        {
            startTime_BufferDuration = Date()
            //bufferCount = bufferCount + 1
            
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.isPlaybackLikelyToKeepUp)
        {
            guard let startDuration = startTime_BufferDuration else {
                return
            }
            let difference =  Date().timeIntervalSince(startDuration)
            if (difference > 1) {
                totalBufferDurationTime = difference + totalBufferDurationTime
                bufferCount = bufferCount + 1
            } else {
                startTime_BufferDuration = Date()
            }
            
        }
        else if keyPath == #keyPath(JCPlayerVC.player.currentItem.status) {
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue) ?? .unknown
            }
            else {
                newStatus = .unknown
            }
            switch newStatus {
            case .readyToPlay:
                self.seekPlayer()
                videoStartingTimeDuration = Int(videoStartingTime.timeIntervalSinceNow)
                isItemToBeAddedInResumeWatchList = true
                self.isRecommendationCollectionViewEnabled = true
                self.addPlayerPeriodicTimeObserver()
                self.sendMediaStartAnalyticsEvent()
                break
            case .failed:
                Log.DLog(message: "Failed" as AnyObject)
                self.isRecommendationCollectionViewEnabled = false
                var failureType = "FPS"
                //If video failed once and valid fps url is there
                if !isVideoUrlFailedOnce, let _ = self.playbackRightsData?.url {
                    isVideoUrlFailedOnce = true
                    failureType = "FPS"
                    isFpsUrl = false
                    self.handleAESStreamingUrl(videoUrl: self.playbackRightsData?.aesUrl ?? "")
                } else {
                    /*
                    //AES url failed
                    failureType = "AES"
                    let alert = UIAlertController(title: "Unable to process your request right now", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                        DispatchQueue.main.async {
                            print("dismiss")
                            self.dismissPlayerVC()
                        }
                    }
                    alert.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self.present(alert, animated: false, completion: nil)
                    }*/
                }
                let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: playerItem?.error?.localizedDescription), "Type": appType.name, "Title": itemTitle, "Content ID": id, "Bitrate": bitrate, "Episode": itemDescription, "Platform": "TVOS", "Failure": failureType] as [String : Any]
                let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: failureType, errorCode: "-1", videoType: appType.name, contentTitle: itemTitle, contentId: id, videoQuality: "Auto", bitrate: bitrate, episodeSubtitle: itemDescription, playerErrorMessage: String(describing: playerItem?.error?.localizedDescription), apiFailureCode: "", message: "", fpsFailure: "")
                
                sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
                
            default:
                print("unknown")
            }
            
        }
    }
    
    //MARK:- AVPlayer Finish Playing Item
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey), isPlayList{
            if self.appType == .Music || self.appType == .Clip || self.appType == .Trailer{
                if (self.currentPlayingIndex) + 1 < (self.moreArray.count) {
                    let nextItem = self.moreArray[(self.currentPlayingIndex) + 1]
                    if isMediaEndAnalyticsEventNotSent{
                        isMediaEndAnalyticsEventNotSent = false
                        sendMediaEndAnalyticsEvent()
                    }
                    changePlayerVC(nextItem.id ?? "", itemImageString: nextItem.banner ?? "", itemTitle: nextItem.name ?? "", itemDuration: 0, totalDuration: 50, itemDesc: nextItem.description ?? "", appType: appType, isPlayList: isPlayList, playListId: playListId, isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: PLAYER_SCREEN, fromCategory: RECOMMENDATION, fromCategoryIndex: 0)
                    preparePlayerVC()
                }else{
                    dismissPlayerVC()
                }
            }
            else if self.appType == .Episode {
                if let nextItem = self.gettingNextEpisode(episodes: self.episodeArray, index: self.currentPlayingIndex) {
                    changePlayerVC(nextItem.id ?? "", itemImageString: nextItem.banner ?? "", itemTitle: nextItem.name ?? "", itemDuration: 0, totalDuration: 50, itemDesc: self.itemDescription, appType: appType, isPlayList: isPlayList, playListId: playListId, isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: PLAYER_SCREEN, fromCategory: RECOMMENDATION, fromCategoryIndex: 0)
                    preparePlayerVC()
                } else {
                    dismissPlayerVC()
                }
            }
        } else {
            dismissPlayerVC()
        }
    }
    
   
    
    
    //MARK:- Analytics Events
    func sendMediaStartAnalyticsEvent() {
        if !isMediaStartEventSent {
            let mbid = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss") + (UIDevice.current.identifierForVendor?.uuidString ?? "")
            
            let mediaStartInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaStartEventForInternalAnalytics(contentId: id, mbid: mbid, mediaStartTime: String(currentDuration), categoryTitle: fromCategory, rowPosition: String(fromCategoryIndex + 1))
            JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaStartInternalEvent)
            
            let customParams: [String:Any] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ,"Video Id": id, "Type": appType.rawValue, "Category Position": String(fromCategoryIndex), "Language": itemLanguage, "Bitrate" : bitrate, "Duration" : currentDuration]
            JCAnalyticsManager.sharedInstance.event(category: VIDEO_START_EVENT, action: VIDEO_ACTION, label: itemTitle, customParameters: customParams as? Dictionary<String, String>)
            isMediaStartEventSent = true
        }
        
    }
    
    func sendBufferingEvent(eventProperties: [String:Any]) {
        let bufferCountForGA = eventProperties["Buffer Count"] as? String
        let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
        JCAnalyticsManager.sharedInstance.event(category: "Player Options", action: "Buffering", label: bufferCountForGA, customParameters: customParams)
        
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Buffering", properties: eventProperties)
    }
    
    func sendPlaybackFailureEvent(forCleverTap eventPropertiesCT:[String:Any], forInternalAnalytics eventPropertiesIA: [String: Any])
    {
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Playback Error", properties: eventPropertiesCT)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: eventPropertiesIA)
    }
    
    func sendMediaEndAnalyticsEvent() {
        vendor = playbackRightsData?.vendor ?? ""
        if let currentTime = player?.currentItem?.currentTime(), (currentTime.timescale != 0) {
            
            let currentTimeDuration = "\(Int(CMTimeGetSeconds(currentTime)))"
            let timeSpent = CMTimeGetSeconds(currentTime) - Double(currentDuration) - videoViewingLapsedTime
            
            let mediaEndInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaEndEventForInternalAnalytics(contentId: id, playerCurrentPositionWhenMediaEnds: currentTimeDuration, ts: "\(Int(timeSpent > 0 ? timeSpent : 0))", videoStartPlayingTime: "\(-videoStartingTimeDuration)", bufferDuration: String(describing: Int(totalBufferDurationTime)) , bufferCount: String(Int(bufferCount)), screenName: fromScreen, bitrate: bitrate, playList: String(isPlayList), rowPosition: String(fromCategoryIndex + 1), categoryTitle: fromCategory, director: director, starcast: starCast, contentp: vendor)
            
            JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaEndInternalEvent)
            let customParams: [String:Any] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ,"Video Id": id, "Type": appType.rawValue, "Category Position": String(fromCategoryIndex), "Language": itemLanguage, "Bitrate": bitrate, "Duration" : timeSpent]
            JCAnalyticsManager.sharedInstance.event(category: VIDEO_END_EVENT, action: VIDEO_ACTION, label: itemTitle, customParameters: customParams as? Dictionary<String, String>)
            
            bufferCount = 0
            videoStartingTimeDuration = 0
            videoStartingTime = Date()
        }
        self.sendVideoViewedEventToCleverTap()
    }
    
    
    func sendVideoViewedEventToCleverTap() {
        let eventProperties:[String:Any] = ["Content ID": id, "Type": appType.rawValue, "Threshold Duration": Int(currentDuration), "Title": itemTitle, "Episode": episodeNumber ?? -1, "Language": itemLanguage, "Source": fromCategory, "screenName": fromScreen, "Bitrate": bitrate, "Playlist": isPlayList, "Row Position":fromCategoryIndex, "Error Message": "", "Genre": "", "Platform": "TVOS", "Director": director, "Starcast": starCast, "Content Partner": vendor]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Video Viewed", properties: eventProperties)
        
        let bufferEventProperties = ["Buffer Count": String(Int(bufferCount/2)),"Buffer Duration": Int(totalBufferDurationTime),"Content ID":id,"Type":appType.rawValue,"Title":itemTitle,"Episode":episodeNumber ?? -1,"Bitrate":bitrate, "Platform":"TVOS"] as [String : Any]
        sendBufferingEvent(eventProperties: bufferEventProperties)
        videoViewingLapsedTime = 0
        totalBufferDurationTime = 0
        bufferCount = 0
    }
    
    //MARK:- Scroll Collection View To Row
    var myPreferredFocusView:UIView? = nil
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferredView = myPreferredFocusView {
            return [preferredView]
        }
        return []
    }
    
    func scrollCollectionViewToRow(row: Int) {
        print("Scroll to Row is = \(row)")
        if row >= 0, collectionView_Recommendation.numberOfItems(inSection: 0) > 0 {
            DispatchQueue.main.async {
                self.collectionView_Recommendation.isScrollEnabled = true
                let path = IndexPath(row: row, section: 0)
                
                self.collectionView_Recommendation.scrollToItem(at: path, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
                let cell = self.collectionView_Recommendation.cellForItem(at: path)
                self.currentPlayingIndex = row
                self.myPreferredFocusView = cell
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
                
            }
        }
    }
    
    //MARK:- Open MetaDataVC
    func openMetaDataVC(model:More) {
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
    func hideUnhideNowPlayingView(cell: JCItemCell, state: Bool) {
        DispatchQueue.main.async {
            cell.nowPlayingImageView.isHidden = state
        }
    }
    //MARK:- Show Next Video View
    
    func showNextVideoView(videoName: String, remainingTime: Int, banner: String) {
        DispatchQueue.main.async {
            self.nextVideoView.isHidden = false
            self.nextVideoNameLabel.text = videoName
            self.nextVideoPlayingTimeLabel.text = "Playing in " + "\(5)" + " Seconds"
            var t1 = 4
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true , block: {(t) in
                
                self.nextVideoPlayingTimeLabel.text = "Playing in " + "\(Int(t1))" + " Seconds"
                if t1 < 1{
                    self.nextVideoView.isHidden = true
                    t.invalidate()
                }
                t1 = t1 - 1
            })
            
            let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(banner) ?? ""
            let url = URL(string: imageUrl)
            self.nextVideoThumbnail.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
        
    }
    
    //MARK:- Custom Setting
    func setCustomRecommendationViewSetting(state: Bool) {
        
        self.isRecommendationView = state
        self.collectionView_Recommendation.reloadData()
        if state
        {
            self.scrollCollectionViewToRow(row: currentPlayingIndex)
        } else {
            DispatchQueue.main.async {
                self.myPreferredFocusView = nil
                self.setNeedsFocusUpdate()
            }
        }
    }
    
    
    //MARK:- Add Swipe Gesture
    func addSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandler))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandler))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeGestureHandler(gesture: UIGestureRecognizer) {
        if !isSwipingAllowed_RecommendationView {
            return
        }
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                self.swipeUpRecommendationView()
            case UISwipeGestureRecognizerDirection.down:
                self.swipeDownRecommendationView()
            default:
                break
            }
        }
    }
    
    //MARK:- Swipe Up Recommendation View
    func swipeUpRecommendationView()
    {
        recommendationViewchangeTo(1.0, visibility: true, animationDuration: 0.0)
        
        Log.DLog(message: "swipeUpRecommendationView" as AnyObject)
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, animations: {
                let tempFrame = self.nextVideoView.frame
                self.nextVideoView.frame = CGRect(x: tempFrame.origin.x, y: tempFrame.origin.y - 300, width: tempFrame.size.width, height: tempFrame.size.height)
                self.view_Recommendation.frame = CGRect(x: 0, y: screenHeight - 300, width: screenWidth, height: self.view_Recommendation.frame.height)
            }, completion: { (completed) in
                self.setCustomRecommendationViewSetting(state: true)
            })
        }
    }
    //MARK:- Swipe Down Recommendation View
    func swipeDownRecommendationView() {
        Log.DLog(message: "swipeDownRecommendationView" as AnyObject)
        collectionView_Recommendation.isScrollEnabled = false
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, animations: {
                let tempFrame = self.nextVideoView.frame
                self.nextVideoView.frame = CGRect(x: tempFrame.origin.x, y: tempFrame.origin.y + 300, width: tempFrame.size.width, height: tempFrame.size.height)
                self.view_Recommendation.frame = CGRect(x: 0, y: screenHeight-60, width: screenWidth, height: self.view_Recommendation.frame.height)
            }, completion: { (completed) in
                self.setCustomRecommendationViewSetting(state: false)
                self.recommendationViewchangeTo(0.0, visibility: false, animationDuration: 4.0)
            })
        }
    }
    
    
    //MARK:- Show Alert
    func showAlert(alertTitle:String, alertMessage:String, completionHandler:(()->Void)?)
    {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        //self.present(alert, animated: true, completion: completionHandler)
    }
    
    
    //MARK:- Web service methods
    func callWebServiceForMoreLikeData(id: String) {
        let url = metadataUrl.appending(id)
        let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        RJILApiManager.defaultManager.get(request: metadataRequest) { [weak self] (data, response, error) in

            guard let self = self else {
                return
            }
            
            if let responseError = error as NSError?
            {
                //TODO: handle error
                //Refresh sso token call fails
                if responseError.code == 143{
                    print("Refresh sso token call fails")
                    
                }
                return
            }
            if let responseData = data
            {
                let recommendationItems = self.evaluateMoreLikeData(dictionaryResponseData: responseData)
                var i = 0
                if let episodes = recommendationItems as? [Episode]{
                    self.isEpisodeDataAvailable = false
                    
                    self.episodeArray.removeAll()
                    if episodes.count > 0{
                        self.episodeArray.removeAll()
                        if episodes.count > 0{
                            self.isEpisodeDataAvailable = true
                            for each in episodes{
                                if each.id == self.id{
                                    self.episodeNumber = each.episodeNo
                                    break
                                }
                                i = i + 1
                            }
                            if i == episodes.count{
                                i = i - 1
                            }
                            self.episodeArray = episodes
                        }
                        self.isEpisodeDataAvailable = true
                        self.episodeArray = episodes
                    }
                }
                else if let mores = recommendationItems as? [More]{
                    self.isMoreDataAvailable = false
                    self.moreArray.removeAll()
                    if mores.count > 0{
                        self.isMoreDataAvailable = true
                        self.moreArray = mores
                    }
                }
                if (self.isMoreDataAvailable) || (self.isEpisodeDataAvailable){
                    DispatchQueue.main.async {
                        self.collectionView_Recommendation.reloadData()
                        self.scrollCollectionViewToRow(row: i)
                    }
                }
                return
            }
        }
    }
    
    func evaluateMoreLikeData(dictionaryResponseData responseData:Data) -> [Any]
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            if let tempMetadata = MetadataModel(JSONString: responseString){
                if let mores = tempMetadata.more{
                    return mores
                }
                if let episodes = tempMetadata.episodes {
                    return episodes
                }
            }
        }
        return [More]()
    }
    
    func callWebServiceForPlayListData(id:String) {
        //playerId = id
        let url = String(format:"%@%@/%@", playbackDataURL, JCAppUser.shared.userGroup, id)
        let params = ["id": id,"contentId":""]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { [weak self] (data, response, error) in
            
            guard let self = self else {
                return
            }
            if let responseError = error as NSError?
            {
                //TODO: handle error
                //Refresh sso token call fails
                var failureType = ""
                if responseError.code == 143{
                    print("Refresh sso token call fails")
                    let vc = self.presentingViewController
                    DispatchQueue.main.async {
                        JCLoginManager.sharedInstance.logoutUser()
                        self.resetPlayer()
                        self.dismiss(animated: false, completion: {
                            let loginVc = Utility.sharedInstance.prepareLoginVC(presentingVC: vc)
                            vc?.present(loginVc, animated: false, completion: nil)
                        })
                        return
                    }
                    failureType = "Referesh SSO fails"
                }
                print(responseError)
                DispatchQueue.main.async {
                    //self.activityIndicatorOfLoaderView.stopAnimating()
                    self.activityIndicatorOfLoaderView.isHidden = true
                    self.textOnLoaderCoverView.text = "Some problem occured!!, please login again!!"
                    Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(JCPlayerVC.dismissPlayerVC), userInfo: nil, repeats: false)
                }
                failureType = "Playlist service failed"
                let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: responseError.localizedDescription), "Type": self.appType.name , "Title": self.itemTitle , "Content ID": self.id , "Bitrate": "0", "Episode": self.itemDescription , "Platform": "TVOS", "Failure": failureType] as [String : Any]
                let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: String(describing: responseError.localizedDescription), errorCode: "-1", videoType: self.appType.name , contentTitle: self.itemTitle , contentId: self.id , videoQuality: "Auto", bitrate: "0", episodeSubtitle: self.itemDescription , playerErrorMessage: String(describing: responseError.localizedDescription), apiFailureCode: "", message: "", fpsFailure: "")
                
                self.sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
                return
            }
            
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    if let playList = PlaylistDataModel(JSONString: responseString){
                        if let mores = playList.more{
                            self.moreArray.removeAll()
                            if mores.count > 0{
                                self.isMoreDataAvailable = true
                                var i = 0
                                for each in mores{
                                    if each.id == self.id{
                                        break
                                    }
                                    i = i + 1
                                }
                                if i == mores.count{
                                    i = i - 1
                                }
                                self.moreArray = mores
                                if (self.isPlayListFirstItemToBePlayed){
                                    self.isPlayListFirstItemToBePlayed = false
                                    let playlistFirstItem = mores[0]
                                    self.changePlayerVC(playlistFirstItem.id ?? "", itemImageString: playlistFirstItem.banner ?? "", itemTitle: playlistFirstItem.name ?? "", itemDuration: 0, totalDuration: 0, itemDesc: playlistFirstItem.description ?? "", appType: .Music, isPlayList: true, playListId: self.playListId , isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: self.fromScreen , fromCategory: self.fromCategory, fromCategoryIndex: self.fromCategoryIndex)
                                    self.preparePlayerVC()
                                }
                                else{
                                    DispatchQueue.main.async {
                                        self.collectionView_Recommendation.reloadData()
                                        self.scrollCollectionViewToRow(row: i)
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
    
    func callWebServiceForPlaybackRights(id:String) {
        isSwipingAllowed_RecommendationView = true
        DispatchQueue.main.async {
            self.activityIndicatorOfLoaderView.startAnimating()
        }
        print("Playback rights id is === \(id)")
        //playerId = id
        let url = playbackRightsURL.appending(id)
        let params = ["id": id, "showId": "", "uniqueId": JCAppUser.shared.unique, "deviceType": "stb"]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { [weak self] (data, response, error) in
            
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.activityIndicatorOfLoaderView.stopAnimating()
            }
            if let responseError = error as NSError?
            {
                //TODO: handle error
                var failuretype = ""
                switch responseError.code {
                case 143:
                    //Refresh sso token call fails
                    print("Refresh sso token call fails")
                    let vc = self.presentingViewController
                    DispatchQueue.main.async {
                        JCLoginManager.sharedInstance.logoutUser()
                        self.resetPlayer()
                        self.dismiss(animated: false, completion: {
                            let loginVc = Utility.sharedInstance.prepareLoginVC(presentingVC: vc)
                            vc?.present(loginVc, animated: false, completion: nil)
                        })
                        return
                    }
                    failuretype = "Refresh SSO failed"
                case 451:
                    //Content not available
                    print(responseError)
                    DispatchQueue.main.async {
                        //self.activityIndicatorOfLoaderView.stopAnimating()
                        self.activityIndicatorOfLoaderView.isHidden = true
                        self.textOnLoaderCoverView.text = ContentNotAvailable_msg
                        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(JCPlayerVC.dismissPlayerVC), userInfo: nil, repeats: false)
                    }
                    failuretype = ContentNotAvailable_msg
                default:
                    print(responseError)
                    DispatchQueue.main.async {
                        //self.activityIndicatorOfLoaderView.stopAnimating()
                        self.activityIndicatorOfLoaderView.isHidden = true
                        self.textOnLoaderCoverView.text = "Some problem occured!!, please login again!!"
                        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(JCPlayerVC.dismissPlayerVC), userInfo: nil, repeats: false)
                    }
                    failuretype = "Playbackrights failed"
                }
                let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: responseError.localizedDescription), "Type": self.appType.name , "Title": self.itemTitle , "Content ID": self.id , "Bitrate": "0", "Episode": self.itemDescription , "Platform": "TVOS", "Failure": failuretype] as [String : Any]
                let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: String(describing: responseError.localizedDescription), errorCode: "-1", videoType: self.appType.name , contentTitle: self.itemTitle , contentId: self.id , videoQuality: "Auto", bitrate: "0", episodeSubtitle: self.itemDescription , playerErrorMessage: String(describing: responseError.localizedDescription), apiFailureCode: "", message: "", fpsFailure: "")
                
                self.sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
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
//                        self.playbackRightsData?.url = nil
                        if let fpsUrl = self.playbackRightsData?.url {
                            self.doParentalCheck(with: fpsUrl, isFps: true)
                        } else if let aesUrl = self.playbackRightsData?.aesUrl {
                            self.doParentalCheck(with: aesUrl, isFps: false)
                        } else {
                            let alert = UIAlertController(title: "Content not available!!", message: "", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                                DispatchQueue.main.async {
                                    print("dismiss")
                                    self.dismissPlayerVC()
                                }
                            }
                            alert.addAction(cancelAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: false, completion: nil)
                            }
                        }
                    }
                }
                return
            }
        }
    }
    
    
    func callWebServiceForRemovingResumedWatchlist(_ itemId: String) {
        let json = ["id": id]
        let params = ["uniqueId": JCAppUser.shared.unique,"listId": "10","json": json] as [String : Any]
        let url = removeFromResumeWatchlistUrl
        let removeRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: removeRequest) { (data, response, error) in
            if let responseError = error as NSError?
            {
                //TODO: handle error
                
                if responseError.code == 143{
                    //Refresh sso token call fails
                    print("Refresh sso token call fails")
                }
                print(responseError)
                return
            }
            
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                NotificationCenter.default.post(name: resumeWatchReloadNotification, object: nil, userInfo: nil)
            }
        }
    }
    
    func callWebServiceForAddToResumeWatchlist(_ itemId: String, currentTimeDuration: String, totalDuration: String, currentLanguage: String)
    {
        let url = addToResumeWatchlistUrl

        let id = itemId
        let audioLanguage = AudioLanguage(rawValue: playbackRightsData?.languageIndex?.name ?? "") ?? .none
        let languageIndexDict: Dictionary<String, Any> = ["name": audioLanguage.name, "code": audioLanguage.code, "index":playbackRightsData?.languageIndex?.index ?? 0]

        let json: Dictionary<String, Any> = ["id": id, "duration": currentTimeDuration, "totalDuration": totalDuration, "languageIndex": languageIndexDict]
        
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = JCAppUser.shared.unique
        params["listId"] = 10
        params["json"] = json
        params["id"] = id
        params["duration"] = currentTimeDuration
        params["totalDuration"] = totalDuration
        let addToResumeWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: addToResumeWatchlistRequest) { (data, response, error) in
            if let responseError = error
            {
                return
            }
            if let responseData = data, let _:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                NotificationCenter.default.post(name: resumeWatchReloadNotification, object: nil, userInfo: nil)
                return
            }
        }
    }
    //MARK:- Resume watch view methods
    @IBAction func didClickOnResumeWatchingButton(_ sender: Any) {
        resumeWatchView.isHidden = true
        callWebServiceForPlaybackRights(id: id)
    }
    @IBAction func didClickOnStartWatchingButton(_ sender: Any) {
        currentDuration = 0
        resumeWatchView.isHidden = true
        callWebServiceForPlaybackRights(id: id)
    }
    @IBAction func didClickOnRemoveFromResumeWatchingButton(_ sender: Any) {
        //callWebServiceForUpdatingResumedWatchlist()
        callWebServiceForRemovingResumedWatchlist(id)
        dismissPlayerVC()
    }
    
    //MARK:- Player Methods
    func preparePlayerVC() {
        isMediaEndAnalyticsEventNotSent = true
        isRecommendationCollectionViewEnabled = false
        isMediaStartEventSent = false
        switch appType {
        case .Movie:
            currentDuration = checkInResumeWatchList(id)
            if currentDuration > 0 {
                isSwipingAllowed_RecommendationView = false
                resumeWatchView.isHidden = false
            } else {
                resumeWatchView.isHidden = true
                callWebServiceForPlaybackRights(id: id)
            }
        case .Episode:
            currentDuration = checkInResumeWatchList(id)
            if currentDuration > 0 {
                isSwipingAllowed_RecommendationView = false
                resumeWatchView.isHidden = false
                player?.pause()
                self.view.bringSubview(toFront: self.resumeWatchView)
            } else {
                resumeWatchView.isHidden = true
                callWebServiceForPlaybackRights(id: id)
            }
        case .Music, .Clip, .Trailer:
            if isPlayList, id == "" {
                self.isPlayListFirstItemToBePlayed = true
                callWebServiceForPlayListData(id: playListId)
            } else {
                callWebServiceForPlaybackRights(id: id)
            }
        default:
            break
        }
    }
    
    //PlayerVc changing when an item is played from playervc recommendation
    func changePlayerVC(_ itemId: String, itemImageString: String, itemTitle: String, itemDuration: Float, totalDuration: Float, itemDesc: String, appType: VideoType, isPlayList: Bool, playListId: String, isMoreDataAvailable: Bool, isEpisodeAvailable: Bool, recommendationArray: [Any] = [Any](), fromScreen: String, fromCategory: String, fromCategoryIndex: Int) {
        self.id = itemId
        self.bannerUrlString = itemImageString
        self.itemTitle = itemTitle
        self.currentDuration = itemDuration
        self.totalDuration = totalDuration
        self.itemDescription = itemDesc
        self.appType = appType
        self.isPlayList = isPlayList
        self.playListId = playListId
    }
    
    //Seek player
    func seekPlayer() {
        if Double(currentDuration) >= ((self.player?.currentItem?.currentTime().seconds) ?? 0.0), didSeek{
            self.player?.seek(to: CMTimeMakeWithSeconds(Float64(currentDuration), 1))
        } else {
            didSeek = false
        }
    }
    func sendRecommendationEvent(videoName: String) {
        let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
        JCAnalyticsManager.sharedInstance.event(category: "Player Options", action: "Recommendation", label: videoName, customParameters: customParams)
    }
    
    func handleAPIFailure(_ text: String) {
        let action = Utility.AlertAction(title: "Dismiss", style: .default)
        let alertVC = Utility.getCustomizedAlertController(with: text, message: "", actions: [action]) {[weak self] (alertAction) in
            if alertAction.title == action.title {
                self?.dismissPlayerVC()
            }
        }
        present(alertVC, animated: false, completion: nil)
    }
    
    //Check in resume watchlist
    func checkInResumeWatchList(_ itemIdToBeChecked: String) -> Float {
        if let resumeWatchArray = JCDataStore.sharedDataStore.resumeWatchList?.data?.items {
            let itemMatched = resumeWatchArray.filter{ $0.id == itemIdToBeChecked}.first
            if let drn = itemMatched?.duration?.floatValue() {
                return drn
            }
        }
        return 0.0
    }
    
    //MARK:- Dismiss Viewcontroller
    @objc func dismissPlayerVC() {
        self.resetPlayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Change recommendation view visibility
    func recommendationViewchangeTo(_ alpha: Double, visibility: Bool, animationDuration: TimeInterval) {
        isRecommendationViewVisible = visibility
        UIView.animate(withDuration: animationDuration) {
            self.view_Recommendation.alpha = CGFloat(alpha)
        }
    }
 }
 
 //MARK:- UICOLLECTIONVIEW DELEGATE
 extension JCPlayerVC: UICollectionViewDelegate
 {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return isRecommendationView
        //return true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.swipeDownRecommendationView()
        guard isRecommendationCollectionViewEnabled else {
            return
        }
        isRecommendationCollectionViewEnabled = false
        if isMoreDataAvailable {
            if isPlayList {
                let newItem = moreArray[indexPath.row]
                if (newItem.id ?? "") == id {
                    isRecommendationCollectionViewEnabled = true
                    return
                }
                //Send Media-end analytics event
                if isMediaEndAnalyticsEventNotSent {
                    isMediaEndAnalyticsEventNotSent = false
                    sendMediaEndAnalyticsEvent()
                    sendRecommendationEvent(videoName: newItem.name ?? "")
                }
                changePlayerVC(newItem.id ?? "", itemImageString: (newItem.banner) ?? "", itemTitle: (newItem.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (self.itemDescription), appType: appType, isPlayList: (self.isPlayList) , playListId: (self.playListId), isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: moreArray, fromScreen: PLAYER_SCREEN, fromCategory: RECOMMENDATION, fromCategoryIndex: 0)
                preparePlayerVC()
            }
            else{
                let newItem = moreArray[indexPath.row]
                if (newItem.id ?? "") == id {
                    isRecommendationCollectionViewEnabled = true
                    return
                }
                //Send Media-end analytics event
                if isMediaEndAnalyticsEventNotSent {
                    isMediaEndAnalyticsEventNotSent = false
                    sendMediaEndAnalyticsEvent()
                    sendRecommendationEvent(videoName: newItem.name ?? "")
                }
                
                if let newAppTypeInt = newItem.app?.type, let newAppType = VideoType(rawValue: newAppTypeInt){
                    if newAppType == .Movie {
                        //Present Metadata
                        if let metaDataVC = self.presentingViewController as? JCMetadataVC {
                            metaDataVC.isUserComingFromPlayerScreen = true
                            self.resetPlayer()
                            self.dismiss(animated: true, completion: {
                                metaDataVC.callWebServiceForMetadata(id: newItem.id ?? "", newAppType: newAppType)
                            })
                        } else if let navVc = self.presentingViewController as? UINavigationController, let tabVc = navVc.viewControllers.first as? JCTabBarController, let homeVc = tabVc.viewControllers?.first as? JCHomeVC {
                            homeVc.isMetadataScreenToBePresentedFromResumeWatchCategory = true
                            self.resetPlayer()
                            self.dismiss(animated: true, completion: {
                                let metaVc = Utility.sharedInstance.prepareMetadata(newItem.id ?? "", appType: .Movie, fromScreen: PLAYER_SCREEN, categoryName: RECOMMENDATION, categoryIndex: 0, tabBarIndex: 0)
                                tabVc.present(metaVc, animated: false, completion: nil)
                            })
                        }
                    }
                    else if newAppType == .Clip || newAppType == .Music || newAppType == .Trailer{
                        changePlayerVC(newItem.id ?? "", itemImageString: (newItem.banner) ?? "", itemTitle: (newItem.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (self.itemDescription), appType: appType, isPlayList: (self.isPlayList) , playListId: (self.playListId), isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: moreArray, fromScreen: PLAYER_SCREEN, fromCategory: RECOMMENDATION, fromCategoryIndex: 0)
                        preparePlayerVC()
                    }
                }
            }
        }
        else if isEpisodeDataAvailable{
            let newItem = episodeArray[indexPath.row]
            if id == newItem.id {
                isRecommendationCollectionViewEnabled = true
                return
            }
            //Send Media-end analytics event
            if isMediaEndAnalyticsEventNotSent {
                isMediaEndAnalyticsEventNotSent = false
                updateResumeWatchList()
                sendMediaEndAnalyticsEvent()
                sendRecommendationEvent(videoName: newItem.name ?? "")
            }
            changePlayerVC(newItem.id ?? "", itemImageString: (newItem.banner) ?? "", itemTitle: (newItem.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (self.itemDescription), appType: appType, isPlayList: (self.isPlayList) , playListId: (self.playListId), isMoreDataAvailable: false, isEpisodeAvailable: true, recommendationArray: episodeArray, fromScreen: PLAYER_SCREEN, fromCategory: RECOMMENDATION, fromCategoryIndex: 0)
            
            preparePlayerVC()
            
        }
    }
 }
 //MARK:- UICOLLECTIONVIEW DATASOURCE
 
 extension JCPlayerVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEpisodeDataAvailable{
            return episodeArray.count
        }
        if isMoreDataAvailable{
            return moreArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell
        var imageUrl    = ""
        if isEpisodeDataAvailable
        {
            let model = episodeArray[indexPath.row]
            cell.nameLabel.text = model.name
            if let bannerUrl = model.banner {
                imageUrl = bannerUrl
            }
            if appType == .Episode {
                isPlayList = true
            }
        }
        else if isMoreDataAvailable{
            let model = moreArray[indexPath.row]
            cell.nameLabel.text = model.name
            if let bannerUrl = model.banner {
                imageUrl = bannerUrl
            }
            
        }
        if indexPath.row == currentPlayingIndex {
            cell.nowPlayingImageView.isHidden = !isPlayList
            
        } else {
            cell.nowPlayingImageView.isHidden = true
        }
        if let urlString = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl) {
            let url = URL(string: urlString)
            cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            });
        }
        return cell
    }
 }
 
 //MARK:- AVAssetResourceLoaderDelegate Methods
 
 extension JCPlayerVC: AVAssetResourceLoaderDelegate, AVPlayerViewControllerDelegate
 {
    //MARK:- Token Encryption Methods
    
    func MD5Hash(string:String) -> String {
        let stringData = string.data(using: .utf8)
        let MD5Data = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = MD5Data.withUnsafeBytes({ MD5Bytes in
            stringData?.withUnsafeBytes({ stringBytes in
                CC_MD5(stringBytes, CC_LONG(stringData?.count ?? 0), UnsafeMutablePointer<UInt8>(mutating: MD5Bytes))
            })
        })
        print("MD5Hex: \(MD5Data.map {String(format: "%02hhx", $0)}.joined())")
        return MD5Data.base64EncodedString()
    }
    
    
    func getJCTKeyValue(with expiryTime:String) -> String
    {
        let jctToken = self.MD5Hash(string: (JCDataStore.sharedDataStore.secretCdnTokenKey ?? "") + self.getSTKeyValue() + expiryTime)
        return filterMD5HashedStringFromSpecialCharacters(md5String:jctToken)
    }
    
    func getSTKeyValue() -> String {
        let stKeyValue = (JCDataStore.sharedDataStore.secretCdnTokenKey ?? "") + JCAppUser.shared.ssoToken
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
        let currentTimeInSeconds: Int = Int(ceil(deviceTime.timeIntervalSince1970)) + (JCDataStore.sharedDataStore.cdnUrlExpiryDuration ?? 0)
        return "\(currentTimeInSeconds)"
    }
    func generateRedirectURL(sourceURL: String)-> URLRequest? {
        if let url = URL(string: sourceURL) {
            let redirect = URLRequest(url: url)
            return redirect
        }
        return nil
    }
    
    func getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest requestBytes: Data, contentIdentifierHost assetStr: String, leaseExpiryDuration expiryDuration: TimeInterval, error errorOut: Error?,completionHandler: @escaping(Data?)->Void)
    {
        let dict: [AnyHashable: Any] = [
            "spc" : requestBytes.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)),
            "id" : "whaterver",
            "leaseExpiryDuration" : Double(expiryDuration)
        ]
        
        var jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        
        guard let url = URL(string: URL_GET_KEY) else {
            return
        }
        let req = NSMutableURLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("\(UInt((jsonData?.count ?? 0)))", forHTTPHeaderField: "Content-Length")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(JCAppUser.shared.ssoToken, forHTTPHeaderField: "ssotoken")
        req.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            //print("error: \(error!)")
            if error != nil {
                return
            }
            if (data != nil), let decodedData = Data(base64Encoded: data!, options: []) {
                completionHandler(decodedData)
            } else {
                completionHandler(data)
            }
        })
        task.resume()
    }
    
    func getAppCertificateData(completionHandler: @escaping (Data?)->Void) {
        guard let url = URL(string: URL_GET_CERT) else {
            return
        }
        let req = NSMutableURLRequest(url: url)
        req.setValue(JCAppUser.shared.ssoToken, forHTTPHeaderField: "ssotoken")
        let session = URLSession.shared
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil {
                return
            }
            
            //print("data: \(data)")
            if (data != nil), let decodedData = Data(base64Encoded: data!, options: []) {
                completionHandler(decodedData)
            } else {
                completionHandler(data)
            }
        })
        task.resume()
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if isFpsUrl {
            let dataRequest: AVAssetResourceLoadingDataRequest? = loadingRequest.dataRequest
            let url: URL? = loadingRequest.request.url
            let error: Error? = nil
           // var handled: Bool = false
            
            // Must be a non-standard URI scheme for AVFoundation to invoke your AVAssetResourceLoader delegate
            // for help in loading it.
            if let urlScheme = url?.scheme, (urlScheme !=  URL_SCHEME_NAME) {
                return false
            }
            
            let assetStr: String = url?.host ?? ""
            var requestBytes: Data?
        
            let assetId = NSData(bytes: assetStr.cString(using: String.Encoding.utf8), length: assetStr.lengthOfBytes(using: String.Encoding.utf8)) as Data
            
            self.getAppCertificateData { (certificate) in
                
                do {
                    requestBytes = try loadingRequest.streamingContentKeyRequestData(forApp: certificate ?? Data(), contentIdentifier: assetId, options: nil)
                    
                    
                    print("Request Bytes is \(String(describing: requestBytes))")
                    //var responseData: Data? = nil
                    let expiryDuration = 0.0
                    
                    
                    self.getContentKeyAndLeaseExpiryfromKeyServerModule(withRequest: requestBytes ?? Data(), contentIdentifierHost: assetStr, leaseExpiryDuration: expiryDuration, error: error, completionHandler: { (responseData) in
                        print("Key  is \(String(describing: responseData))")
                        
                        
                        if let responseData = responseData {
                            dataRequest?.respond(with: responseData)
                            if expiryDuration != 0.0 {
                                let infoRequest: AVAssetResourceLoadingContentInformationRequest? = loadingRequest.contentInformationRequest
                                if (infoRequest != nil) {
                                    infoRequest?.renewalDate = Date(timeIntervalSinceNow: expiryDuration)
                                    infoRequest?.contentType = "application/octet-stream"
                                    infoRequest?.contentLength = Int64(responseData.count)
                                    infoRequest?.isByteRangeAccessSupported = false
                                }
                                
                            }
                            loadingRequest.finishLoading()
                        } else {
                                loadingRequest.finishLoading()
                        }
                        
                        //handled = true;	// Request has been handled regardless of whether server returned an error.
                        // completionHandler(responseData)
                        //  return handled
                    })
                }
                catch {
                    print(error)
                }
            }
            return true
            
        }
        
        var urlString = loadingRequest.request.url?.absoluteString ?? ""
        print(urlString)
        let contentRequest = loadingRequest.contentInformationRequest
        let dataRequest = loadingRequest.dataRequest
        //Check if the it is a content request or data request, we have to check for data request and do the m3u8 file manipulation
        
        if (contentRequest != nil) {
            contentRequest?.isByteRangeAccessSupported = true
        }
        if (dataRequest != nil) {
            //this is data request so processing the url. change the scheme to http
            
            if (urlString.contains("fakeHttp")), (urlString.contains("token")) {
                print(urlString)
                urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
                guard let url = URL(string: urlString) else {
                    return false
                }
                do {
                    let data = try Data(contentsOf: url)
                    dataRequest?.respond(with: data)
                    loadingRequest.finishLoading()
                    
                } catch {
                    return false
                }
                return true
            }
            if (urlString.contains(".m3u8"))
            {
//                if urlString.contains("subtitlelist"){
//                    print("subtitlelist = = \(urlString)")
//                    urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
//                    guard let url = URL(string: urlString) else {
//                        return false
//                    }
//                    do {
//                        let data = try Data(contentsOf: url)
//                        dataRequest?.respond(with: data)
//                        loadingRequest.finishLoading()
//
//                    } catch {
//                        print("error of subtitle = \(error.localizedDescription)")
//                        return false
//                    }
//                }
//                else{
                if urlString.contains("subtitlelist"){
                    print("m3u8 = \(urlString)")
                }
                    let expiryTime:String = self.getExpireTime()
                    urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
                    let punctuation = (urlString.contains(".m3u8?")) ? "&" : "?"
                    let stkeyValue = self.getSTKeyValue()
                    let urlString = urlString + "\(punctuation)jct=\(self.getJCTKeyValue(with: expiryTime))&pxe=\(expiryTime)&st=\(stkeyValue)"
                    guard let url = URL(string: urlString) else {
                        return false
                    }
                    print("printing value of url \(urlString)")
                    do {
                        let data = try Data(contentsOf: url)
                        dataRequest?.respond(with: data)
                        loadingRequest.finishLoading()
                        
                    } catch {
                        print("error of subtitle = \(error.localizedDescription)")
                        return false
                    }
               // }
                
                return true
            }
            if(urlString.contains(".ts")) {
                urlString = urlString.replacingOccurrences(of: "fakeHttp", with: "http")
                if let redirect = self.generateRedirectURL(sourceURL: urlString), let url = URL(string: urlString) {
                    //Step 9 and 10:-
                    loadingRequest.redirect = redirect
                    let response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
                    loadingRequest.response = response
                    loadingRequest.finishLoading()
                    return true
                }
                return false
            }
            return false
        }
        return true
    }
    
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool
    {
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        if appType == .Movie || appType == .Episode {
            return self.resourceLoader(resourceLoader, shouldWaitForLoadingOfRequestedResource: renewalRequest)
        }
        return true
    }
    
    //MARK:- Player Controller Delegate methods
    func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        let lapseTime = CMTimeGetSeconds(targetTime) - CMTimeGetSeconds(oldTime)
        videoViewingLapsedTime = videoViewingLapsedTime + lapseTime
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willTransitionToVisibilityOfTransportBar visible: Bool, with coordinator: AVPlayerViewControllerAnimationCoordinator) {
        if visible, !isRecommendationViewVisible {
            recommendationViewchangeTo(1.0, visibility: false, animationDuration: 0)
            recommendationViewchangeTo(0.0, visibility: false, animationDuration: 4.0)
        }
    }
    func playerViewController(_ playerViewController: AVPlayerViewController, didPresent interstitial: AVInterstitialTimeRange) {
        print("Gotit")
    }
 }
 
 
 //AVPlayerItem extension for subtitle and audio setting
 extension AVPlayerItem {
    enum TrackType {
        case subtitle
        case audio
        /**                 Return valid AVMediaSelectionGroup is item is available.                 */
        
        fileprivate func characteristic(item:AVPlayerItem) -> AVMediaSelectionGroup? {
            let str = self == .subtitle ? AVMediaCharacteristic.legible : AVMediaCharacteristic.audible
            if item.asset.availableMediaCharacteristicsWithMediaSelectionOptions.contains(str) {
                return item.asset.mediaSelectionGroup(forMediaCharacteristic: str)
                
            }
            return nil
        }
        
    }
    func tracks(type:TrackType) -> [String] {
        if let characteristic = type.characteristic(item: self) {
            return characteristic.options.map { $0.displayName}
        }
        return [String]()
    }
    func selected(type:TrackType) -> String? {
        guard let group = type.characteristic(item: self) else {
            return nil
        }
        let selected = self.selectedMediaOption(in: group)
        return selected?.displayName
    }
    func select(type:TrackType, name:String) -> Bool {
        guard let group = type.characteristic(item: self) else {
            return false
        }
        guard let matched = group.options.filter({ $0.displayName == name }).first else{
            return false
        }
        self.select(matched, in: group)
        return true
    }
 }
 
 extension JCPlayerVC: EnterPinViewModelDelegate {
    func doParentalCheck(with url: String, isFps: Bool) {
        let ageGroup = playbackRightsData?.maturityAgeGrp ?? .allAge
        if ParentalPinManager.shared.checkParentalPin(ageGroup) {
            //Present ParentalPinView
            isSwipingAllowed_RecommendationView = false
            enterParentalPinView = Utility.getXib(EnterParentalPinViewIdentifier, type: EnterParentalPinView.self, owner: self)
            enterPinViewModel = EnterPinViewModel(contentName: playbackRightsData?.contentName ?? "", delegate: self)
            enterParentalPinView?.delegate = enterPinViewModel
            enterParentalPinView?.contentTitle.text = self.enterPinViewModel?.contentName
            enterParentalPinView?.frame = self.view.frame
            self.view.addSubview(enterParentalPinView!)
            myPreferredFocusView = enterParentalPinView
            self.updateFocusIfNeeded()
            self.setNeedsFocusUpdate()
        } else {
            intantiatePlayerAfterParentalCheck(with: url, isFps: isFps)
        }
    }
    
    func pinVerification(_ isSucceed: Bool) {
        if isSucceed {
            isSwipingAllowed_RecommendationView = true
            enterPinViewModel = nil
            enterParentalPinView?.removeFromSuperview()
            enterParentalPinView = nil
            if let fpsUrl = self.playbackRightsData?.url {
                intantiatePlayerAfterParentalCheck(with: fpsUrl, isFps: true)
            } else if let aesUrl = self.playbackRightsData?.aesUrl {
                intantiatePlayerAfterParentalCheck(with: aesUrl, isFps: false)
            }
        }
    }
 }

 
 
 
 
 
 
 
 
 
 
