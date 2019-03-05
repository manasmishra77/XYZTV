//
//  ControlsView.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 27/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//
import UIKit
import Foundation
protocol PlayerControlsDelegate {
    func playTapped(_ isPaused: Bool)
}

class ControlsView: UIView {
    @IBOutlet weak var sliderLeading: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    var progressBarTimer : Timer!
    var isPaused = false
    
    var delegate : PlayerControlsDelegate?
    var slidersValueWhentouchBeganCalled: CGFloat = 0.0
    var progressWhentouchBeganCalled: Float = 0.0
    
    func configureControls() {
        playButton.isEnabled = false
        self.clipsToBounds = true
        progressBar.progress = 0.0
        progressBar.tintColor = .red
    }
    @IBAction func playButtonTapped(_ sender: UIButton) {
        delegate?.playTapped(isPaused)
        isPaused = !isPaused
        sender.setTitle(isPaused ? "Play" : "Pause", for: .normal)
    }
    
    func touchBeganCalledSetSliderValue() {
        slidersValueWhentouchBeganCalled = sliderLeading.constant
        progressWhentouchBeganCalled = progressBar.progress
    }
    func updateProgressBar(progress: Float, dueToScrubing: Bool = false) {
        if dueToScrubing {
            progressBar.progress = (progressWhentouchBeganCalled + progress)
            let newSliderValue =  slidersValueWhentouchBeganCalled + CGFloat(progress * 1720)
            if newSliderValue >= 0 && newSliderValue <= 1720 {
                sliderLeading.constant = (slidersValueWhentouchBeganCalled + CGFloat(progress * 1720))
            }
            else if newSliderValue < 0 {
                sliderLeading.constant = 0
            }
            else if newSliderValue > 1720 {
                sliderLeading.constant = 1720
            }
        } else {
            progressBar.progress = progress
            sliderLeading.constant = (CGFloat(progress) * 1720)
        }
        progressBar.setProgress(progressBar.progress, animated: true)
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if press.type == .playPause{
                if !isPaused {
                    delegate?.playTapped(false)
                } else {
                    delegate?.playTapped(true)
                }
                isPaused = !isPaused
            }
        }
        
    }
    
}

