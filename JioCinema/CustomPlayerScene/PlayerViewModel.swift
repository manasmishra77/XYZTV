//
//  PlayerViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/28/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import AVKit

protocol PlayerViewModelDelegate: NSObjectProtocol {
    func addAvPlayerToController()
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel)
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String)
    func reloadMoreLikeCollectionView(i: Int)
    func prepareAndAddSubviewsOnPlayer()
    func changePlayingUrlAsPerBitcode()
    func addResumeWatchView()
}

enum BitRatesType: String {
    case auto = "Auto"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

class PlayerViewModel: NSObject {
    fileprivate var itemToBePlayed: Item
    var playerItem: AVPlayerItem?
    var moreArray: [Item]?
    var episodeArray: [Episode]?
    var totalDuration: Float = 0.0
    var appType: VideoType = VideoType.None
    weak var delegate: PlayerViewModelDelegate?
    var startTime_BufferDuration: Date?
    fileprivate var totalBufferDurationTime = 0.0
    fileprivate var bufferCount = 0
    var playListId: String = ""


    var playbackRightsModel: PlaybackRightsModel?
    fileprivate var episodeNumber :Int? = nil
    var currentDuration: Float = 0.0

    fileprivate var isFpsUrl = false
    var isPlayList: Bool = false
    fileprivate var isRecommendationCollectionViewEnabled = false
    fileprivate var isVideoUrlFailedOnce = false
    var isItemToBeAddedInResumeWatchList = true
    var isPlayListFirstItemToBePlayed: Bool = false
    var isMoreDataAvailable: Bool = false
    var isEpisodeDataAvailable: Bool = false
    var isDisney: Bool = false
    
    var bannerUrlString: String = ""
    var assetManager: PlayerAssetManager?
    var playerActiveUrl: String!
    var playerActiveBitrate: BitRatesType?
    
    init(item: Item) {
        self.itemToBePlayed = item
        super.init()
        self.setVideoType(item: item)
        //callWebServiceForPlaybackRights(id: item.id!)
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
    func updateResumeWatchList() {
        if let currentTime = playerItem?.currentTime(), let totalTime = playerItem?.duration, (totalTime.timescale != 0), (currentTime.timescale != 0) {
            let currentTimeDuration = "\(Int(CMTimeGetSeconds(currentTime)))"
            let timeDifference = CMTimeGetSeconds(currentTime)
            let totalDuration = "\(Int(CMTimeGetSeconds(totalTime)))"
            let totalDurationFloat = Double(totalDuration.floatValue() ?? 0)
            
            if (timeDifference < 300) || (timeDifference > (totalDurationFloat - 60)) {
                self.callWebServiceForRemovingResumedWatchlist()
            } else {
                let audio = self.playerItem?.selected(type: .audio) ?? ""
                self.callWebServiceForAddToResumeWatchlist(itemToBePlayed.id ?? "", currentTimeDuration: currentTimeDuration, totalDuration: totalDuration, selectedAudio: audio)
            }
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
//                self.playbackRightsModel?.fps = nil
            self.decideURLPriorityForPlayer()
            
            if self.playbackRightsModel?.url != nil || self.playbackRightsModel?.fps != nil {
                self.isFpsUrl = true
            }
            self.delegate?.checkParentalControlFor(playbackRightModel: self.playbackRightsModel!)
        }
    }
    
    func callWebServiceForRemovingResumedWatchlist() {
        guard let id = itemToBePlayed.id else{
            return
        }
        let json = ["id": id]
        let header = isDisney ? RJILApiManager.RequestHeaderType.disneyCommon : RJILApiManager.RequestHeaderType.baseCommon
        let params = ["uniqueId": JCAppUser.shared.unique, "listId": isDisney ? "30" : "10", "json": json] as [String : Any]
        let url = removeFromResumeWatchlistUrl
        RJILApiManager.getReponse(path: url, headerType: header, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: NoModel.self) { [weak self] (response) in
            guard let self = self else {return}
            guard response.isSuccess else {
                return
            }
            if self.isDisney {
                NotificationCenter.default.post(name: AppNotification.reloadResumeWatchForDisney, object: nil)
            }
            else {
                NotificationCenter.default.post(name: AppNotification.reloadResumeWatch, object: nil, userInfo: nil)
            }
        }
        /*
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
         }*/
    }
    
    func callWebServiceForAddToResumeWatchlist(_ itemId: String, currentTimeDuration: String, totalDuration: String, selectedAudio: String)
    {
        let url = addToResumeWatchlistUrl
        
        let id = itemId
        
        let lang: String = selectedAudio.lowercased()
        var json: Dictionary<String, Any> = ["id": id, "duration": currentTimeDuration, "totalDuration": totalDuration]
        
        if let audioLanguage: AudioLanguage = AudioLanguage(rawValue: lang) {
            let languageIndexDict: Dictionary<String, Any> = ["name": audioLanguage.name, "code": audioLanguage.code, "index":playbackRightsModel?.languageIndex?.index ?? 0]
            json["languageIndex"] = languageIndexDict
        }
        
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = JCAppUser.shared.unique
        params["listId"] = isDisney ? "30" : "10"
        params["json"] = json
        params["id"] = id
        params["duration"] = currentTimeDuration
        params["totalDuration"] = totalDuration
        
        let header = isDisney ? RJILApiManager.RequestHeaderType.disneyCommon : RJILApiManager.RequestHeaderType.baseCommon
        
//        weak var weakSelf = self.presentingViewController
        var isDisney = self.isDisney
        RJILApiManager.getReponse(path: url, headerType: header, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: NoModel.self) {[weak self] (response) in
            guard response.isSuccess else {
                return
            }
            
            if isDisney {
                NotificationCenter.default.post(name: AppNotification.reloadResumeWatchForDisney, object: nil)
            } else {
                NotificationCenter.default.post(name: AppNotification.reloadResumeWatch, object: nil, userInfo: nil)
            }
        }
        /*
         
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
         }*/
    }
    
    func decideURLPriorityForPlayer() {
         if let fpsUrl = self.playbackRightsModel?.url {
            playerActiveUrl = fpsUrl
        } else if let aesUrl = self.playbackRightsModel?.aesUrl {
            playerActiveUrl = aesUrl
        } else if let fpsBitcodeUrl = self.playbackRightsModel?.fps {
            playerActiveBitrate = .auto
            playerActiveUrl = fpsBitcodeUrl.auto
        } else if let aesBitcodeUrl = self.playbackRightsModel?.aes {
            playerActiveBitrate = .auto
            playerActiveUrl = aesBitcodeUrl.auto
        }
    }
    
    func callWebServiceForPlayListData(id: String) {
        //vinit_commented
    }
    
    func instantiatePlayerAfterParentalCheck() {
        assetManager = nil
        assetManager = PlayerAssetManager(playBackModel: playbackRightsModel!, isFps: self.isFpsUrl, listener: self, activeUrl: self.playerActiveUrl)
    }
    
    //MARK:- Add Player Observer
    
//
//    
//    func updateResumeWatchList() {
//        //vinit_edited
//    }
    
    func sendMediaStartAnalyticsEvent() {
        
    }
    
    func sendBufferingEvent() {
        
    }
    
    func preparePlayer() {
//        isMediaEndAnalyticsEventNotSent = true
        isRecommendationCollectionViewEnabled = false
//        isMediaStartEventSent = false
        
        // audioLanguage = checkItemAudioLanguage(id)
//        setRecommendationConstarints(appType)
        guard let id = itemToBePlayed.id else {
            return
        }
        switch appType {
        case .Movie:
            if isPlayList, id == ""{
                self.isPlayListFirstItemToBePlayed = true
                callWebServiceForPlayListData(id: playListId)
                delegate?.prepareAndAddSubviewsOnPlayer()
            } else {
                currentDuration = checkInResumeWatchListForDuration(id)
                if currentDuration > 0 {
                    delegate?.addResumeWatchView()
                } else {
                    delegate?.prepareAndAddSubviewsOnPlayer()
                    callWebServiceForPlaybackRights(id: id)
                }
            }
        case .Episode, .TVShow:
            currentDuration = checkInResumeWatchListForDuration(id)
            if currentDuration > 0 {
                delegate?.addResumeWatchView()
//                player?.pause()
//                self.view.bringSubviewToFront(self.resumeWatchView)
            } else {
                delegate?.prepareAndAddSubviewsOnPlayer()
                callWebServiceForPlaybackRights(id: id)
            }
        case .Music, .Clip, .Trailer:
            if isPlayList, id == "" {
                self.isPlayListFirstItemToBePlayed = true
                callWebServiceForPlayListData(id: playListId)
                delegate?.prepareAndAddSubviewsOnPlayer()
            } else {
                delegate?.prepareAndAddSubviewsOnPlayer()
                callWebServiceForPlaybackRights(id: id)
            }
        default:
            break
        }
    }
    //Check in resume watchlist
    
    func checkInResumeWatchListForDuration(_ itemIdToBeChecked: String) -> Float {
        let itemMatched = self.checkInResumeWatchList(itemIdToBeChecked)
        if let drn = itemMatched?.duration {
            return Float(drn)
        }
        return 0.0
    }
    
    //Check in resume watchlist
    func checkInResumeWatchList(_ itemIdToBeChecked: String) -> Item? {
        if isDisney {
            if let resumeWatchListArray = JCDataStore.sharedDataStore.disneyResumeWatchList?.data?[0].items {
                let itemMatched = resumeWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
                return itemMatched
            }
        } else {
            if let resumeWatchListArray = JCDataStore.sharedDataStore.resumeWatchList?.data?[0].items {
                let itemMatched = resumeWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
                return itemMatched
            }
        }
        return nil
    }
    

    
    //MARK:- Play Video
    func playVideoWithPlayerItem() {
        //  self.addMetadataToPlayer()
//        if let player = player {
//            player.replaceCurrentItem(with: playerItem)
//        } else {
//            resetPlayer()
//            player = AVPlayer(playerItem: playerItem)
//            player?.play()
//        }
        delegate?.addAvPlayerToController()
        //        handleForPlayerReference()
    }
    
    private func autoPlaySubtitle(_ isAutoPlaySubtitle: Bool) {
        /*
         let subtitles = player?.currentItem?.tracks(type: .subtitle)
         // Select track with displayName
         guard (subtitles?.count ?? 0) > 0 else {return}
         _ = player?.currentItem?.select(type: .subtitle, name: (subtitles?.first)!)
         *///vinit_commented
    }
    
    func handleForPlayerReference() {
        
    }
    
    
    func updatePlayerBufferCount() {
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
    
    func handlePlayerStatusFailed() {
        Log.DLog(message: "Failed" as AnyObject)
        var failureType = "FPS"
        if !isVideoUrlFailedOnce, let _ = self.playbackRightsModel?.url {
            isVideoUrlFailedOnce = true
            failureType = "FPS"
            isFpsUrl = false
            assetManager?.handleAESStreamingUrl(videoUrl: self.playbackRightsModel?.aesUrl ?? "")
        } else {
            //AES url failed
            failureType = "AES"
            let alert = UIAlertController(title: "Unable to process your request right now", message: "", preferredStyle: UIAlertController.Style.alert)
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
        
    }
    
    func changePlayerBitrateTye(bitrateQuality: BitRatesType) {
        var bitcode: Bitcode?
        if isFpsUrl == true {
            bitcode = playbackRightsModel?.fps
        }
        else {
            bitcode = playbackRightsModel?.aes
        }
        
        if let bitcode = bitcode {
            switch bitrateQuality {
            case .auto:
                playerActiveUrl = bitcode.auto
                break
            case .low:
                playerActiveUrl = bitcode.low
                break
            case .medium:
                playerActiveUrl = bitcode.medium
                break
            case .high:
                playerActiveUrl = bitcode.high
                break
            }

            //           delegate?.changePlayingUrlAsPerBitcode()
//            self.instantiatePlayerAfterParentalCheck()
        }
    }
    
//    func changePlayerSubtitleLanguageAndAudioLanguage(subtitleLang: String?, audioLang: String?) {
//        var playerLang = self.playerItem?.asset.accessibilityLanguage
//
//        if let subtitle = subtitleLang {
//
//        }
//        if let audio = audioLang {
//
//        }
        
//    }
    
    
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
                    let pngData = img.pngData()
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

