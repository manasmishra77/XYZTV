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
    var controlsView : PlayersControlView?

    var player : AVPlayer?
    var playerItem : AVPlayerItem?
    var url: URL?
    var timer: Timer!
    var delegate : DelegateToUpdateProgressBar?
    var myPreferedFocusView : UIView?
    
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
        
        self.updateFocusIfNeeded()
        self.setNeedsFocusUpdate()
    }
    func addPlayersControlView() {
        controlsView = UINib(nibName: "PlayersControlView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayersControlView
        controlsView?.configurePlayersControlView()
        controlsView?.delegate = self
        controlsView?.addAsSubviewWithFourConstraintsFromBottomWithConstantHeight(self, height: 400, bottom: -100, leading: 0, trailing: 0)
    }
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        for press in presses {
//            switch press.type{
//            case .downArrow:
//                print("DownArrow")
//            case .leftArrow:
//                print("leftArrow")
//            case .menu:
//                print("menu")
//            case .playPause:
//                print("playPause")
//            case .rightArrow:
//                print("rightArrow")
//            case .upArrow:
//                print("upArrow")
//            case .select:
//                print("select")
//            }
//        }
//    }

//    @objc func updateProgressBar() {
//        if let duration = playerItem?.asset.duration, let currentTime = playerItem?.currentTime(){
//            let newValue = currentTime.seconds / duration.seconds
//            controlsView?.updateProgressBar(progress: Float(newValue))
//        }
//    }
//    var start:CGPoint?

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
