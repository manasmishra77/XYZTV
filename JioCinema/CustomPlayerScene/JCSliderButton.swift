//
//  File.swift
//  JioCinema
//
//  Created by Shweta Adagale on 05/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit
protocol SliderDelegate {
    func updateProgressBar(progress: Float,dueToScrubing: Bool)
    func touchBeganCalledSetSliderValue()
}
class JCSliderButton: UIButton
{
    var delegate : SliderDelegate?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            return
        }
        delegate?.touchBeganCalledSetSliderValue()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesEnded")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if self.isFocused {
                let startingPoint: CGFloat = 960
                let maxDisplacement: CGFloat = 1920
                var displacement : CGFloat = 0.0
                displacement = (touch.location(in: self.superview).x - startingPoint)
                let scale = displacement / maxDisplacement
                delegate?.updateProgressBar(progress: Float(scale/4), dueToScrubing: true)
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesCancelled")
    }
}
