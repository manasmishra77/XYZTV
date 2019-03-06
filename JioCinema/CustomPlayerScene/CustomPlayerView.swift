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
    var controlsView: PlayersControlView?
    var moreLikeView: MoreLikeView?

    var player : AVPlayer?
    var playerItem : AVPlayerItem?
    var url: URL?
    var timer: Timer!
    var delegate : DelegateToUpdateProgressBar?
    var myPreferedFocusView : UIView?
    var timerToHideControls : Timer!
    
    func configureView(url: URL, superView: UIView) {
        self.url = url
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.clipsToBounds = true
        self.layer.addSublayer(playerLayer)
        addPlayersControlView()
        addMoreLikeView()
        startTimer()
        self.updateFocusIfNeeded()
        self.setNeedsFocusUpdate()
    }
    func startTimer(){
        timerToHideControls = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.hideControlsView), userInfo: nil, repeats: true)
    }
    
    func resetTimer(){
        self.controlsView?.isHidden = false
        timerToHideControls.invalidate()
        startTimer()
    }

    @objc func hideControlsView() {
        self.controlsView?.isHidden = true
    }
    func addPlayersControlView() {
        controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
        controlsView?.configurePlayersControlView()
        controlsView?.delegate = self
        controlsView?.addAsSubviewWithFourConstraintsFromBottomWithConstantHeight(self, height: 400, bottom: -100, leading: 0, trailing: 0)
    }
    func addMoreLikeView() {
        moreLikeView = UINib(nibName: "MoreLikeView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? MoreLikeView
        moreLikeView?.configMoreLikeView()
//        moreLikeView?.delegate = self
        moreLikeView?.addAsSubviewWithFourConstraintsFromBottomWithConstantHeight(self, height: 500, bottom: 400, leading: 0, trailing: 0)
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type{
            case .downArrow:
                //print("DownArrow")
                resetTimer()
//                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
            case .leftArrow:
                resetTimer()
                //print("leftArrow")
//                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
            case .menu:
                print("menu")
            case .playPause:
                print("playPause")
            case .rightArrow:
                resetTimer()
                //print("rightArrow")
//                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
            case .upArrow:
                resetTimer()
                //print("upArrow")
//                self.controlsView?.isHidden = self.controlsView?.isHidden == true ? false : true
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
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == moreLikeView {
            controlsView?.isHidden = true
            UIView.animate(withDuration: 2, animations: {
                self.moreLikeView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -500).isActive = true
            }, completion: nil)
            layoutIfNeeded()
            moreLikeView?.layoutIfNeeded()
//            moreLikeView?.layoutIfNeeded()
            moreLikeView?.moreLikeCollectionView.layoutIfNeeded()
            moreLikeView?.moreLikeCollectionView.reloadData()
        }
    }
}
extension CustomPlayerView : PlayerControlsDelegate {
    func playTapped(_ isPaused: Bool) {
        if !isPaused {
            player?.pause()
        } else {
            player?.play()
        }
    }
}
