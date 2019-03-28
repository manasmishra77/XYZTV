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
    
    @IBOutlet weak var playButton: UIButton!
    var delegate : PlayerControlsDelegate?
    
    var isPaused = false
    
    var sliderView : CustomSlider?
    
    func configurePlayersControlView() {
        addCustomSlider()
    }
    
    func addCustomSlider() {
        sliderView = UINib(nibName: "CustomSlider", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomSlider
        sliderView?.frame = sliderHolderView.bounds
        sliderView?.configureControls()
        sliderView?.sliderDelegate = self
        sliderHolderView.addSubview(sliderView!)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.playTapped(isPaused)
        isPaused = !isPaused
        playButton.setTitle(isPaused ? "Play" : "Pause", for: .normal)
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
