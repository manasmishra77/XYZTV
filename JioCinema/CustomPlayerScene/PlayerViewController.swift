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
    var playerItem: Item?
    
    @IBOutlet weak var playerHolder: UIView!
    var viewforplayer: CustomPlayerView?
    
    init(item: Item) {
        self.playerItem = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(PlayerViewController.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
        
        self.configureView()
    }
    
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.viewforplayer?.resetAndRemovePlayer()
            self.removePlayerController()
        }
        print("do nothing")
    }
    
    func configureView() {
        viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomPlayerView
        viewforplayer?.frame = playerHolder.frame
        playerHolder.addSubview(viewforplayer!)
        viewforplayer?.delegate = self
        viewforplayer?.configureView(item: self.playerItem!)
    }
    
    deinit {
        print("2 inside player controller deinit")
    }
}


extension PlayerViewController: CustomPlayerViewProtocol {
    func removePlayerController() {
        self.dismiss(animated: false) {
            
        }
    }
}
