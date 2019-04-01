//
//  AutoScrollLabel.swift
//  JioCinema
//
//  Created by Vinit Somani on 12/11/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class AutoScrollLabel: UIView {
    
    var textLabel: UILabel?
    var timer: Timer?
    
//    func setLabel(text: String, fontName: UIFont, textColor: UIColor, alignment: NSTextAlignment) {
//
//    }
    
    func setLabelFont(font: UIFont) {
    textLabel?.font = font
    }
    
    func setLabelTextColor(color: UIColor) {
    textLabel?.textColor = color
    }
    
    func setLabelTextAlignment(alignment: NSTextAlignment) {
    textLabel?.textAlignment = alignment
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

            self.clipsToBounds = true
            self.autoresizesSubviews = true
            
        textLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        textLabel?.backgroundColor = .blue
        textLabel?.textColor = .black
        textLabel?.textAlignment = NSTextAlignment.left
        if textLabel == nil {
            return
        }
        self.addSubview(textLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  Converted to Swift 4 by Swiftify v4.2.20547 - https://objectivec2swift.com/
    func setLabelText(_ text: String?) {
        
        guard let textLabel = self.textLabel else {
            return
        }
        textLabel.text = text
        let textSize: CGSize? = text?.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
        
        
        if (textSize?.width ?? 0.0) > self.frame.size.width {
            textLabel.frame = CGRect(x: 0, y: 0, width: textSize?.width ?? 0.0, height: self.frame.size.height)
        } else {
            textLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
        
        if textLabel.frame.size.width > self.frame.size.width {
            
            timer?.invalidate()
            timer = nil
            var frame: CGRect = textLabel.frame
            frame.origin.x = self.frame.size.width - 50
            textLabel.frame = frame
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.moveText), userInfo: nil, repeats: true)
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    
    @objc func moveText() {
        guard let textLabel = self.textLabel else {
            return
        }
        if textLabel.frame.origin.x < textLabel.frame.size.width - 2 * textLabel.frame.size.width {
            var frame: CGRect = textLabel.frame
            frame.origin.x = self.frame.size.width
            textLabel.frame = frame
        }
        UIView.beginAnimations(nil, context: nil)
        var frame: CGRect = textLabel.frame
        frame.origin.x -= 5
        textLabel.frame = frame
        UIView.commitAnimations()
        
    }
    

    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
