//
//  IndicatorManager.swift
//  JioCinema
//
//  Created by Manas Mishra on 14/02/19.
//  Copyright © 2019 Reliance Jio. All rights reserved.
//

import UIKit
typealias IndexInNewSpinnerViewArray = Int

class IndicatorManager: NSObject {
    static let shared = IndicatorManager()
    var spinnerView: SpiralSpinner?
    var coverLayerView: UIView?
    
    var newSpinnerViews: [SpiralSpinner] = []
    
    private override init() {
        super.init()
    }
    
    func setUpIndicator() {
        spinnerView = SpiralSpinner(frame: CGRect.zero)
    }
    
    
    //Used for shared spinner
    func startAnimatingIndicator(spinnerColor: UIColor = .white, superView: UIView, superViewSize: CGSize? = nil, spinnerSize: CGSize = CGSize(width: 100, height: 100), spinnerWidth: CGFloat = 5, superViewUserInteractionEnabled: Bool, shouldUseCoverLayer: Bool, coverLayerOpacity: CGFloat? = nil, coverLayerColor: UIColor? = nil) {
        spinnerView?.spinningAnimation(shouldStart: false)
        coverLayerView?.removeFromSuperview()
        spinnerView?.removeFromSuperview()
        coverLayerView = nil
        let spinnerOrigin = CGPoint(x: superView.frame.width/2-spinnerSize.width/2, y: superView.frame.height/2-spinnerSize.height/2)
        let spinnerFrame = CGRect(origin: spinnerOrigin, size: spinnerSize)
        let spinnerYPatch = (superView.frame.height - (superViewSize?.height ?? superView.frame.height))/2
        let spinnerXPatch = (superView.frame.width - (superViewSize?.width ?? superView.frame.width))/2
        spinnerView?.setup(spinnerColor: spinnerColor, newFrame: spinnerFrame, spinnerWidth: spinnerWidth)
        guard let spinnerView = spinnerView else {return}
        if shouldUseCoverLayer {
            let newCoverLayerView = UIView(frame: superView.bounds)
            newCoverLayerView.backgroundColor = coverLayerColor ?? .black
            newCoverLayerView.alpha = coverLayerOpacity ?? 1.0
            let overLayTopConstarint = superView.frame.height - (superViewSize?.height ?? superView.frame.height)
            newCoverLayerView.addAsSubViewWithConstraints(superView, top: overLayTopConstarint)
            superView.bringSubviewToFront(newCoverLayerView)
            coverLayerView = newCoverLayerView
        }
        superView.addSubview(spinnerView)
        spinnerView.addFourConstraintsAlignMentAndSize(superView, size: spinnerSize, xAlignment: spinnerXPatch, yAlignment: spinnerYPatch)
        superView.bringSubviewToFront(spinnerView)
        spinnerView.spinningAnimation(shouldStart: true)
        superView.isUserInteractionEnabled = superViewUserInteractionEnabled
    }
    func stopAnimation() {
        spinnerView?.superview?.isUserInteractionEnabled = true
        spinnerView?.spinningAnimation(shouldStart: false)
        spinnerView?.removeFromSuperview()
        coverLayerView?.removeFromSuperview()
        coverLayerView = nil
    }
    
    //Used for adding new and independenet spinner
    func addAndStartAnimatingANewIndicator(spinnerColor: UIColor = .darkGray, superView: UIView, superViewSize: CGSize? = nil, spinnerSize: CGSize = CGSize(width: 100, height: 100), spinnerWidth: CGFloat = 5, superViewUserInteractionEnabled: Bool, shouldUseCoverLayer: Bool, coverLayerOpacity: CGFloat? = nil, coverLayerColor: UIColor? = nil) -> SpiralSpinner {
        let newSpinnerView = SpiralSpinner(frame: CGRect.zero)
        let spinnerOrigin = CGPoint(x: superView.frame.width/2-spinnerSize.width/2, y: superView.frame.height/2-spinnerSize.height/2)
        let spinnerFrame = CGRect(origin: spinnerOrigin, size: spinnerSize)
        let spinnerYPatch = (superView.frame.height - (superViewSize?.height ?? superView.frame.height))/2
        let spinnerXPatch = (superView.frame.width - (superViewSize?.width ?? superView.frame.width))/2
        newSpinnerView.setup(spinnerColor: spinnerColor, newFrame: spinnerFrame, spinnerWidth: spinnerWidth)
        if shouldUseCoverLayer {
            let newCoverLayerView = UIView(frame: superView.bounds)
            newCoverLayerView.backgroundColor = coverLayerColor
            newCoverLayerView.alpha = coverLayerOpacity ?? 1.0
            newCoverLayerView.tag = 70
            let overLayTopConstarint = superView.frame.height - (superViewSize?.height ?? superView.frame.height)
            newCoverLayerView.addAsSubViewWithConstraints(superView, top: overLayTopConstarint)
            superView.bringSubviewToFront(newCoverLayerView)
        }
        superView.addSubview(newSpinnerView)
        newSpinnerView.addFourConstraintsAlignMentAndSize(superView, size: spinnerSize, xAlignment: spinnerXPatch, yAlignment: spinnerYPatch)
        superView.bringSubviewToFront(newSpinnerView)
        superView.isUserInteractionEnabled = superViewUserInteractionEnabled
        newSpinnerView.spinningAnimation(shouldStart: true)
        return newSpinnerView
    }
    func stopSpinningIndependent(spinnerView: SpiralSpinner?) {
        guard let spinner = spinnerView else {return}
        spinner.superview?.isUserInteractionEnabled = true
        spinner.superview?.viewWithTag(70)?.removeFromSuperview()
        spinner.spinningAnimation(shouldStart: false)
        spinner.removeFromSuperview()
    }

}
