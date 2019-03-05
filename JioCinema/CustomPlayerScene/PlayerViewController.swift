//
//  ViewController.swift
//  CustomPlayer
//
//  Created by Shweta Adagale on 26/02/19.
//  Copyright © 2019 Shweta Adagale. All rights reserved.
//

import UIKit
import Foundation

class PlayerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    func configureView() {
        let viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! CustomPlayerView
        if let path = Bundle.main.path(forResource: "SampleVideo", ofType: "mp4"){
            let url = URL(fileURLWithPath: path)
            viewforplayer.configureView(url: url, superView: self.view)
            viewforplayer.addAsSubViewWithConstraints(self.view, top: 0, bottom: 0, leading: 0, trailing: 0)
        }
    }
}

extension UIView {
    func addConstraintsToViewForPlayer(_ superView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
    }
}
