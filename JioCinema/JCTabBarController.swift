//
//  JCTabBarController.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


class JCTabBarController: UITabBarController {
    
      
    var settingsVC: JCSettingsVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabBarTitle()
        
//        let homeVC = JCHomeVC(nibName: "JCBaseVC", bundle: nil)
//        homeVC.tabBarItem = UITabBarItem(title: "Home", image: nil, tag: 0)
        
//        let moviesVC = JCMoviesVC(nibName: "JCBaseVC", bundle: nil)
//        moviesVC.tabBarItem = UITabBarItem(title: "Movies", image: nil, tag: 1)
//
//        let tvVC = JCTVVC(nibName: "JCBaseVC", bundle: nil)
//        tvVC.tabBarItem = UITabBarItem(title: "TV", image: nil, tag: 2)
//
//        let musicVC = JCMusicVC(nibName: "JCBaseVC", bundle: nil)
//        musicVC.tabBarItem = UITabBarItem(title: "Music", image: nil, tag: 3)
        
//        let clipsVC = JCClipsVC(nibName: "JCBaseVC", bundle: nil)
//        clipsVC.tabBarItem = UITabBarItem(title: "Clips", image: nil, tag: 4)
        let moviesVC = BaseViewController(.movie)
        let tvVC = BaseViewController(.tv)
        let musicVC = BaseViewController(.music)
        let disneyVC = BaseViewController(.disneyHome)//JCDisneyVC(nibName: "JCBaseVC", bundle: nil)
        let homeVC = BaseViewController(.home)
        //disneyVC.tabBarItem = UITabBarItem(title: "Disney", image: nil, tag: 4)
        
        
        
        let searchViewController = Utility.sharedInstance.prepareSearchViewController(searchText: "")
        let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        searchContainerController.view.backgroundColor = UIColor.black
        let navControllerForSearchContainer = SearchNavigationController(rootViewController: searchContainerController)
        
        navControllerForSearchContainer.tabBarItem = UITabBarItem(title: "Search", image: nil, tag: 5)
        
        
        

        settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsVCStoryBoardId) as? JCSettingsVC
        settingsVC?.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 6)
        
        let viewControllersArray = [homeVC, moviesVC, tvVC, musicVC, disneyVC, navControllerForSearchContainer, settingsVC!] as [Any]
        self.setViewControllers(viewControllersArray as? [UIViewController], animated: false)
        
        //self.tabBar.alpha = 0.7
        self.tabBar.backgroundColor = UIColor.black
        
        
        //To change the tab bar title appearance
        for item in self.tabBar.items! {
            let unselectedItem = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
            let selectedItem = [NSAttributedStringKey.foregroundColor: UIColor.white]
            
            item.setTitleTextAttributes(unselectedItem, for: .normal)
            item.setTitleTextAttributes(selectedItem, for: .selected)
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func setTabBarTitle() {
        let tabBarTitleLabel = UILabel.init(frame: CGRect(x: 50.0, y: 0.0, width: 300.0, height: 135.0))
        
        tabBarTitleLabel.text = ""
        tabBarTitleLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 56.0)
        tabBarTitleLabel.textColor = UIColor.white
        self.tabBar.addSubview(tabBarTitleLabel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func presentVC(_ item: Item, dataType: DataType = .common) {
//        print(item)
//        let metadataVC = Utility.sharedInstance.prepareMetadata(item.id!, appType: item.appType, fromScreen: DISNEY_SCREEN, categoryName: <#String#>, categoryIndex: <#Int#>, tabBarIndex: 5, isDisney: dataType == .disney)
//        self.present(metadataVC, animated: true, completion: nil)
//    }
    func presentDisneySubVC(_ vc: UIViewController) {
        self.present(vc, animated: false, completion: nil)
    }

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

enum DataType {
    case common
    case disney
}

