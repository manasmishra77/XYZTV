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

class JCPlayerVC: UIViewController
{
 
    var player:AVPlayer?
    var playerController:AVPlayerViewController?
    var playbackRightsData:PlaybackRightsModel?
    var isResumed = false
    var duration:Double = 0
    var playerId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func instantiatePlayer(with url:String)
    {
        let videoUrl = URL(string: url)
        player = AVPlayer(url: videoUrl!)
        playerController = AVPlayerViewController()
        if isResumed
        {
            player?.seek(to: CMTimeMakeWithSeconds(duration, (player?.currentItem?.asset.duration.timescale)!))
        }
        playerController?.player = player
        self.addChildViewController(playerController!)
        self.view.addSubview((playerController?.view)!)
        playerController?.view.frame = self.view.frame
        
        player?.play()
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        for press in presses {
            if(press.type == .menu)
            {
                self.callWebServiceForAddToResumeWatchlist()
                player?.pause()
                player = nil
            }
        }
    }
    
    func callWebServiceForAddToResumeWatchlist()
    {
        let url = addToResumeWatchlistUrl
        let json: Dictionary<String, String> = ["id":playerId!, "duration":"\(CMTimeGetSeconds((player?.currentItem?.currentTime())!))", "totalduration": "\(CMTimeGetSeconds((player?.currentItem?.duration)!))"]
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = JCAppUser.shared.unique
        params["listId"] = "10"
        params["json"] = json
        params["id"] = playerId
        params["duration"] = "\(CMTimeGetSeconds((player?.currentItem?.currentTime())!))"
        params["totalduration"] = "\(CMTimeGetSeconds((player?.currentItem?.duration)!))"
        
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
    
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

