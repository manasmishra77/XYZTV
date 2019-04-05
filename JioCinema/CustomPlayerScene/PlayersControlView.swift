//
//  CustomSlider.swift
//  JioCinema
//
//  Created by Shweta Adagale on 05/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol PlayerControlsDelegate {
    func playTapped(_ isPaused: Bool)
    func subtitlesAndMultiaudioButtonPressed(todisplay: Bool)
    func settingsButtonPressed(toDisplay: Bool)
    func nextButtonPressed(toDisplay: Bool)
    func previousButtonPressed(toDisplay: Bool)
    func getTimeDetails(_ currentTime: String,_ duration: String)
    func setPlayerSeekTo(seekValue: CGFloat)
    func cancelTimerForHideControl()
    func resetTimerForHideControl()
//    func settingsAudioAndSubtitlePressedOnControl()
//    func settingsVideoQualityPressedOnControl()
}

class PlayersControlView: UIView {
    @IBOutlet weak var sliderHolderView: UIView!
    @IBOutlet weak var playerButtonsHolderView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    var delegate : PlayerControlsDelegate?
    
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
        playerButtonsView?.frame = sliderHolderView.bounds
        playerButtonsView?.configurePlayerButtonsView()
        playerButtonsHolderView.addSubview(playerButtonsView!)
        
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.playTapped(isPaused)
        isPaused = !isPaused
        playButton.setImage(isPaused ? UIImage(named: "Play") : UIImage(named: "Pause"), for: .normal)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        delegate?.settingsButtonPressed(toDisplay: true)
    }
    @IBAction func subtitleButtonPressed(_ sender: Any) {
        delegate?.subtitlesAndMultiaudioButtonPressed(todisplay: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        delegate?.nextButtonPressed(toDisplay: true)
    }
    @IBAction func previoudButtonPressed(_ sender: Any) {
        delegate?.previousButtonPressed(toDisplay: true)
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
