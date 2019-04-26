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
    var latestEpisodeId: String?
    var recommendationArray: Any = false
    var isDisney: Bool = false
    var audioLanguage: AudioLanguage?
    
    @IBOutlet weak var playerHolder: UIView!
    var viewforplayer: CustomPlayerView?
    
    init(item: Item, isDisney: Bool = false, latestEpisodeId: String? = nil) {
        self.playerItem = item
        self.isDisney = isDisney
        self.latestEpisodeId = latestEpisodeId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        //        let menuPressRecognizer = UITapGestureRecognizer()
        //        menuPressRecognizer.addTarget(self, action: #selector(PlayerViewController.menuButtonAction(recognizer:)))
        //        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        //        self.view.addGestureRecognizer(menuPressRecognizer)
        
        self.configureCustomPlayerViewView()
    }
    
    func configureCustomPlayerViewView() {
        viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomPlayerView
        viewforplayer?.frame = playerHolder.bounds
        playerHolder.addSubview(viewforplayer!)
        viewforplayer?.delegate = self
        viewforplayer?.recommendationArray = self.recommendationArray
        viewforplayer?.isDisney = self.isDisney
        viewforplayer?.configureView(item: self.playerItem!, latestEpisodeId: self.latestEpisodeId,audioLanguage: self.audioLanguage)
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            switch press.type{
            case .downArrow, .leftArrow, .upArrow, .rightArrow:
                print("downArrow")
            case .menu:
                print("menu")
                menuButtonAction()
            case .playPause:
                print("playPause")
            case .select:
                print("select")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    //modificationNeeded
    //    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
    func menuButtonAction() {
        
        if viewforplayer?.popUpHolderView.isHidden == false {
            //viewforplayer!.removeControlDetailview()
            viewforplayer?.popUpHolderView.isHidden = true
        } else if viewforplayer?.controlsView?.isHidden ?? false{
            
        } else {
            DispatchQueue.main.async {
                self.viewforplayer?.resetAndRemovePlayer()
                self.removePlayerController()
            }
        }
    }

    deinit {
        print("playerVC deinit called")
    }
}


extension PlayerViewController: CustomPlayerViewProtocol {
    func removePlayerController() {
        self.dismiss(animated: false) {
        }
    }
    
}
