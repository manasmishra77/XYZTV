//
//  CustomPlayerView.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 26/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class CustomPlayerView: UIView {
    
    var moreLikeView: MoreLikeView?
    fileprivate var playerViewModel: PlayerViewModel?
    fileprivate var playbackRightModel : PlaybackRightsModel?
    fileprivate var enterParentalPinView: EnterParentalPinView?
    fileprivate var enterPinViewModel: EnterPinViewModel?
    fileprivate var playerItem: Item?
    
    var controlsView : PlayersControlView?
    
    @IBOutlet weak var playerHolderView: UIView!
    @IBOutlet weak var controlHolderView: UIView!
    @IBOutlet weak var moreLikeHolderView: UIView!
    
    @IBOutlet weak var bottomSpaceOfMoreLikeInContainer: NSLayoutConstraint!
    @IBOutlet weak var heightOfMoreLikeHolderView: NSLayoutConstraint!
    
    var timer: Timer!
    var timerToHideControls : Timer!
    
    func configureView(item: Item, superView: UIView) {
        playerViewModel = PlayerViewModel(item: item)
        playerViewModel?.callWebServiceForMoreLikeData()
        playerViewModel?.delegate = self
        self.playerItem = item
        addPlayersControlView()
        moreLikeView?.moreLikeCollectionView.reloadData()
        addMoreLikeView()
        startTimer()
    }
    
    func addPlayersControlView() {
        controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
        controlsView?.configurePlayersControlView()
        controlsView?.delegate = self
        controlsView?.frame = controlHolderView.bounds
        guard let controlsView = controlsView else {
            return
        }
        self.controlHolderView.addSubview(controlsView)
        //        self.bringSubview(toFront: controlHolderView)
    }
    func addMoreLikeView() {
        moreLikeView = UINib(nibName: "MoreLikeView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? MoreLikeView
        heightOfMoreLikeHolderView.constant = (playerViewModel?.appType == .Movie) ? rowHeightForPotrait : rowHeightForLandscape
        self.layoutIfNeeded()
        moreLikeView?.configMoreLikeView()
        moreLikeView?.frame = moreLikeHolderView.bounds
        //        guard let moreLikeView = moreLikeView else {
        //            return
        //        }
        self.moreLikeHolderView.addSubview(moreLikeView!)
        
        //        moreLikeView?.delegate = self
        
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView is ItemCollectionViewCell{
            resetTimer()
            self.bottomSpaceOfMoreLikeInContainer.constant = 0
            UIView.animate(withDuration: 1) {
                self.layoutIfNeeded()
                self.controlsView?.layoutIfNeeded()
            }
        } else {
            self.bottomSpaceOfMoreLikeInContainer.constant = playerViewModel?.appType == .Movie ? -(rowHeightForPotrait - 100) : -(rowHeightForLandscape - 100)
            UIView.animate(withDuration: 1) {
                self.layoutIfNeeded()
            }
        }
    }
}

extension CustomPlayerView : PlayerControlsDelegate {
    func getTimeDetails(_ currentTime: String, _ duration: String) {
        playerViewModel?.getPlayerDuration()
    }
    
    func playTapped(_ isPaused: Bool) {
        if !isPaused {
            //             player?.pause()
        } else {
            //            player?.play()
        }
    }
}



extension CustomPlayerView: EnterPinViewModelDelegate {
    func pinVerification(_ isSucceed: Bool) {
        if isSucceed {
            enterPinViewModel = nil
            enterParentalPinView?.removeFromSuperview()
            enterParentalPinView = nil
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }
}

extension CustomPlayerView: PlayerViewModelDelegate {
    func currentTimevalueChanged(newTime: Double, duration: Double) {
        controlsView?.sliderView?.staringTime.text = getCurrentTimeInFormat(time: newTime)
        controlsView?.sliderView?.endingTime.text = getCurrentTimeInFormat(time: duration)
        controlsView?.sliderView?.updateProgressBar(currentTime: Float(newTime), duration: Float(duration), dueToScrubing: false)
        controlsView?.sliderView?.progressBar.progress = Float(newTime / duration)
    }
    
    func getCurrentTimeInFormat(time: Double) -> String {
        var seconds = 0
        var min = 0
        var hours = 0
        seconds = Int(time) % 60
        hours = Int(time) / 3600
        min = (Int(time) - hours * 3600) / 60
        return "\(hours):\(min):\(seconds)"
    }
    func getDuration(duration: Double){
//        controlsView?.sliderView?.endingTime.text = getCurrentTimeInFormat(time: duration)
    }
    
    func reloadMoreLikeCollectionView(i: Int) {
        self.moreLikeView?.moreArray = playerViewModel?.moreArray
        self.moreLikeView?.episodesArray = playerViewModel?.episodeArray
        self.moreLikeView?.appType = playerViewModel?.appType ?? .None
        self.moreLikeView?.moreLikeCollectionView.reloadData()
    }
    
    func checkParentalControlFor(playbackRightModel: PlaybackRightsModel) {
        self.playbackRightModel = playbackRightModel
        let ageGroup:AgeGroup = self.playbackRightModel?.maturityAgeGrp ?? .allAge
        if ParentalPinManager.shared.checkParentalPin(ageGroup) {
            enterParentalPinView = Utility.getXib(EnterParentalPinViewIdentifier, type: EnterParentalPinView.self, owner: self)
            enterPinViewModel = EnterPinViewModel(contentName: playbackRightModel.contentName ?? "", delegate: self)
            enterParentalPinView?.delegate = enterPinViewModel
            enterParentalPinView?.contentTitle.text = self.enterPinViewModel?.contentName
            enterParentalPinView?.frame = self.frame
            self.addSubview(enterParentalPinView!)
        }
        else {
            playerViewModel?.instantiatePlayerAfterParentalCheck()
        }
    }
    
    func addAvPlayerControllerToController() {
        if let player = playerViewModel?.player {
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.bounds
//            playerLayer.videoGravity = .resizeAspectFill
            self.clipsToBounds = true
            playerLayer.videoGravity = .resize
            playerHolderView.layer.addSublayer(playerLayer)
            playerViewModel?.addPlayerNotificationObserver()
            player.play()
            //            self.bringSubview(toFront: controlHolderView)
        }
    }
    
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {
        //vinit_comment handle player error
    }
}
extension CustomPlayerView {
    func startTimer(){
        timerToHideControls = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hideControlsView), userInfo: nil, repeats: true)
    }
    
    func resetTimer(){
        self.controlsView?.isHidden = false
        self.moreLikeView?.isHidden = false
        timerToHideControls.invalidate()
        startTimer()
    }
    @objc func hideControlsView() {
        self.controlsView?.isHidden = true
        self.moreLikeView?.isHidden = true
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type{
            case .downArrow, .leftArrow, .upArrow, .rightArrow:
                resetTimer()
            case .menu:
                print("menu")
            case .playPause:
                print("playPause")
                if playerViewModel?.player?.rate == 0 {
                    playerViewModel?.player?.play()
                } else {
                    playerViewModel?.player?.pause()
                }
            case .select:
                    print("select")
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            switch touch.type{
            case .direct:
                print("Direct")
            case .indirect:
                print("indirect")
                resetTimer()
            case .pencil:
                print("pencil")
            }
        }
    }
    
}
