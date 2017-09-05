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
    @IBOutlet weak var nextVideoView: UIView!
    @IBOutlet weak var nextVideoNameLabel: UILabel!
    @IBOutlet weak var nextVideoPlayingTimeLabel: UILabel!
    @IBOutlet weak var nextVideoThumbnail: UIImageView!
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerTimeObserverToken: Any?
    var playerController:AVPlayerViewController?
    var playbackRightsData:PlaybackRightsModel?
    var isResumed:Bool?
    var duration:Double = 0
    var playerId:String?
    var playlistData:PlaylistDataModel?
    var currentItemImage:String?
    var currentItemTitle:String?
    var currentItemDuration:String?
    var currentItemDescription:String?
    
    var playlistIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let currentTime = player?.currentItem?.currentTime()
        {
            let currentTimeDuration = "\(CMTimeGetSeconds(currentTime))"
            let totalDuration = "\(CMTimeGetSeconds((player?.currentItem?.duration)!))"
            self.callWebServiceForAddToResumeWatchlist(currentTimeDuration: currentTimeDuration, totalDuration: totalDuration)
        }
        if isResumed != nil
        {
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }

        removePlayerObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- AVPlayerViewController Methods
    
    func instantiatePlayer(with url:String)
    {
        if((self.player) != nil) {
            self.removePlayerObserver()
        }
        
        let videoUrl = URL(string: url)
        playerItem = AVPlayerItem(url: videoUrl!)
        
        self.addMetadtaToPlayer()
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
        self.nextVideoView.isHidden = true
        
    }
    
    func addMetadtaToPlayer()
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
                Log.DLog(message: "Remaining Time" as AnyObject)
                Log.DLog(message: remainingTime as AnyObject)
               
                if UserDefaults.standard.bool(forKey: isAutoPlayOnKey),self?.playlistData != nil
                {
                    let index = (self?.playlistIndex)! + 1
                    
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
    func getPlayerDuration() -> Double {
        Log.DLog(message: "$$$$$$$$" as AnyObject)
        Log.DLog(message: self.player?.currentItem as AnyObject)
        
        guard let currentItem = self.player?.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
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
        // self.currentItem = nil
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
                // self.playerDelegate?.didILinkPlayerStatusReadyToPlay()
                break
            case .failed:
                Log.DLog(message: "Failed" as AnyObject)
            // self.playerDelegate?.didILinkPlayerStatusFailed(player?.currentItem?.error?.localizedDescription, error: player?.currentItem?.error)
            default:
                print("unknown")
            }
            
            if newStatus == .failed {
            }
        }
    }
    
    
    
    
    
    func playerDidFinishPlaying(note: NSNotification) {
        Log.DLog(message: self.playlistData?.more?.count as AnyObject )
        Log.DLog(message: self.playlistIndex as AnyObject )
        
        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey),self.playlistData != nil
        {
            self.playlistIndex = self.playlistIndex + 1
            
            if self.playlistIndex != self.playlistData?.more?.count
            {
                let moreId = self.playlistData?.more?[self.playlistIndex].id
                self.currentItemImage = self.playlistData?.more?[self.playlistIndex].banner
                self.currentItemTitle = self.playlistData?.more?[self.playlistIndex].name
                self.currentItemDuration = String(describing: self.playlistData?.more?[self.playlistIndex].totalDuration)
                self.currentItemDescription = self.playlistData?.more?[self.playlistIndex].description
                self.callWebServiceForPlaybackRights(id: moreId!)
            }
            else
            {
                dismissPlayerVC()
            }
        }
        else
        {
            dismissPlayerVC()
        }
    }
    
    func dismissPlayerVC()
    {
        removePlayerObserver()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Webservice Methods
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
                        let moreId = self.playlistData?.more?[self.playlistIndex].id
                        self.currentItemImage = self.playlistData?.more?[self.playlistIndex].banner
                        self.currentItemTitle = self.playlistData?.more?[self.playlistIndex].name
                        self.currentItemDuration = String(describing: self.playlistData?.more?[self.playlistIndex].totalDuration)
                        self.currentItemDescription = self.playlistData?.more?[self.playlistIndex].description
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
        let json: Dictionary<String, String> = ["id":playerId!, "duration":currentTimeDuration, "totalduration": totalDuration]
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = JCAppUser.shared.unique
        params["listId"] = "10"
        params["json"] = json
        params["id"] = playerId
        params["duration"] = currentTimeDuration
        params["totalduration"] = totalDuration
        
        let addToResumeWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
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

class PlaylistDataModel: Mappable {
    
    var more: [More]?
    
    required init(map:Map) {
    }
    
    func mapping(map:Map)
    {
        
        more <- map["more"]
    }
    
}
