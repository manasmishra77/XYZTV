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
    var playerSubtitles: String?
    var playerAudios: String?
    var recommendationArray: Any = false
    
    @IBOutlet weak var playerHolder: UIView!
    var viewforplayer: CustomPlayerView?
    
    init(item: Item, subtitles: String? = nil, audios: String? = nil) {
        self.playerItem = item
        self.playerAudios = audios
        self.playerSubtitles = subtitles
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(PlayerViewController.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
        
        self.configureView()
    }
    
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        
        if viewforplayer?.controlDetailView.isHidden == false {
            viewforplayer!.removeControlDetailview()
        }
        else {
            DispatchQueue.main.async {
                self.viewforplayer?.resetAndRemovePlayer()
                self.removePlayerController()
            }
        }
    }
    
    func configureView() {
        viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomPlayerView
        viewforplayer?.frame = playerHolder.bounds
        playerHolder.addSubview(viewforplayer!)
        viewforplayer?.delegate = self
        viewforplayer?.recommendationArray = self.recommendationArray
        viewforplayer?.configureView(item: self.playerItem!, subtitles: self.playerSubtitles, audios: self.playerAudios)
    }
}


extension PlayerViewController: CustomPlayerViewProtocol {
    func removePlayerController() {
        self.dismiss(animated: false) {
            
        }
    }
}
