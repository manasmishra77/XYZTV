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
}

class PlayersControlView: UIView {
    
    @IBOutlet weak var playButton: UIButton!
    var delegate : PlayerControlsDelegate?
    
    var isPaused = false
    
    var sliderView : CustomSlider?
    
    func configurePlayersControlView() {
        addCustomSlider()
    }
    func addCustomSlider() {
        sliderView = UINib(nibName: "CustomSlider", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomSlider
        sliderView?.configureControls()
        sliderView?.addAsSubviewWithFourConstraintsFromBottomWithConstantHeight(self, height: 200, bottom: -200, leading: 0, trailing: 0)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("abhdjk")
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.playTapped(isPaused)
        isPaused = !isPaused
        playButton.setTitle(isPaused ? "Play" : "Pause", for: .normal)
    }
}
