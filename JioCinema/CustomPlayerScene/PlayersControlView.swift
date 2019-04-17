//
//  CustomSlider.swift
//  JioCinema
//
//  Created by Shweta Adagale on 05/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol PlayerControlsDelegate: NSObject {
    func getTimeDetails(_ currentTime: String,_ duration: String)
    func setPlayerSeekTo(seekValue: CGFloat)
    func cancelTimerForHideControl()
    func resetTimerForHideControl()
}

class PlayersControlView: UIView {
    @IBOutlet weak var sliderHolderView: UIView!
    @IBOutlet weak var playerButtonsHolderView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    weak var delegate : PlayerControlsDelegate?
    
    @IBOutlet var playerButtonLabels: [UILabel]!
    var isPaused = false
    
    var sliderView : CustomSlider?
    var playerButtonsView: PlayerButtonsView?
    
    func configurePlayersControlView() {
        addCustomSlider()
        addPlayerButtons()
    }
    
    func addCustomSlider() {
        sliderView = UINib(nibName: "CustomSlider", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomSlider
        sliderView?.frame = sliderHolderView.bounds
        sliderView?.configureControls()
        sliderView?.sliderDelegate = self
        sliderHolderView.addSubview(sliderView!)
    }
    
    func addPlayerButtons() {
        playerButtonsView = UINib(nibName: "PlayerButtonsView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? PlayerButtonsView
        playerButtonsView?.frame = playerButtonsHolderView.bounds
        playerButtonsView?.configurePlayerButtonsView()
        playerButtonsHolderView.addSubview(playerButtonsView!)
        
    }
    deinit {
        print("PlayerControlsView deinit called")
    }
}

extension PlayersControlView: CustomSliderProtocol {
    func resetTimerForShowControl() {
        delegate?.resetTimerForHideControl()
    }
    
    func seekPlayerTo(pointX: CGFloat) {
        delegate?.setPlayerSeekTo(seekValue: pointX)
    }
    
    func cancelTimerForHideControl() {
        delegate?.cancelTimerForHideControl()
    }

}
