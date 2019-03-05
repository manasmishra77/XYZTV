//
//  ControlsView.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 27/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//
import UIKit
import Foundation

class CustomSlider: UIView {
    @IBOutlet weak var sliderLeading: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var backgroundFocusableButton: JCSliderButton!
    @IBOutlet weak var staringTime: UILabel!
    @IBOutlet weak var endingTime: UILabel!
    @IBOutlet weak var sliderCursor: UIButton!
    
    var isPaused = false
    
    var slidersValueWhentouchBeganCalled: CGFloat = 0.0
    var progressWhentouchBeganCalled: Float = 0.0
    var widthOfProgressBar: Float = 1720
    var widthOfSlider: Float = 30
    
    func configureControls() {
//        endingTime.text = "\(duration)"
        self.clipsToBounds = true
        progressBar.progress = 0.0
        progressBar.tintColor = .red
        backgroundFocusableButton.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ghsva")
    }
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        for press in presses {
//            if press.type == .playPause{
//                if !isPaused {
//                    delegate?.playTapped(false)
//                } else {
//                    delegate?.playTapped(true)
//                }
//                isPaused = !isPaused
//            }
//        }
//
//    }
    
}
extension CustomSlider: SliderDelegate{
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self.backgroundFocusableButton{
                self.sliderCursor.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.sliderCursor.backgroundColor = .lightGray
            
        } else {
            self.sliderCursor.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.sliderCursor.backgroundColor = .darkGray
        }
    }
    func updateProgressBar(progress: Float, dueToScrubing: Bool = false) {
        let maxLeading : Float = widthOfProgressBar - widthOfSlider
        if dueToScrubing {
            progressBar.progress = (progressWhentouchBeganCalled + progress)
            let newSliderValue: Float =  Float(slidersValueWhentouchBeganCalled) + progress * maxLeading
            if newSliderValue >= 0 && newSliderValue <= maxLeading {
                sliderLeading.constant = (slidersValueWhentouchBeganCalled + CGFloat(progress * maxLeading))
            }
            else if newSliderValue < 0 {
                sliderLeading.constant = 0
            }
            else if newSliderValue > maxLeading {
                sliderLeading.constant = CGFloat(maxLeading)
            }
        } else {
            progressBar.progress = progress
            sliderLeading.constant = (CGFloat(progress) * CGFloat(maxLeading))
        }
        progressBar.setProgress(progressBar.progress, animated: true)
    }
    func touchBeganCalledSetSliderValue() {
        slidersValueWhentouchBeganCalled = sliderLeading.constant
        progressWhentouchBeganCalled = progressBar.progress
    }
}
