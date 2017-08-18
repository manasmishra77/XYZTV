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
    var currentPlayableItem:Any?
    var isCurrentItemEpisode = false
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
        if let item = notification.userInfo?["item"] as? Item
        {
        currentPlayableItem = item
            isCurrentItemEpisode = false
        }
            else if let item = notification.userInfo?["item"] as? Episode
        {
            currentPlayableItem = item
            isCurrentItemEpisode = true
        }
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
        

        //if metadata is to be shown, show it here, else, proceed with the below flow
        
        if !isCurrentItemEpisode
        {
            if (currentPlayableItem as! Item).app?.type == VideoType.Movie.rawValue || (currentPlayableItem as! Item).app?.type == VideoType.TVShow.rawValue
            {
                showMetadata()
            }
            else
            {
                weakSelf?.checkLoginAndPlay()
            }
        }
        else
        {
            weakSelf?.checkLoginAndPlay()
        }
    }
    
    func checkLoginAndPlay()
    {
        weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            prepareToPlay()
        }
        else
        {
            JCLoginManager.sharedInstance.performNetworkCheck { (isOnJioNetwork) in
                if(isOnJioNetwork == false)
                {
                    print("Not on jio network")
                    NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: nil)
                    
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
    
    func showMetadata()
    {
        print("show metadata")
        let metadataVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
        metadataVC.item = currentPlayableItem as? Item
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
            
            if isCurrentItemEpisode
            {
                playerVC.callWebServiceForPlaybackRights(id: ((currentPlayableItem as! Episode).id!))
            }
            else
            {
                playerVC.callWebServiceForPlaybackRights(id: ((currentPlayableItem as! Item).id!))
            }
        
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        let playerItem = ["player":playerVC]
        NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: playerItem)
            
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

