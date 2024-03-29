//
//  File.swift
//  JioCinema
//
//  Created by Shweta Adagale on 05/03/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol SliderDelegate: NSObject {
    func updateProgressBar(scale: CGFloat, dueToScrubing: Bool, duration: Double?)
    func touchBeganCalledSetSliderValue()
    func pressesBeganCalled()
    func sliderTouchEnded()
}

class JCSliderButton: UIButton
{
    weak var delegate : SliderDelegate?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count > 1 {
            return
        }
        delegate?.touchBeganCalledSetSliderValue()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if self.isFocused {
                let startingPoint: CGFloat = 960
                let maxDisplacement: CGFloat = 1920
                var displacement : CGFloat = 0.0
                displacement = (touch.location(in: self.superview).x - startingPoint)
                let scale = displacement / maxDisplacement
                delegate?.updateProgressBar(scale: scale / 4, dueToScrubing: true, duration: nil)
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.sliderTouchEnded()
    }
    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesCancelled")
//    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type{
            case .select:
                delegate?.pressesBeganCalled()
            default:
                print("default")
            }
        }
    }
}
