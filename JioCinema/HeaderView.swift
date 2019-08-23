//
//  HeaderView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 18/07/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func playButtonTapped()
    func moreInfoButtonTapped()
}

class HeaderView: UIView {

    @IBOutlet weak var maturityRating: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var topConstraintOfDescription: NSLayoutConstraint!
    @IBOutlet weak var imageViewForHeader: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: HeaderButtons!
    @IBOutlet weak var moreInfoButton: HeaderButtons!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var heightOfMoreIfoButton: NSLayoutConstraint!
    var gradientColor : UIColor = ThemeManager.shared.backgroundColor
    
    weak var headerViewDelegate: HeaderViewDelegate?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
   */
     @IBAction func playButtonTapped(_ sender: Any) {
        if let delegate = headerViewDelegate {
            delegate.playButtonTapped()
        }
     }
 
    @IBAction func moreInfoButtonTapped(_ sender: Any) {
        if let delegate = headerViewDelegate {
             delegate.moreInfoButtonTapped()
        }
    }
    
    func addGradientToHeader(color: UIColor) {
        let gradientLayer:CAGradientLayer = CAGradientLayer()

        var colors = [color.cgColor, color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0.5).cgColor, color.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        var startPoint = CGPoint(x: 0.0, y: 1.0)
        var endPoint = CGPoint(x: 1.0, y: 1.0)
        Utility.applyGradient(imageViewForHeader, startPoint: startPoint, endPoint: endPoint, colorArray: colors, atIndex: 1)
        
//        colors = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor, color.withAlphaComponent(0.5).cgColor, color.cgColor]
        colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, color.cgColor ]
//        startPoint = CGPoint(x: 0.0, y: 1.0)
//        endPoint = CGPoint(x: 0.0, y: 0.0)

        Utility.applyGradient(imageViewForHeader, colorArray: colors)
    }
}
