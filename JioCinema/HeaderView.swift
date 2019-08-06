//
//  HeaderView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 18/07/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    @IBOutlet weak var topConstraintOfDescription: NSLayoutConstraint!
    @IBOutlet weak var imageViewForHeader: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: HeaderButtons!
    @IBOutlet weak var moreInfoButton: HeaderButtons!
    @IBOutlet weak var descriptionLabel: UILabel!
    var gradientColor : UIColor = ThemeManager.shared.backgroundColor
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func addGradientToHeader(color: UIColor) {
//        var colors = [UIColor.clear.cgColor, color.withAlphaComponent(0.5).cgColor, color.cgColor]
//        var startPoint = CGPoint(x: 1.0, y: 0.0)
//        var endPoint = CGPoint(x: 0.0, y: 0.0)
//        Utility.applyGradient(imageViewForHeader, startPoint: startPoint, endPoint: endPoint, colorArray: colors)
//        
//        colors = [UIColor.clear.cgColor, color.withAlphaComponent(0.5).cgColor, color.cgColor]
//        endPoint = CGPoint(x: 0.0, y: 1.0)
//        startPoint = CGPoint(x: 0.0, y: 0.0)
//        Utility.applyGradient(imageViewForHeader, startPoint: startPoint, endPoint: endPoint, colorArray: colors, atIndex: 1)
    }
}
