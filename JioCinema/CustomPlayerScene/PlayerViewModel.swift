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
    func reloadMoreLikeCollectionView(currentMorelikeIndex: Int)
    func addSubviewOnPlayer()
    func addResumeWatchView()
    func updateIndicatorState(toStart: Bool)
    func dismissPlayerOnAesFailure()
    func checkTimeToShowSkipButton(isValidTime: Bool, starttime: Double, endTime: Double)
    func setThumbnailsValue()
    func dismissPlayer()
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
    var recommendationArray: Any = false
//    var moreArray: [Item]?
//    var episodeArray: [Episode]?
    var totalDuration: Float = 0.0
    var appType: VideoType = VideoType.None
    weak var delegate: PlayerViewModelDelegate?
    var startTime_BufferDuration: Date?
    fileprivate var totalBufferDurationTime = 0.0
    fileprivate var bufferCount = 0
    var playListId: String = ""
    var videoViewedTimer: Timer?
    var thumbImageArray : [ThumbnailsModel]?
    
    var isItValideTimeToShowSkipButton: Bool = false
    
    var playbackRightsModel: PlaybackRightsModel?
    fileprivate var episodeNumber :Int? = nil
    var currentDuration: Float = 0.0
    var currentPlayerTimeInSeconds: Double = 0.0
    
    fileprivate var videoViewingLapsedTime = 0.0
    fileprivate var isFpsUrl = false
    var isPlayList: Bool = false
    //    fileprivate var isRecommendationCollectionViewEnabled = false
    fileprivate var isVideoUrlFailedOnce = false
    var isItemToBeAddedInResumeWatchList = true
    //    var isPlayListFirstItemToBePlayed: Bool = false
    //    var isMoreDataAvailable: Bool = false
    //    var isEpisodeDataAvailable: Bool = false
    var isDisney: Bool = false
    
    var bannerUrlString: String = ""
    var assetManager: PlayerAssetManager?
    var playerActiveUrl: String!
    var playerActiveBitrate: BitRatesType?
    var latestEpisodeId: String?
    
    //for analytics
    var fromScreen = ""
    var fromCategory = ""
    var fromCategoryIndex = 0
    var fromLanguage = ""
    var itemLanguage = ""
    var director = ""
    var starCast = ""
    var isAudioChanged: Bool = false
    var isMediaStartEventSent: Bool = false
    var isMediaEndAnalyticsEventSent: Bool = false
    var videoStartingTimeDuration = 0
    var videoStartingTime = Date()
    var vendor : String {
        return self.playbackRightsModel?.vendor ?? ""
    }
    
    var itemId: String{
        if itemToBePlayed.id == "" && isPlayList{
            return itemToBePlayed.latestId ?? ""
        } else {
            return itemToBePlayed.id ?? ""
        }
    }
    
    var itemTitle: String {
        if itemToBePlayed.name == "" || itemToBePlayed.name == nil {
            return itemToBePlayed.showname ?? ""
        } else {
            return itemToBePlayed.name ?? ""
        }
    }
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
    
    init(item: Item, latestEpisodeId: String? = nil) {
        self.itemToBePlayed = item
        self.latestEpisodeId = latestEpisodeId
        super.init()
        self.setVideoType(item: item)
        updateValues(item: item)
        isPlayList = itemToBePlayed.isPlaylist ?? false
    }
    
    func updateValues(item: Item){
        appType = item.appType
    }
    
    func setVideoType(item: Item) {
        if let appTypeInt = item.app?.type {
            appType = VideoType(rawValue: appTypeInt)!
        }
    }
    func updateResumeWatchList(audioLanguage: String) {
        if let currentTime = playerItem?.currentTime(), let totalTime = playerItem?.duration, (totalTime.timescale != 0), (currentTime.timescale != 0) {
            let currentTimeDuration = "\(Int(CMTimeGetSeconds(currentTime)))"
            let timeDifference = CMTimeGetSeconds(currentTime)
            let totalDuration = "\(Int(CMTimeGetSeconds(totalTime)))"
            let totalDurationFloat = Double(totalDuration.floatValue() ?? 0)
            
            if (timeDifference < 300) || (timeDifference > (totalDurationFloat - 60)) {
                self.callWebServiceForRemovingResumedWatchlist()
            } else {
                //                let audio = self.playerItem?.selected(type: .audio) ?? ""
                self.callWebServiceForAddToResumeWatchlist(itemToBePlayed.latestId ?? itemToBePlayed.id ?? "", currentTimeDuration: currentTimeDuration, totalDuration: totalDuration, selectedAudio: audioLanguage)
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
            var currentPlayingIndex = 0
            if response.model?.more != nil || response.model?.episodes != nil{
                self.recommendationArray = false
                self.recommendationArray = response.model?.more ?? response.model?.episodes ?? false
            }
//            if let recommendationItems = response.model?.more {
////                self.moreArray?.removeAll()
//                self.recommendationArray = false
//                if recommendationItems.count > 0 {
////                    self.moreArray = recommendationItems
//                    self.recommendationArray = recommendationItems
//                }
//            } else if let episodes = response.model?.episodes {
////                self.episodeArray?.removeAll()
//
//                    if episodes.count > 0{
//                        for (index, each) in episodes.enumerated() {
//                            if each.id == self.itemToBePlayed.id {
//                                currentPlayingIndex = index
//                                break
//                            }
//                        }
//                        self.recommendationArray = episodes
////                        self.episodeArray = episodes
//                    }
//            }
//            if (self.moreArray?.count ?? 0 > 0) || (self.episodeArray?.count ?? 0 > 0){
//                DispatchQueue.main.async {
//                    self.delegate?.reloadMoreLikeCollectionView(currentMorelikeIndex: currentPlayingIndex)
//                }
//            }
            if ((self.recommendationArray as? [Item]) != nil) || ((self.recommendationArray as? [Episode]) != nil){
                if let episodes = response.model?.episodes {
                    if episodes.count > 0{
                        for (index, each) in episodes.enumerated() {
                            if each.id == self.itemToBePlayed.id {
                                currentPlayingIndex = index
                                break
                            }
                        }
                    }
                }

                self.delegate?.reloadMoreLikeCollectionView(currentMorelikeIndex: currentPlayingIndex)
            }
        }
    }
    
    func callWebServiceForPlaybackRights(id: String) {
        delegate?.updateIndicatorState(toStart: true)
        print("indicator stared on play back right call")
        var contentId = id
        if let latestEpisodeId = self.latestEpisodeId {
            contentId = latestEpisodeId
        }
        RJILApiManager.getPlaybackRightsModel(contentId: contentId) {[weak self](response) in
            guard let self = self else {
                return
            }
            guard response.isSuccess else {
                //vinit_commented sendplaybackfailureevent
                self.delegate?.handlePlaybackRightDataError(errorCode: response.code!, errorMsg: response.errorMsg!)
                let failuretype = "Playbackrights failed"
                var itemId = self.itemToBePlayed.id
                if itemId == "" && self.isPlayList {
                    itemId = self.itemToBePlayed.latestId
                }
                let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: response.errorMsg ?? ""), "Type": self.appType.name, "Title": self.itemToBePlayed.name ?? "", "Content ID": itemId ?? "", "Bitrate": "0", "Episode": self.itemToBePlayed.description ?? "", "Platform": "TVOS", "Failure": failuretype] as [String : Any]
                let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: String(describing: response.errorMsg ?? ""), errorCode: "-1", videoType: self.appType.name, contentTitle: self.itemToBePlayed.name ?? "", contentId: itemId ?? "", videoQuality: "Auto", bitrate: "0", episodeSubtitle: self.itemToBePlayed.description ?? ""   , playerErrorMessage: String(describing: response.errorMsg ?? ""), apiFailureCode: "", message: "", fpsFailure: "")
                self.sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
                return
            }
            
            DispatchQueue.main.async {
                self.playbackRightsModel = response.model
                self.playbackRightsModel?.fps = nil
                self.decideURLPriorityForPlayer()
                
                guard let _ = self.playerActiveUrl else {
                    return
                }
                
                if self.playbackRightsModel?.url != nil || self.playbackRightsModel?.fps != nil {
                    self.isFpsUrl = true
                }
               if self.playbackRightsModel?.thumb != nil && self.playbackRightsModel?.thumb != "" {
                                self.callWebServiceForThumbnails(thumbUrl: self.playbackRightsModel?.thumb ?? "")
                }
                self.delegate?.checkParentalControlFor(playbackRightModel: self.playbackRightsModel!)
            }
        }
    }
    
    func callWebServiceForThumbnails(thumbUrl: String) {
        let url = thumbnailBaseUrl + thumbUrl
        RJILApiManager.getReponse(path: url, headerType: .none, postType: .GET, reponseModelType: [ThumbnailsModel].self) {[weak self](response) in
            guard self != nil else {
                return
            }
            guard response.isSuccess else {
                return
            }
            let tempdata = response.model
            self?.thumbImageArray = tempdata
            DispatchQueue.main.async {
                self?.delegate?.setThumbnailsValue()
            }
        }
    }
    
    func observeValueToHideUnhideSkipIntro(newTime : Double) {
        
        guard let endTime = convertStringToSeconds(strTime: playbackRightsModel?.introCreditEnd ?? playbackRightsModel?.recapCreditEnd ?? "") else {
            return
        }
        guard let startTime = convertStringToSeconds(strTime: playbackRightsModel?.introCreditStart ?? playbackRightsModel?.recapCreditStart ?? "") else {
            return
        }
        if newTime >= startTime && newTime <= endTime{
            isItValideTimeToShowSkipButton = true
        } else {
            isItValideTimeToShowSkipButton = false
        }
        delegate?.checkTimeToShowSkipButton(isValidTime: isItValideTimeToShowSkipButton, starttime: startTime, endTime: endTime)
    }
    func convertStringToSeconds(strTime: String)-> Double?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        guard let date = dateFormatter.date(from: strTime) else {
            return nil
        }
        let seconds : Double = date.timeIntervalSince1970 - (dateFormatter.date(from: "00:00:00")?.timeIntervalSince1970 ?? 0.0)
        return seconds
    }
    
    func callWebServiceForRemovingResumedWatchlist() {
        let isDisney = self.isDisney
        guard let id = itemToBePlayed.id else{
            return
        }
        let json = ["id": id]
        let header = isDisney ? RJILApiManager.RequestHeaderType.disneyCommon : RJILApiManager.RequestHeaderType.baseCommon
        let params = ["uniqueId": JCAppUser.shared.unique, "listId": isDisney ? "30" : "10", "json": json] as [String : Any]
        let url = removeFromResumeWatchlistUrl
        RJILApiManager.getReponse(path: url, headerType: header, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: NoModel.self) { (response) in
            //            guard let self = self else {return}
            guard response.isSuccess else {
                return
            }
            if isDisney {
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
        let isDisney = self.isDisney
        RJILApiManager.getReponse(path: url, headerType: header, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: NoModel.self) {(response) in
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
            getActiveUrl(url: fpsBitcodeUrl)
        } else if let aesBitcodeUrl = self.playbackRightsModel?.aes {
            getActiveUrl(url: aesBitcodeUrl)
        } else {
            self.delegate?.dismissPlayerOnAesFailure()
//            let alert = UIAlertController(title: "Content not available!!", message: "", preferredStyle: UIAlertController.Style.alert)
//
//            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
//                DispatchQueue.main.async {
//                    print("dismiss")
//                    self.dismissPlayerVC()
//                }
//            }
//            alert.addAction(cancelAction)
//            DispatchQueue.main.async {
//                self.present(alert, animated: false, completion: nil)
//            }
        }
    }
    
    func getActiveUrl(url: Bitcode) {
        switch getUserPreferedVideoQuality() {
        case .auto:
            playerActiveUrl = url.auto
            playerActiveBitrate = .auto
        case .medium:
            playerActiveUrl = url.medium
            playerActiveBitrate = .medium
        case .high:
            playerActiveUrl = url.high
            playerActiveBitrate = .high
        case .low:
            playerActiveUrl = url.low
            playerActiveBitrate = .low
        }
        print("playerActiveUrl is  ========= \(playerActiveUrl)")
    }
    
    func getUserPreferedVideoQuality() -> BitRatesType{
        
        if let selectedBitrate = UserDefaults.standard.value(forKey: isRememberMySettingsSelectedKey){
            return BitRatesType(rawValue: selectedBitrate as! String) ?? .auto
        } else {
            return .auto
        }
    }
    
    func callWebServiceForPlayListData(id: String) {
        //vinit_commented
        let url = String(format:"%@%@/%@", playbackDataURL, JCAppUser.shared.userGroup, id)
        let params = ["id": id,"contentId":""]
        if isPlayList && itemToBePlayed.id == ""{
            //url = playBackForPlayList.appending(playListId)
            //params = ["id": playListId, "showId": "", "uniqueId": JCAppUser.shared.unique, "deviceType": "stb"]
        }
        RJILApiManager.getReponse(path: url, params: params, postType: .POST, paramEncoding: .BODY, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: PlaylistDataModel.self) {[weak self] (response) in
            guard let self = self else {return}
            guard response.isSuccess else {
                var failureType = ""
                failureType = "Playlist service failed"
                let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: response.errorMsg ?? ""), "Type": self.appType.name, "Title": self.itemToBePlayed.name ?? "", "Content ID": self.itemToBePlayed.id ?? "", "Bitrate": "0", "Episode": self.itemToBePlayed.description ?? "", "Platform": "TVOS", "Failure": failureType] as [String : Any]
                let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: String(describing: response.errorMsg ?? ""), errorCode: "-1", videoType: self.appType.name, contentTitle: self.itemToBePlayed.name ?? "", contentId: self.itemToBePlayed.id ?? "", videoQuality: "Auto", bitrate: "0", episodeSubtitle: self.itemToBePlayed.description ?? "", playerErrorMessage: String(describing: response.errorMsg ?? ""), apiFailureCode: "", message: "", fpsFailure: "")
                
                self.sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
                return
            }
            let playList = response.model!
            if let mores = playList.more {
//                self.moreArray?.removeAll()
                self.recommendationArray = false
                var currentPlayingIndex = 0
                if mores.count > 0{
                    for (index,each) in mores.enumerated() {
                        if each.id == self.itemToBePlayed.latestId {
                            currentPlayingIndex = index
                            break
                        }
                    }
                    self.recommendationArray = mores
//                    self.moreArray = mores
//                    if (self.moreArray?.count ?? 0 > 0){
                    if ((self.recommendationArray as? [Item]) != nil){
                            self.delegate?.reloadMoreLikeCollectionView(currentMorelikeIndex: currentPlayingIndex)
                    }
                    
                }
            }
            
        }
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
    
    func sendBufferingEvent() {
        
    }
    
    func preparePlayer() {
        guard let id = itemToBePlayed.id else {
            return
        }
        isMediaStartEventSent = false
        switch appType {
        case .Movie:
            if isPlayList, id == "" {
                callWebServiceForPlaybackRights(id:  itemToBePlayed.latestId ?? "")
//                delegate?.addSubviewOnPlayer()
            } else {
                currentDuration = checkInResumeWatchListForDuration(id)
                if currentDuration > 0 {
                    delegate?.addResumeWatchView()
                } else {
                    
                    callWebServiceForPlaybackRights(id: id)
//                    delegate?.addSubviewOnPlayer()
                }
            }
        case .Episode, .TVShow:
            currentDuration = checkInResumeWatchListForDuration(id)
            if currentDuration > 0 {
                delegate?.addResumeWatchView()
            } else {
                callWebServiceForPlaybackRights(id: id)
//                delegate?.addSubviewOnPlayer()
            }
        case .Music, .Clip, .Trailer:
            if isPlayList, id == "" {
                callWebServiceForPlaybackRights(id: itemToBePlayed.latestId ?? "")
//                delegate?.addSubviewOnPlayer()
            } else {
                callWebServiceForPlaybackRights(id: id)
//                delegate?.addSubviewOnPlayer()
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
        //        delegate?.addAvPlayerToController()
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
        if isFpsUrl {
            failureType = "FPS"
            isFpsUrl = false
            if let aesBitcodeUrl = self.playbackRightsModel?.aes {
                getActiveUrl(url: aesBitcodeUrl)
            }
            
            instantiatePlayerAfterParentalCheck()
            //            assetManager?.handleAESStreamingUrl(videoUrl: self.playbackRightsModel?.aesUrl ?? "")
        } else {
            failureType = "AES"
            self.delegate?.dismissPlayerOnAesFailure()
        }
        let eventPropertiesForCleverTap = ["Error Code": "-1", "Error Message": String(describing: playerItem?.error?.localizedDescription), "Type": appType.name, "Title": itemTitle, "Content ID": itemId, "Bitrate": bitrate, "Episode": itemToBePlayed.description ?? "", "Platform": "TVOS", "Failure": failureType] as [String : Any]
        let eventDicyForIAnalytics = JCAnalyticsEvent.sharedInstance.getMediaErrorEventForInternalAnalytics(descriptionMessage: failureType, errorCode: "-1", videoType: appType.name, contentTitle: itemTitle, contentId: itemId, videoQuality: "Auto", bitrate: bitrate, episodeSubtitle: itemToBePlayed.description ?? "", playerErrorMessage: String(describing: playerItem?.error?.localizedDescription), apiFailureCode: "", message: "", fpsFailure: "")
        
        sendPlaybackFailureEvent(forCleverTap: eventPropertiesForCleverTap, forInternalAnalytics: eventDicyForIAnalytics)
        
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
            self.instantiatePlayerAfterParentalCheck()
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
    
    //MARK:- Autoplay handler
    func gettingNextEpisodeAndSequence(episodes: [Episode], index: Int) -> (Episode, Bool)? {
        guard episodes.count > 1 else {return nil}
        if let firstEpisodeNum = episodes[0].episodeNo, let seconEpisodeNum = episodes[1].episodeNo {
            if firstEpisodeNum < seconEpisodeNum {
                //For handling Original Case
                if index < episodes.count - 1 {
                    let nextEpisode = episodes[index + 1]
                    return (nextEpisode, true)
                }
            } else {
                if (index - 1) >= 0 {
                    let nextEpisode = episodes[index - 1]
                    return (nextEpisode, false)
                }
            }
        }
        return nil
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
        delegate?.addAvPlayerToController()
        delegate?.addSubviewOnPlayer()
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
            self.select(nil, in: group)
            return false
        }
        self.select(matched, in: group)
        return true
    }
}


//MARK:- Analytics Events
extension PlayerViewModel {
    func sendBufferingEvent(eventProperties: [String:Any]) {
        let bufferCountForGA = eventProperties["Buffer Count"] as? String
        let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
        JCAnalyticsManager.sharedInstance.event(category: "Player Options", action: "Buffering", label: bufferCountForGA, customParameters: customParams)
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Buffering", properties: eventProperties)
    }
    func sendSkipIntroEvent(eventProperties: [String:Any]) {
//        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "User Media Error", properties: eventPropertiesCT)
        let skipIntroInternalEvent = JCAnalyticsEvent.sharedInstance.getSkipIntroEventForInternalAnalytics(screenName: fromScreen, source: fromCategory, playerCurrentPositionWhenMediaEnds: Int(playerItem?.currentTime().seconds ?? 0.0), contentId: itemId, bufferDuration: Int(totalBufferDurationTime), type: self.appType.name, bufferCount: Int(bufferCount))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: skipIntroInternalEvent)
    }
    func sendPlaybackFailureEvent(forCleverTap eventPropertiesCT:[String:Any], forInternalAnalytics eventPropertiesIA: [String: Any])
    {
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "User Media Error", properties: eventPropertiesCT)
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: eventPropertiesIA)
    }
    func sendAudioChangedAnalytics(){
        let timeSpent = 9
        let audioChangedInternalEvent = MultiAudioManager.getAudioChangedEventForInternalAnalytics(screenName: fromScreen, source: fromCategory, playerCurrentPositionWhenMediaEnds: Int(playerItem?.currentTime().seconds ?? 0.0), contentId: itemId, bufferDuration: Int(totalBufferDurationTime), timeSpent: Int(timeSpent), type: self.appType.name, bufferCount: Int(bufferCount))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: audioChangedInternalEvent)
        self.sendAudioChangedCleverTapEvent(duration: String(Int(playerItem?.currentTime().seconds ?? 0.0)))
    }
    
    func sendAudioChangedCleverTapEvent(duration : String){
        let lang = playerItem?.selected(type: .audio)
        let eventProperties = ["Platform": "TVOS","Language": lang,"Error Code":"","Error Message":"","Threshold Duration":duration,"Content Id":itemId,"Episode":"","Genre":"","screen name":fromScreen,"source":fromCategory,"Title":itemTitle ,"Offline":"","Type":"\(appType.name)"]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Audio Heard", properties: eventProperties as [String : Any])
    }
    func sendMediaStartAnalyticsEvent() {
        if !isMediaStartEventSent {
            let mbid = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss") + (UIDevice.current.identifierForVendor?.uuidString ?? "")
            
            let mediaStartInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaStartEventForInternalAnalytics(contentId: itemId, mbid: mbid, mediaStartTime: String(currentDuration), categoryTitle: fromCategory, rowPosition: String(fromCategoryIndex + 1))
            JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaStartInternalEvent)
            
            let customParams: [String:Any] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ,"Video Id": itemId, "Type": appType.rawValue, "Category Position": String(fromCategoryIndex), "Language": itemLanguage, "Bitrate" : bitrate, "Duration" : currentDuration]
            JCAnalyticsManager.sharedInstance.event(category: VIDEO_START_EVENT, action: VIDEO_ACTION, label: itemTitle, customParameters: customParams as? Dictionary<String, String>)
            isMediaStartEventSent = true
        }
    }
    
    func sendMediaEndAnalyticsEvent(timeSpent: Int) {
//        vendor = self.playbackRightsModel?.vendor
        if let currentTime = playerItem?.currentTime(), (currentTime.timescale != 0) {
            let currentTimeDuration = Int(CMTimeGetSeconds(currentTime))
//            var timeSpent = CMTimeGetSeconds(currentTime) - Double(currentDuration) - videoViewingLapsedTime
//            timeSpent = timeSpent > 0 ? timeSpent : 0
            
            let mediaEndInternalEvent = JCAnalyticsEvent.sharedInstance.getMediaEndEventForInternalAnalytics(contentId: itemId, playerCurrentPositionWhenMediaEnds: currentTimeDuration, ts: Int(timeSpent), videoStartPlayingTime: -videoStartingTimeDuration, bufferDuration: Int(totalBufferDurationTime), bufferCount: Int(bufferCount), screenName: fromScreen, bitrate: bitrate, playList: String(isPlayList), rowPosition: String(fromCategoryIndex + 1), categoryTitle: fromCategory, director: director, starcast: starCast, contentp: vendor, audioChanged: isAudioChanged )
            
            JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: mediaEndInternalEvent)
            let customParams: [String:Any] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ,"Video Id": itemId, "Type": appType.rawValue, "Category Position": String(fromCategoryIndex), "Language": itemLanguage, "Bitrate": bitrate, "Duration" : timeSpent]
            JCAnalyticsManager.sharedInstance.event(category: VIDEO_END_EVENT, action: VIDEO_ACTION, label: itemToBePlayed.name , customParameters: customParams as? Dictionary<String, String>)
            
            bufferCount = 0
//            videoStartingTimeDuration = 0
//            videoStartingTime = Date()
        }
        self.sendVideoViewedEventToCleverTap()
    }
    
    
    func sendVideoViewedEventToCleverTap() {
        let eventProperties:[String:Any] = ["Content ID": itemId, "Type": appType.rawValue, "Threshold Duration": Int(currentDuration), "Title": itemToBePlayed.name, "Episode": episodeNumber ?? -1, "Language": itemLanguage, "Source": fromCategory, "screenName": fromScreen, "Bitrate": bitrate, "Playlist": isPlayList, "Row Position":fromCategoryIndex, "Error Message": "", "Genre": "", "Platform": "TVOS", "Director": director, "Starcast": starCast, "Content Partner": vendor, "Audio Changed": isAudioChanged]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Video Viewed", properties: eventProperties)
        
        let bufferEventProperties = ["Buffer Count": String(Int(bufferCount/2)),"Buffer Duration": Int(totalBufferDurationTime),"Content ID":itemId,"Type":appType.rawValue,"Title":itemToBePlayed.name ?? "","Episode":episodeNumber ?? -1,"Bitrate":bitrate, "Platform":"TVOS"] as [String : Any]
        sendBufferingEvent(eventProperties: bufferEventProperties)
        videoViewingLapsedTime = 0
        totalBufferDurationTime = 0
        bufferCount = 0
    }
}
extension PlayerViewModel {
    func startTimerToCalculateTimeSpent() {
        if  videoViewedTimer != nil {
            videoViewedTimer?.invalidate()
            videoViewedTimer = nil
        }
        videoViewedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {[weak self] (timer) in
            self?.videoViewedTimer?.invalidate()
            self?.videoViewedTimer = nil
        })
    }
    
//    func resetTimertToHideControls() {
////        if controlsView != nil || controlsView?.isHidden == false{
//            invalidateTimerForControl()
////            self.controlsView?.isHidden = false
////            self.moreLikeView?.isHidden = false
//            self.startTimerToHideControls()
//        }
//    }
//
    func invalidateTimerForControl() {
        if self.videoViewedTimer != nil {
            self.videoViewedTimer?.invalidate()
        }
    }
}

