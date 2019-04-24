//
//  ControlsView.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 27/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//
import UIKit
import Foundation

protocol CustomSliderProtocol: NSObjectProtocol {
    func seekPlayerTo(pointX: CGFloat)
    func cancelTimerForHideControl()
    func resetTimerForShowControl()
}

class CustomSlider: UIView {
    @IBOutlet weak var sliderLeading: NSLayoutConstraint!
    @IBOutlet weak var sliderLeadingForSeeking: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var backgroundFocusableButton: JCSliderButton!
    @IBOutlet weak var endingTime: UILabel!
    @IBOutlet weak var sliderCursor: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var sliderCursorForSeeking: UIButton!
    @IBOutlet weak var seekTime: UILabel!
    @IBOutlet weak var heightOfProgressBar: NSLayoutConstraint!
    
    weak var sliderDelegate: CustomSliderProtocol?
    
    var itemDuration: Double?
    var durationString: String = ""
    var isPaused = false
    
//    let kTimeFormatInMinutes = DateFormatter()
//    let hourFormat = DateFormatter()
    var slidersValueWhentouchBeganCalled: CGFloat = 0.0
    var timeWhentouchBeganCalled: Double = 0.0
    var progressWhentouchBeganCalled: CGFloat = 0.0
    var widthOfProgressBar: CGFloat = 1720
    var widthOfSlider: CGFloat = 30
    
    func configureControls() {
//        kTimeFormatInMinutes.dateFormat = "mm:ss"
//        hourFormat.dateFormat = "HH:mm:ss"
        hideThumbnails(requrestToHide: true)
        self.clipsToBounds = true
        progressBar.progress = 0.0
        progressBar.tintColor = ViewColor.selectionBarOnLeftNavigationColor
        backgroundFocusableButton.delegate = self
    }
    deinit {
        print("Custom slider deinit called")
    }
    
}

extension CustomSlider: SliderDelegate {
    func sliderTouchEnded() {
        sliderDelegate?.resetTimerForShowControl()
    }
    
    func pressesBeganCalled() {
        if backgroundFocusableButton.isFocused {
            sliderLeading.constant = sliderLeadingForSeeking.constant
            sliderDelegate?.seekPlayerTo(pointX: CGFloat(sliderLeading.constant/(self.widthOfProgressBar)))
            hideThumbnails(requrestToHide: true)
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        hideThumbnails(requrestToHide: true)
        if context.nextFocusedView == self.backgroundFocusableButton{
            self.sliderCursor.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            self.sliderCursor.backgroundColor = .white
            self.heightOfProgressBar.constant = 10
        } else {
            self.sliderLeadingForSeeking.constant = self.sliderLeading.constant
            self.sliderCursor.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.sliderCursor.backgroundColor = .darkGray
            self.heightOfProgressBar.constant = 5
        }
    }
    
    func updateProgressBar(scale: CGFloat, dueToScrubing: Bool = false, duration: Double?) {
        let maxLeading : CGFloat = widthOfProgressBar// - widthOfSlider
        if duration != nil{
            self.itemDuration = duration
        }
        if dueToScrubing {
            hideThumbnails(requrestToHide: false)
            //progressBar.progress = (progressWhentouchBeganCalled + progress)
            let newSliderValue =  CGFloat(slidersValueWhentouchBeganCalled) + scale * maxLeading
            if newSliderValue >= 0 && newSliderValue <= maxLeading {
                sliderLeadingForSeeking.constant = (slidersValueWhentouchBeganCalled + CGFloat(scale * maxLeading))
                let scaleToCalculateseconds : Double = Double(sliderLeadingForSeeking.constant / maxLeading)
                let seconds = scaleToCalculateseconds * (itemDuration ?? 0)
                seekTime.text = Utility.getTimeInFormatedStringFromSeconds(seconds: Int(seconds))
                
            }
            else if newSliderValue < 0 {
                sliderLeadingForSeeking.constant = 0
                seekTime.text = "00:00"
            }
            else if newSliderValue > maxLeading {
                sliderLeadingForSeeking.constant = CGFloat(maxLeading)
                seekTime.text = Utility.getTimeInFormatedStringFromSeconds(seconds: Int(itemDuration ?? 0))
//                print(Utility.getTimeInFormatFromSeconds(seconds: Int(itemDuration)))
            }
        } else {
            progressBar.progress = Float(scale)
            sliderLeading.constant = (CGFloat(scale) * CGFloat(maxLeading))
        }
        progressBar.setProgress(progressBar.progress, animated: true)
    }
    func touchBeganCalledSetSliderValue() {
        slidersValueWhentouchBeganCalled = sliderLeadingForSeeking.constant
        progressWhentouchBeganCalled = CGFloat(progressBar.progress)
        sliderDelegate?.cancelTimerForHideControl()
    }
    func hideThumbnails(requrestToHide: Bool) {
        title.isHidden = !requrestToHide
        endingTime.isHidden = !requrestToHide
        sliderCursorForSeeking.isHidden = requrestToHide
        seekTime.isHidden = requrestToHide
    }
    
}
