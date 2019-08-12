//
//  CircleView.swift
//  JioCinema
//
//  Created by Sneha Harke on 13/02/19.
//  Copyright © 2019 Reliance Jio. All rights reserved.
//

import UIKit

class SpiralSpinner: UIView {

    private var foregroundColor = UIColor.green
    private var lineWidth: CGFloat = 3.0
    
    private var isAnimating = false {
        didSet {
            if isAnimating {
                self.isHidden = false
                self.rotate360Degrees(duration: 1.0)
            } else {
                self.isHidden = true
                self.layer.removeAllAnimations()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(spinnerColor: nil, newFrame: nil, spinnerWidth: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(spinnerColor: nil, newFrame: nil, spinnerWidth: nil)
    }
    
    func setup(spinnerColor: UIColor?, newFrame: CGRect?, spinnerWidth: CGFloat?) {
        self.backgroundColor = .clear
        if let newFrame = newFrame {
            self.frame = newFrame
        }
        if let spinnerColor = spinnerColor {
            foregroundColor = spinnerColor
        }
        if let spinnerWidth = spinnerWidth {
            lineWidth = spinnerWidth
        }
        setNeedsDisplay()
    }
    
    func spinningAnimation(shouldStart: Bool) {
        self.isAnimating = shouldStart
    }
    
    override func draw(_ rect: CGRect) {
        let width = bounds.width
        let height = bounds.height
        let radius = (min(width, height) - lineWidth) / 2.0
        
        var currentPoint = CGPoint(x: width/2 + radius, y: height/2)
        var priorAngle = CGFloat(360)
        
        for angle in stride(from: CGFloat(360), through: 0, by: -20) {
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            
            path.move(to: currentPoint)
            currentPoint = CGPoint(x: width / 2.0 + cos(angle * .pi / 180.0) * radius, y: height / 2.0 + sin(angle * .pi / 180.0) * radius)
            path.addArc(withCenter: CGPoint(x: width / 2.0, y: height / 2.0), radius: radius, startAngle: priorAngle * .pi / 180.0 , endAngle: angle * .pi / 180.0, clockwise: false)
            priorAngle = angle
           // print("-----------\(angle)")
            foregroundColor.withAlphaComponent(angle/360.0).setStroke()
            path.stroke()
        }
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 4) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = HUGE
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
