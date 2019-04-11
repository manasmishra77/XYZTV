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
    func getDuration(duration: Double)
    
    func changePlayingUrlAsPerBitcode()
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
    fileprivate var isFpsUrl = false
    var moreArray: [Item]?
    var episodeArray: [Episode]?
    var isPlayList: Bool = false
    var totalDuration: Float = 0.0
    var appType: VideoType = VideoType.None
    weak var delegate: PlayerViewModelDelegate?
    var startTime_BufferDuration: Date?
    fileprivate var totalBufferDurationTime = 0.0
    fileprivate var bufferCount = 0
    var isItemToBeAddedInResumeWatchList = true
    fileprivate var isRecommendationCollectionViewEnabled = false
    fileprivate var isVideoUrlFailedOnce = false
    var playbackRightsModel: PlaybackRightsModel?
    fileprivate var episodeNumber :Int? = nil
    
    var isMoreDataAvailable: Bool = false
    var isEpisodeDataAvailable: Bool = false
    var bannerUrlString: String = ""
    var assetManager: PlayerAssetManager?
    var playerActiveUrl: String!
    var playerActiveBitrate: BitRatesType?
    
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
//                self.playbackRightsModel?.fps = nil
            self.decideURLPriorityForPlayer()
            
            if self.playbackRightsModel?.url != nil || self.playbackRightsModel?.fps != nil {
                self.isFpsUrl = true
            }
            self.delegate?.checkParentalControlFor(playbackRightModel: self.playbackRightsModel!)
        }
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
    

    
    func updateResumeWatchList() {
        //vinit_edited
    }
    
    func sendMediaStartAnalyticsEvent() {
        
    }
    
    func sendBufferingEvent() {
        
    }
    
    //MARK:- Play Video
    func playVideoWithPlayerItem() {
        //  self.addMetadataToPlayer()
        self.autoPlaySubtitle(IsAutoSubtitleOn)

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

