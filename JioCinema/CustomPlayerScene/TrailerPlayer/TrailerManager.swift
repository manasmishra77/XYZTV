//
//  TrailerManager.swift
//  JioCinema
//
//  Created by vinit somani on 8/27/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import AVKit


class TrailerManager: NSObject {
    
    static let shared = TrailerManager()
    var trailerPlayerLayer: AVPlayerLayer?
    var playerViewModel: PlayerViewModel?
    var playerItem: Item?
    var trailerHolderView: UIView?

    weak var timerForTrailer: Timer?
    
    @objc var player: AVPlayer? {
        get {
            return self.trailerPlayerLayer?.player
        }
    }
    
    private override init() {}
    
    func initialiseViewModelForTrailer(item: Item, holderView: UIView) {
        
        self.timerForTrailer?.invalidate()
        self.timerForTrailer = nil
        self.timerForTrailer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) {[weak self] (timer) in
            guard let self = self else {return}
            
            guard let url = item.trailer?.urls?.TV?.auto else {
                return
            }
            self.resetPlayer()
            self.trailerHolderView = holderView
            self.playerViewModel = nil
            self.playerViewModel = PlayerViewModel(item: item)
            self.playerViewModel?.delegate = self
            self.playerItem = item
            self.playerViewModel?.preparePlayerForTrailer(url: url)
        }
    }
    
    func resetPlayer() {
        if let player = player {
            player.pause()
            self.removePlayerObserver()
        }
        self.trailerPlayerLayer?.removeFromSuperlayer()
        self.playerViewModel = nil
        self.timerForTrailer?.invalidate()
        self.timerForTrailer = nil
    }

}


extension TrailerManager: PlayerViewModelDelegate {
    func setThumbnailsValue() {}
    
    func checkTimeToShowSkipButton(isValidTime: Bool, starttime: Double, endTime: Double) {}
    
    func dismissPlayer() {
    }
    
    func updateIndicatorState(toStart: Bool) {}
    
    func addResumeWatchView() {}
    
    func setValuesForSubviewsOnPlayer() {}
    
    func addSubviewOnPlayer() {}
    
    func reloadMoreLikeCollectionView(currentMorelikeIndex: Int) {}
    
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel) {}
    
    func addAvPlayerToController() {
        DispatchQueue.main.async {
            guard let holderView = self.trailerHolderView else {
                return
            }
                let player = AVPlayer(playerItem: self.playerViewModel?.playerItem)
                self.trailerPlayerLayer = AVPlayerLayer(player: player)
                self.trailerPlayerLayer?.frame = holderView.bounds
                self.trailerPlayerLayer?.videoGravity = .resizeAspectFill
                self.trailerHolderView?.layer.addSublayer(self.trailerPlayerLayer!)
            self.addPlayerNotificationObserver()
            self.player?.seek(to: CMTime(seconds: Double(0), preferredTimescale: 1))
            self.player?.play()
           
        }
    }
    
    func addPlayerNotificationObserver () {
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackLikelyToKeepUp), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    
    //MARK:- Remove Player Observer
    func removePlayerObserver() {
        guard let viewModel = playerViewModel else {
            return
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackBufferEmpty), context: &playerViewControllerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.isPlaybackLikelyToKeepUp), context: &playerViewControllerKVOContext)
    }
    
    
    //MARK:- AVPlayer Finish Playing Item
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.updateIndicatorState(toStart: false)
        self.resetPlayer()
    }
    
    
    
    func setCurrentPlayingOnMoreLike() {}
    
    
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
        
        if keyPath == #keyPath(player.currentItem.duration) {
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = CMTime.zero
            }
            Log.DLog(message: newDuration as AnyObject)
        }
        else if keyPath == #keyPath(player.rate) {
            //            let newRate = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.doubleValue ?? 0
        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackBufferFull)
        {
            self.updateIndicatorState(toStart: false)
        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackBufferEmpty)
        {
            self.updateIndicatorState(toStart: true)
            playerViewModel?.startTime_BufferDuration = Date()
        }
        else if keyPath == #keyPath(player.currentItem.isPlaybackLikelyToKeepUp)
        {
            self.updateIndicatorState(toStart: false)
            playerViewModel?.updatePlayerBufferCount()
        }
        else if keyPath == #keyPath(player.currentItem.status) {
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue) ?? .unknown
            } else {
                newStatus = .unknown
            }
            switch newStatus {
            case .readyToPlay:
                playerViewModel?.videoStartingTimeDuration = Int(playerViewModel?.videoStartingTime.timeIntervalSinceNow ?? 0)
                playerViewModel?.isItemToBeAddedInResumeWatchList = true
                self.addPlayerPeriodicTimeObserver()
                playerViewModel?.sendMediaStartAnalyticsEvent()
                break
            case .failed:
                playerViewModel?.handlePlayerStatusFailed()
                break
            default:
                break
            }
        }
    }
    
    
    func addPlayerPeriodicTimeObserver() {}
    func checkForNextVideoInAutoPlay(remainingTime: Double) {}
    func hideUnhideControl(visibleControls : VisbleControls) {}
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {}
    func dismissPlayerOnAesFailure() {
        self.resetPlayer()
    }
}
