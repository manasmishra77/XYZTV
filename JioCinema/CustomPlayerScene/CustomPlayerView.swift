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

    var moreLikeView: MoreLikeView?
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
    var timerToHideControls : Timer!
    
//<<<<<<< HEAD
//    func configureView(url: URL, superView: UIView) {
//        self.url = url
//        playerItem = AVPlayerItem(url: url)
//        player = AVPlayer(playerItem: playerItem)
//        player?.play()
//        //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.bounds
//        self.clipsToBounds = true
//        self.layer.addSublayer(playerLayer)
//        addPlayersControlView()
//        addMoreLikeView()
//        startTimer()
//        self.updateFocusIfNeeded()
//        self.setNeedsFocusUpdate()
//    }
//    func startTimer(){
//        timerToHideControls = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hideControlsView), userInfo: nil, repeats: true)
//    }
//
//    func resetTimer(){
//        self.controlsView?.isHidden = false
//        timerToHideControls.invalidate()
//        startTimer()
//    }
//
//    @objc func hideControlsView() {
//        self.controlsView?.isHidden = true
//    }
//=======
    func configureView(item: Item, superView: UIView) {
        playerViewModel = PlayerViewModel(item: item)
        playerViewModel?.delegate = self
        self.playerItem = item
        addPlayersControlView()
//        addMoreLikeView()
    }
    
    
    func addPlayersControlView() {
        controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
        controlsView?.configurePlayersControlView()
        controlsView?.delegate = self
        controlsView?.frame = controlHolderView.frame
        self.controlHolderView.addSubview(controlsView!)
//        self.bringSubview(toFront: controlHolderView)
    }
//<<<<<<< HEAD
//    func addMoreLikeView() {
//        moreLikeView = UINib(nibName: "MoreLikeView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? MoreLikeView
//        moreLikeView?.configMoreLikeView()
////        moreLikeView?.delegate = self
//        moreLikeView?.addAsSubviewWithFourConstraintsFromBottomWithConstantHeight(self, height: 500, bottom: 400, leading: 0, trailing: 0)
//    }
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        for press in presses {
//            switch press.type{
//            case .downArrow:
//                //print("DownArrow")
//                resetTimer()
////                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
//            case .leftArrow:
//                resetTimer()
//                //print("leftArrow")
////                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
//            case .menu:
//                print("menu")
//            case .playPause:
//                print("playPause")
//            case .rightArrow:
//                resetTimer()
//                //print("rightArrow")
////                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
//            case .upArrow:
//                resetTimer()
//                //print("upArrow")
////                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
//            case .select:
//                print("select")
//            }
//        }
//    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches{
//            switch touch.type{
//            case .direct:
//                print("Direct")
//            case .indirect:
//                print("indirect")
//                resetTimer()
//            case .pencil:
//                print("pencil")
//            }
//        }
//    }
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        if context.nextFocusedView == moreLikeView {
//            controlsView?.isHidden = true
//            UIView.animate(withDuration: 2, animations: {
//                self.moreLikeView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -500).isActive = true
//            }, completion: nil)
//            layoutIfNeeded()
//            moreLikeView?.layoutIfNeeded()
////            moreLikeView?.layoutIfNeeded()
//            moreLikeView?.moreLikeCollectionView.layoutIfNeeded()
//            moreLikeView?.moreLikeCollectionView.reloadData()
//        }
//    }
//=======
//>>>>>>> ff5f153ee04a031263d5868d694c1f536c815a48
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
