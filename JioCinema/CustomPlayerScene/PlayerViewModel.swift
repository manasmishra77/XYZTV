//
//  PlayerViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/28/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import AVKit

private var playerViewControllerKVOContext = 0
protocol PlayerViewModelDelegate {
    func addAvPlayerControllerToController()
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel)
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String)
    func reloadMoreLikeCollectionView(i: Int)
    func currentTimevalueChanged(newTime : Double, duration: Double)
    func getDuration(duration: Double)
}
class PlayerViewModel: NSObject {
    
    fileprivate var itemToBePlayed: Item
    @objc var player: AVPlayer?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var didSeek :Bool = false
    fileprivate var isFpsUrl = false
    fileprivate var playerTimeObserverToken: Any?
    var moreArray: [Item]?
    var episodeArray: [Episode]?
    
    var isPlayList: Bool = false
    var totalDuration: Float = 0.0
    var currentDuration: Float = 0.0
    var appType: VideoType = VideoType.None
    var delegate: PlayerViewModelDelegate?
    fileprivate var startTime_BufferDuration: Date?
    fileprivate var totalBufferDurationTime = 0.0
    fileprivate var bufferCount = 0
    fileprivate var videoStartingTime = Date()
    fileprivate var videoStartingTimeDuration = 0
    fileprivate var isItemToBeAddedInResumeWatchList = true
    fileprivate var isRecommendationCollectionViewEnabled = false
    fileprivate var isVideoUrlFailedOnce = false
    fileprivate var playbackRightsModel: PlaybackRightsModel?
    fileprivate var episodeNumber :Int? = nil
    
    var isMoreDataAvailable: Bool = false
    var isEpisodeDataAvailable: Bool = false
    var bannerUrlString: String = ""
    
    init(item: Item) {
        self.itemToBePlayed = item
        super.init()
        self.setVideoType(item: item)
        callWebServiceForPlaybackRights(id: item.id!)
        updateValues(item: item)
    }
    func updateValues(item: Item){
        appType = item.appType
        
    }
    
    func setVideoType(item: Item) {
        if let appTypeInt = item.app?.type {
            appType = VideoType(rawValue: appTypeInt)!
        }
    }
    
    func callWebServiceForMoreLikeData() {
        let url = metadataUrl.appending(itemToBePlayed.id ?? "")
        RJILApiManager.getReponse(path: url, params: nil, postType: .GET, paramEncoding: .URL, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: MetadataModel.self) {[weak self] (response) in
            guard let self = self else {return}
            guard response.isSuccess else {
                return
            }
            var i = 0
            if let recommendationItems = response.model?.more {
                self.isMoreDataAvailable = false
                self.moreArray?.removeAll()
                if recommendationItems.count > 0 {
                    self.isMoreDataAvailable = true
                    self.moreArray = recommendationItems
                }
            } else if let episodes = response.model?.episodes {
                self.isEpisodeDataAvailable = false
                
                self.episodeArray?.removeAll()
                if episodes.count > 0{
                    self.episodeArray?.removeAll()
                    if episodes.count > 0{
                        self.isEpisodeDataAvailable = true
                        for each in episodes{
                            if each.id == self.itemToBePlayed.id {
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
                if (self.isMoreDataAvailable) || (self.isEpisodeDataAvailable){
                DispatchQueue.main.async {
                    self.delegate?.reloadMoreLikeCollectionView(i: i)
                }
                }
        }
    }
    
    func callWebServiceForPlaybackRights(id: String) {
        RJILApiManager.getPlaybackRightsModel(contentId: id) {[unowned self](response) in
            Utility.sharedInstance.hideIndicator()
            guard response.isSuccess else {
                //vinit_commented sendplaybackfailureevent
                self.delegate?.handlePlaybackRightDataError(errorCode: response.code!, errorMsg: response.errorMsg!)
                return
            }
            self.playbackRightsModel = response.model
            
            DispatchQueue.main.async {
                if(self.player != nil) {
                    self.player?.pause()
                    self.resetPlayer()
                }
                self.playbackRightsModel?.url = nil
                self.isFpsUrl = self.playbackRightsModel?.url != nil ? true : false
                self.delegate?.checkParentalControlFor(playbackRightModel: self.playbackRightsModel!)
            }
        }
    }
    
    func callWebServiceForPlayListData(id: String) {
        //vinit_commented
    }
    
    func instantiatePlayerAfterParentalCheck() {
        player = nil
        didSeek = true
        _ = PlayerAssetManager(playBackModel: playbackRightsModel!, isFps: self.isFpsUrl, listener: self)
    }
    
    //MARK:- AVPlayerViewController Methods
    func resetPlayer() {
        if let player = player {
            player.pause()
            self.removePlayerObserver()
            //            self.playerController = nil
        }
    }
    
    //MARK:- Add Player Observer
    func addPlayerNotificationObserver () {
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        addObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.isPlaybackLikelyToKeepUp), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    //MARK:- Remove Player Observer
    func removePlayerObserver() {
        //sendMediaEndAnalyticsEvent()
        //        if (appType == .Movie || appType == .Episode), isItemToBeAddedInResumeWatchList {
        updateResumeWatchList()
        //        } //vinit_commented
        if let timeObserverToken = playerTimeObserverToken {
            self.player?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        removeObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.duration), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.rate), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.status), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.isPlaybackBufferEmpty), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(PlayerViewModel.player.currentItem.isPlaybackLikelyToKeepUp), context: &playerViewControllerKVOContext)
        self.playerTimeObserverToken = nil
        self.player = nil
    }
    
    func updateResumeWatchList() {
        //vinit_edited
    }
    
    //MARK:- AVPlayer Finish Playing Item
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey), isPlayList {
            //handle play list
        } else {
            //dismiss Player
        }
        //vinit_commented
    }
    
    func sendMediaStartAnalyticsEvent() {
        
    }
    
    func sendBufferingEvent() {
        
    }
    
    //MARK:- Play Video
    func playVideoWithPlayerItem() {
        //  self.addMetadataToPlayer()
        self.autoPlaySubtitle(IsAutoSubtitleOn)
        //        if playerController == nil {
        //            playerController = AVPlayerViewController()
        //            playerController?.delegate = self as? AVPlayerViewControllerDelegate
        //            if let player = player, let timeScale = player.currentItem?.asset.duration.timescale {
        //                player.seek(to: CMTimeMakeWithSeconds(Float64(currentDuration), timeScale))
        //            }
        //        }
        if let player = player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            resetPlayer()
            player = AVPlayer(playerItem: playerItem)
        }

        delegate?.addAvPlayerControllerToController()
        //        handleForPlayerReference()
    }
    
    private func autoPlaySubtitle(_ isAutoPlaySubtitle: Bool) {
        guard isAutoPlaySubtitle else {return}
        /*
         let subtitles = player?.currentItem?.tracks(type: .subtitle)
         // Select track with displayName
         guard (subtitles?.count ?? 0) > 0 else {return}
         _ = player?.currentItem?.select(type: .subtitle, name: (subtitles?.first)!)
         *///vinit_commented
    }
    
    func handleForPlayerReference() {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard self.player != nil else {
            return
        }
        
        if keyPath == #keyPath(PlayerViewModel.player.currentItem.duration) {
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
        else if keyPath == #keyPath(PlayerViewModel.player.rate) {
            let newRate = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.doubleValue ?? 0
            
            if newRate == 0
            {
                //vinit_commented swipeDownRecommendationView()
            }
        }
        else if keyPath == #keyPath(PlayerViewModel.player.currentItem.isPlaybackBufferEmpty)
        {
            startTime_BufferDuration = Date()
        }
        else if keyPath == #keyPath(PlayerViewModel.player.currentItem.isPlaybackLikelyToKeepUp)
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
        else if keyPath == #keyPath(PlayerViewModel.player.currentItem.status) {
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
                break
            case .failed:
                Log.DLog(message: "Failed" as AnyObject)
                self.isRecommendationCollectionViewEnabled = false
                var failureType = "FPS"
                //If video failed once and valid fps url is there
                if !isVideoUrlFailedOnce, let _ = self.playbackRightsModel?.url {
                    isVideoUrlFailedOnce = true
                    failureType = "FPS"
                    isFpsUrl = false
                    //vinit_commented                    self.handleAESStreamingUrl(videoUrl: self.playbackRightsModel?.aesUrl ?? "")
                } else {
                    //AES url failed
                    failureType = "AES"
                    let alert = UIAlertController(title: "Unable to process your request right now", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                        DispatchQueue.main.async {
                            print("dismiss")
                            //vinit_commented                            self.dismissPlayerVC()
                        }
                    }
                    alert.addAction(cancelAction)
                    DispatchQueue.main.async {
                        //vinit_commented                        self.present(alert, animated: false, completion: nil)
                    }
                }
                /*
                 let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: playerItem?.error?.localizedDescription), "Type": appType.name, "Title": itemTitle, "Content ID": id, "Bitrate": bitrate, "Episode": itemDescription, "Platform": "TVOS", "Failure": failureType] as [String : Any]
                 let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: failureType, errorCode: "-1", videoType: appType.name, contentTitle: itemTitle, contentId: id, videoQuality: "Auto", bitrate: bitrate, episodeSubtitle: itemDescription, playerErrorMessage: String(describing: playerItem?.error?.localizedDescription), apiFailureCode: "", message: "", fpsFailure: "")
                 
                 sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
             */ //vinit_commented
            default:
                print("unknown")
            }
            
        }
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
                    self?.delegate?.currentTimevalueChanged(newTime: currentPlayerTime, duration: self?.getPlayerDuration() ?? 0)
                    self?.delegate?.getDuration(duration: self?.getPlayerDuration() ?? 0)
                    let remainingTime = (self?.getPlayerDuration())! - currentPlayerTime
                    
                    if remainingTime <= 5
                    {
                        //vinit_commented //show next item to play code
                    }
                } else {
                    self?.playerTimeObserverToken = nil
                }
        }
    }
    
    func getPlayerDuration() -> Double {
        guard let currentItem = self.player?.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    //Seek player
    func seekPlayer() {
        if Double(currentDuration) >= ((self.player?.currentItem?.currentTime().seconds) ?? 0.0), didSeek{
            self.player?.seek(to: CMTimeMakeWithSeconds(Float64(currentDuration), 1))
        } else {
            didSeek = false
        }
    }
    
}

extension PlayerViewController: AVPlayerViewControllerDelegate {
    //MARK:- Player Controller Delegate methods
    func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        let lapseTime = CMTimeGetSeconds(targetTime) - CMTimeGetSeconds(oldTime)
        //vinit_commented       videoViewingLapsedTime = videoViewingLapsedTime + lapseTime
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willTransitionToVisibilityOfTransportBar visible: Bool, with coordinator: AVPlayerViewControllerAnimationCoordinator) {
        /*
         if visible, !isRecommendationViewVisible {
         recommendationViewchangeTo(1.0, visibility: false, animationDuration: 0)
         recommendationViewchangeTo(0.0, visibility: false, animationDuration: 4.0)
         }
         */ //vinit_commented
    }
}


extension PlayerViewModel: PlayerAssetManagerDelegate {
    func setAVAssetInPlayerItem(asset: AVURLAsset) {
        playerItem = AVPlayerItem(asset: asset)
        self.playVideoWithPlayerItem()
    }
}

extension PlayerViewModel {
    func addMetadataToPlayer() {
        let titleMetadataItem = AVMutableMetadataItem()
        titleMetadataItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
        titleMetadataItem.extendedLanguageTag = "und"
        titleMetadataItem.locale = NSLocale.current
        titleMetadataItem.key = AVMetadataKey.commonKeyTitle as NSCopying & NSObjectProtocol
        titleMetadataItem.keySpace = AVMetadataKeySpace.common
        let itemName = itemToBePlayed.name ?? ""
        titleMetadataItem.value = itemName as NSCopying & NSObjectProtocol
        
        
        let descriptionMetadataItem = AVMutableMetadataItem()
        descriptionMetadataItem.identifier = AVMetadataIdentifier.commonIdentifierDescription
        descriptionMetadataItem.extendedLanguageTag = "und"
        descriptionMetadataItem.locale = NSLocale.current
        descriptionMetadataItem.key = AVMetadataKey.commonKeyDescription as NSCopying & NSObjectProtocol
        descriptionMetadataItem.keySpace = AVMetadataKeySpace.common
        let itemDescription = itemToBePlayed.description ?? ""
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

