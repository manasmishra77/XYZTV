//
//  JCTabBarController.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import ReachabilitySwift

var currentPlayableItem:Any?

class JCTabBarController: UITabBarController {
    
      
    var settingsVC:JCSettingsVC?
    
    var isCurrentItemEpisode = false
    var reachability:Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabBarTitle()
        startNetworkNotifier()
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
        
        
        let searchVC = JCSearchVC.init(nibName: "JCBaseVC", bundle: nil)
        searchVC.view.backgroundColor = .black
        
        let searchViewController = UISearchController.init(searchResultsController: searchVC)
        searchViewController.view.backgroundColor = .black
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.searchBar.tintColor = UIColor.white
        searchViewController.searchBar.barTintColor = UIColor.black
        searchViewController.searchBar.tintColor = UIColor.gray
        searchViewController.hidesNavigationBarDuringPresentation = true
        searchViewController.obscuresBackgroundDuringPresentation = false
        searchViewController.searchBar.delegate = searchVC
        searchViewController.searchBar.searchBarStyle = .minimal
        searchVC.searchViewController = searchViewController
        let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        searchContainerController.view.backgroundColor = UIColor.black
                searchContainerController.tabBarItem = UITabBarItem.init(title: "Search", image: nil, tag: 5)

        settingsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsVCStoryBoardId) as? JCSettingsVC
        settingsVC?.tabBarItem = UITabBarItem.init(title: "Settings", image: nil, tag: 6)
        
        let viewControllersArray = [homeVC, moviesVC, tvVC, musicVC, clipsVC, searchContainerController, settingsVC!] as [Any]
        self.setViewControllers(viewControllersArray as? [UIViewController], animated: false)
        
        self.tabBar.alpha = 0.7
        
        // Do any additional setup after loading the view.
    }
    
    
    func setTabBarTitle()
    {
        let tabBarTitleLabel = UILabel.init(frame: CGRect(x: 50.0, y: 0.0, width: 300.0, height: 135.0))
        
        tabBarTitleLabel.text = "JioCinema"
        tabBarTitleLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 56.0)
        tabBarTitleLabel.textColor = UIColor.white
        self.tabBar.addSubview(tabBarTitleLabel)
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
            if item.app?.type == VideoType.Language.rawValue || item.app?.type == VideoType.Genre.rawValue
            {
                presentLanguageGenreController(item: item)
                return
            }
            else
            {
                currentPlayableItem = item
                isCurrentItemEpisode = false
            }
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
                    DispatchQueue.main.async {
                        weakSelf?.presentLoginVC()
                    }
                }
            }
        
            return
        }
        
        //if metadata is to be shown, show it here, else, proceed with the below flow
        
        if !isCurrentItemEpisode
        {
            if let duration = (currentPlayableItem as? Item)?.duration
            {
                
                if duration.contains(":")
                {
                    weakSelf?.checkLoginAndPlay()
                }
                else
                {
                    let durationInt = Int(Float(duration)!)
                    if durationInt != 0
                    {
                        let resumeWatchingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: resumeWatchingVCStoryBoardId) as! JCResumeWatchingVC
                        resumeWatchingVC.playableItemDuration = durationInt
                        resumeWatchingVC.playerId = (currentPlayableItem as! Item).id
                        resumeWatchingVC.itemDescription = (currentPlayableItem as! Item).description
                        resumeWatchingVC.itemImage = (currentPlayableItem as! Item).banner
                        resumeWatchingVC.itemTitle = (currentPlayableItem as! Item).name
                        resumeWatchingVC.itemDuration = String(describing: (currentPlayableItem as! Item).totalDuration)
                        resumeWatchingVC.item = currentPlayableItem
                        
                        self.present(resumeWatchingVC, animated: false, completion: nil)
                    }
                    else if (currentPlayableItem as! Item).app?.type == VideoType.Movie.rawValue || (currentPlayableItem as! Item).app?.type == VideoType.TVShow.rawValue
                    {
                        showMetadata()
                    }
                }
            }
            else if let duration = (currentPlayableItem as? Episode)?.duration
            {
                let durationInt = Int(Float(duration))
                if durationInt != 0
                {
                    let resumeWatchingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: resumeWatchingVCStoryBoardId) as! JCResumeWatchingVC
                    resumeWatchingVC.playableItemDuration = durationInt
                    resumeWatchingVC.playerId = (currentPlayableItem as! Episode).id
                    resumeWatchingVC.itemDescription = (currentPlayableItem as! Episode).subtitle
                    resumeWatchingVC.itemImage = (currentPlayableItem as! Episode).banner
                    resumeWatchingVC.itemTitle = (currentPlayableItem as! Episode).name
                    resumeWatchingVC.itemDuration = String(describing: (currentPlayableItem as! Episode).totalDuration)
                    self.present(resumeWatchingVC, animated: false, completion: nil)
                }
            }
            else if (currentPlayableItem as! Item).app?.type == VideoType.Movie.rawValue || (currentPlayableItem as! Item).app?.type == VideoType.TVShow.rawValue
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
    
    func presentLanguageGenreController(item:Item)
    {
        let languageGenreVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
        DispatchQueue.main.async {
            self.present(languageGenreVC, animated: false, completion: nil)
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
                    if let item = currentPlayableItem as? Item
                    {
                        if (item.app?.type == VideoType.Music.rawValue || item.app?.type == VideoType.Clip.rawValue || item.app?.type == VideoType.Trailer.rawValue)
                        {
                            DispatchQueue.main.async {
                                weakSelf?.presentLoginVC()
                            }
                        }
                    }
                    else
                    {
                        NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: nil)
                    }
                    
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
        let selectedItem:Item = currentPlayableItem as! Item
        Log.DLog(message: selectedItem.id as AnyObject)
        let metadataVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
        metadataVC.item = selectedItem
        metadataVC.modalPresentationStyle = .overFullScreen
        metadataVC.modalTransitionStyle = .coverVertical
        self.present(metadataVC, animated: false, completion: nil)
    }
    
    func prepareToPlay()
    {
        if currentPlayableItem != nil, JCLoginManager.sharedInstance.isLoginFromSettingsScreen == false
        {
            print("play video")
            
            let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
            
            if isCurrentItemEpisode
            {
                let item = (currentPlayableItem as! Episode)
                playerVC.currentItemImage = item.banner
                playerVC.currentItemTitle = item.name
                playerVC.currentItemDuration = String(describing: item.totalDuration)
                playerVC.currentItemDescription = item.subtitle
                playerVC.callWebServiceForPlaybackRights(id: item.id!)
                playerVC.modalPresentationStyle = .overFullScreen
                playerVC.modalTransitionStyle = .coverVertical
               // playerVC.playerId = (currentPlayableItem as! Episode).id!
                let playerItem = ["player":playerVC]
                NotificationCenter.default.post(name: watchNowNotificationName, object: nil, userInfo: playerItem)
            }
            else
            {
                let item = (currentPlayableItem as! Item)
                if (item.id?.characters.count)! > 0
                {
                    playerVC.currentItemImage = item.banner
                    playerVC.currentItemTitle = item.name
                    playerVC.currentItemDuration = String(describing: item.totalDuration)
                    playerVC.currentItemDescription = item.description
                    if latestEpisodeId != "-1"
                    {
                    playerVC.callWebServiceForPlaybackRights(id: latestEpisodeId)
                       // latestEpisodeId = "-1"
                    }
                    else
                    {
                    playerVC.callWebServiceForPlaybackRights(id: item.id!)
                    }
                }
               // else
                //{
//                    if item.isPlaylist!
//                    {
//                        playerVC.callWebServiceForPlayListData(id: item.playlistId!)
//                    }
                //}
                
                playerVC.modalPresentationStyle = .overFullScreen
                playerVC.modalTransitionStyle = .coverVertical
                playerVC.playerId = (currentPlayableItem as! Item).id!
                
                playerVC.item = currentPlayableItem
                
                if let topController = UIApplication.topViewController() {
                    topController.present(playerVC, animated: false, completion: nil)
                }
            }
        }
        else
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            settingsVC?.settingsTableView.reloadData()
            JCLoginManager.sharedInstance.isLoginFromSettingsScreen = false
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
    
    // MARK:- Network Notifier
    
    func startNetworkNotifier()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        reachability = Reachability.init()
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    func reachabilityChanged(note: Notification) {
        let r = note.object as! Reachability
        if r.isReachable {
            if (reachability?.isReachableViaWiFi)! {
                print("Reachable via WiFi")
                
            } else {
                print("Reachable via Cellular")
                
            }
        } else {
            print("Network not reachable")
            let alertController = UIAlertController.init(title: "Alert", message: "No network available", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            
            appDelegate?.window?.rootViewController?.present(alertController, animated: false, completion: nil)
        }
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let navigationController = controller as? UINavigationController
        {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController
        {
            if let selected = tabController.selectedViewController
            {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController
        {
            return topViewController(controller: presented)
        }
        return controller
    }
}


