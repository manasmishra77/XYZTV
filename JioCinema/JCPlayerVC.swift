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
    @IBOutlet var lbl_NextVideoPlayingTime : UILabel!
    
    var player:AVPlayer?
    var playerTimeObserverToken: Any?
    var playerController:AVPlayerViewController?
    var playbackRightsData:PlaybackRightsModel?
    var isResumed:Bool?
    var duration:Double = 0
    var playerId:String?
    var playlistData:PlaylistDataModel?
    
    var playlistIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //self.removePlayerObserver()
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
        player = AVPlayer(url: videoUrl!)
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
        
        self.view.bringSubview(toFront: self.lbl_NextVideoPlayingTime)
        self.lbl_NextVideoPlayingTime.isHidden = true

    }
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        for press in presses {
            if(press.type == .menu)
            {
                let currentTimeduration = "\(CMTimeGetSeconds((player?.currentItem?.currentTime())!))"
                let totalDuration = "\(CMTimeGetSeconds((player?.currentItem?.duration)!))"
                removePlayerObserver()
                self.callWebServiceForAddToResumeWatchlist(currentTimeDuration: currentTimeduration, totalDuration: totalDuration)
                if isResumed != nil
                {
                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                }
            }
        }
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
                
                Log.DLog(message: "Remaining Time" as AnyObject)
                
                let currentPlayerTime = Double(CMTimeGetSeconds(time))
                let remainingTime = (self?.getPlayerDuration())! - currentPlayerTime
                
                
                //Log.DLog(message: self?.player?.currentItem?.duration as AnyObject)
                Log.DLog(message: remainingTime as AnyObject)
                
                if UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
                {
                    let index = (self?.playlistIndex)! + 1
                    
                    if index != self?.playlistData?.more?.count
                    {
                    if remainingTime <= 5
                    {
                        self?.lbl_NextVideoPlayingTime.isHidden = false
                        self?.lbl_NextVideoPlayingTime.text = "Next video will  play in " + "\(Int(remainingTime))" + " Seconds"
                    }
                    }
                    else
                    {
                        self?.lbl_NextVideoPlayingTime.isHidden = true
                    }
                }
                else
                {
                    self?.lbl_NextVideoPlayingTime.isHidden = true
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

        if UserDefaults.standard.bool(forKey: isAutoPlayOnKey)
        {
            self.playlistIndex = self.playlistIndex + 1

            if self.playlistIndex != self.playlistData?.more?.count
            {
                let moreId = self.playlistData?.more?[self.playlistIndex].id
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
