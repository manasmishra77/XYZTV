//
//  JCTabBarController.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCTabBarController: UITabBarController {
    
    enum VideoType:Int
    {
        case Movie = 0
        case Music = 2
        case TVShow = 1
        case Clip = 6
    }
    
    var settingsVC:JCSettingsVC?
    var currentPlayableItem:Item?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: cellTapNotificationName, object: nil, queue: nil, using: didReceiveNotificationForCellTap(notification:))
        NotificationCenter.default.addObserver(self, selector: #selector(prepareToPlay), name: readyToPlayNotificationName, object: nil)
        
        let homeVC = JCHomeVC.init(nibName: "JCBaseVC", bundle: nil)
        homeVC.tabBarItem = UITabBarItem.init(title: "Home", image: nil, tag: 0)
        
        let moviesVC = JCMoviesVC.init(nibName: "JCBaseVC", bundle: nil)
        moviesVC.tabBarItem = UITabBarItem.init(title: "Movies", image: nil, tag: 1)
        
        let tvVC = JCTVVC.init(nibName: "JCBaseVC", bundle: nil)
        tvVC.tabBarItem = UITabBarItem.init(title: "TV", image: nil, tag: 2)
        
        let musicVC = JCMusicVC.init(nibName: "JCBaseVC", bundle: nil)
        musicVC.tabBarItem = UITabBarItem.init(title: "Music", image: nil, tag: 3)
        
        let clipsVC = JCClipsVC.init(nibName: "JCBaseVC", bundle: nil)
        clipsVC.tabBarItem = UITabBarItem.init(title: "Clips", image: nil, tag: 4)
        
        settingsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsVCStoryBoardId) as? JCSettingsVC
        settingsVC?.tabBarItem = UITabBarItem.init(title: "Settings", image: nil, tag: 5)
        
        let viewControllersArray = [homeVC,moviesVC,tvVC,musicVC,clipsVC,settingsVC!] as [Any]
        self.setViewControllers(viewControllersArray as? [UIViewController], animated: false)
        
        self.tabBar.alpha = 0.7
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func didReceiveNotificationForCellTap(notification:Notification) -> Void
    {
        weak var weakSelf = self
        guard let item = notification.userInfo?["item"] as? Item
            else {
                JCLoginManager.sharedInstance.performNetworkCheck { (isOnJioNetwork) in
                    if(isOnJioNetwork == false)
                    {
                        print("Not on jio network")
                        weakSelf?.presentLoginVC()
                        
                    }
                }
                return
        }
        currentPlayableItem = item

        
        //if metadata is to be shown, show it here, else, proceed with the below flow
        if(currentPlayableItem?.app?.type == VideoType.Movie.rawValue || currentPlayableItem?.app?.type == VideoType.TVShow.rawValue)
        {
            showMetadata()
        }
        else
        {
            if(JCLoginManager.sharedInstance.isUserLoggedIn())
            {
                JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
                weakSelf?.prepareToPlay()
            }
            else
            {
                JCLoginManager.sharedInstance.performNetworkCheck { (isOnJioNetwork) in
                    if(isOnJioNetwork == false)
                    {
                        print("Not on jio network")
                        weakSelf?.presentLoginVC()
                        
                    }
                    else
                    {
                        //proceed without checking any login
                        weakSelf?.prepareToPlay()
                        print("Is on jio network")
                    }
                }
            }
        }
    }
    
    
    func showMetadata()
    {
        print("show metadata")
        let metadataVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
        metadataVC.item = currentPlayableItem
        metadataVC.modalPresentationStyle = .overFullScreen
        metadataVC.modalTransitionStyle = .coverVertical
        self.present(metadataVC, animated: false, completion: nil)
    }
    
    func prepareToPlay()
    {
        if currentPlayableItem != nil
        {
        print("play video")
        
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        playerVC.callWebServiceForPlaybackRights(id: (currentPlayableItem?.id!)!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        self.present(playerVC, animated: false, completion: nil)
        }
        else
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            settingsVC?.settingsTableView.reloadData()
            return
        }
    }
    
    
    func presentLoginVC()
    {
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: loginVCStoryBoardId)
        loginVC.modalPresentationStyle = .overFullScreen
        loginVC.modalTransitionStyle = .coverVertical
        loginVC.view.layer.speed = 0.7
        self.present(loginVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

