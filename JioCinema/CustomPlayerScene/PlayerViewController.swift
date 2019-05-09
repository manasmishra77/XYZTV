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
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(PlayerViewController.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        self.view.addGestureRecognizer(menuPressRecognizer)
        
        self.configureCustomPlayerViewView()
    }
    
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        if viewforplayer?.popUpHolderView.isHidden == false {
            viewforplayer!.removeControlDetailview(forOkButtonClick: false)
            if viewforplayer?.stateOfPlayerBeforeOkButtonClickIsPaused ?? false {
                viewforplayer?.player?.pause()
            } else {
                viewforplayer?.player?.play()
            }
        }
        else {
            DispatchQueue.main.async {
                self.viewforplayer?.resetAndRemovePlayer()
                self.removePlayerController()
            }
        }
    }
    
    func configureCustomPlayerViewView() {
        viewforplayer = UINib(nibName: "CustomPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? CustomPlayerView
        viewforplayer?.frame = playerHolder.bounds
        playerHolder.addSubview(viewforplayer!)
        viewforplayer?.delegate = self
        viewforplayer?.recommendationArray = self.recommendationArray
        viewforplayer?.isDisney = self.isDisney
        viewforplayer?.configureView(item: self.playerItem!, latestEpisodeId: self.latestEpisodeId,audioLanguage: self.audioLanguage)
        viewforplayer?.audioLanguage = self.audioLanguage
    }

    deinit {
        print("playerVC deinit called")
    }
}


extension PlayerViewController: CustomPlayerViewProtocol {
    func presenMetadataOnMoreLikeTapped(item: Item) {
        //Present Metadata
        if let metaDataVC = self.presentingViewController as? JCMetadataVC {
            metaDataVC.isUserComingFromPlayerScreen = true
            metaDataVC.item = item
            self.dismiss(animated: true, completion: {
                metaDataVC.callWebServiceForMetadata(id: item.id ?? "", newAppType: item.appType)
            })
        } else if let navVc = self.presentingViewController as? UINavigationController, let sideNavigationVC = navVc.viewControllers.first as? SideNavigationVC, let homeVc = sideNavigationVC.selectedVC as? BaseViewController {
            homeVc.isMetadataScreenToBePresentedFromResumeWatchCategory = true
            self.dismiss(animated: false, completion: {
                let metaVc = Utility.sharedInstance.prepareMetadata(item.id ?? "", appType: .Movie, fromScreen: PLAYER_SCREEN, categoryName: RECOMMENDATION, categoryIndex: 0, tabBarIndex: 0, isDisney: self.isDisney)
                metaVc.item = item
                homeVc.present(metaVc, animated: false, completion: nil)
            })
        }
    }
    
    func removePlayerAfterAesFailure() {
        let alert = UIAlertController(title: "Unable to process your request right now", message: "", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            DispatchQueue.main.async {
                self.removePlayerController()
            }
        }
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    func removePlayerController() {
        self.dismiss(animated: false) {
        }
    }
    
}
