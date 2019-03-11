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

protocol DelegateToUpdateProgressBar {
    func currentTimevalueChanged(newTime : Float)
}

class CustomPlayerView: UIView {
    
    fileprivate var playerViewModel: PlayerViewModel?
    fileprivate var playbackRightModel : PlaybackRightsModel?
    fileprivate var enterParentalPinView: EnterParentalPinView?
    fileprivate var enterPinViewModel: EnterPinViewModel?
    fileprivate var playerItem: Item?
    
    var controlsView : PlayersControlView?
    
    @IBOutlet weak var playerHolderView: UIView!
    @IBOutlet weak var controlHolderView: UIView!
    
    var timer: Timer!
    var delegate : DelegateToUpdateProgressBar?
    var myPreferedFocusView : UIView?
    
    func configureView(item: Item, superView: UIView) {
        playerViewModel = PlayerViewModel(item: item)
        playerViewModel?.delegate = self
        self.playerItem = item
        addPlayersControlView()
    }
    
    
    func addPlayersControlView() {
        controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
        controlsView?.configurePlayersControlView()
        controlsView?.delegate = self
        controlsView?.frame = controlHolderView.frame
        self.controlHolderView.addSubview(controlsView!)
//        self.bringSubview(toFront: controlHolderView)
    }
}

extension CustomPlayerView : PlayerControlsDelegate {
    func playTapped(_ isPaused: Bool) {
        if !isPaused {
//            player?.pause()
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
            playerLayer.videoGravity = .resizeAspectFill
            self.clipsToBounds = true
            playerHolderView.layer.addSublayer(playerLayer)
            player.play()
//            self.bringSubview(toFront: controlHolderView)
        }
    }
    
    func handlePlaybackRightDataError(errorCode: Int, errorMsg: String) {
        //vinit_comment handle player error
    }
}
