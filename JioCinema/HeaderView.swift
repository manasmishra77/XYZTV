//
//  HeaderView.swift
//  JioCinema
//
//  Created by Shweta Adagale on 18/07/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    @IBOutlet weak var imageViewForHeader: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: HeaderButtons!
    @IBOutlet weak var moreInfoButton: HeaderButtons!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        let colorLayer = CAGradientLayer()
        colorLayer.frame = imageViewForHeader.bounds
        colorLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.9).cgColor]
        colorLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        colorLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        self.imageViewForHeader.layer.insertSublayer(colorLayer, at:0)
    }

}
