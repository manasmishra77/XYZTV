//
//  AppManager.swift
//  JioCinema
//
//  Created by Manas Mishra on 30/07/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class AppManager: NSObject {
    static let shared = AppManager()
    private override init() {
        
    }
    
    //App Delegate
    var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var sideNavigationVC: SideNavigationVC? {
        let window = appDelegate?.window
        let rootNavVC = window?.rootViewController as? UINavigationController
        let navVc = rootNavVC?.viewControllers.first as? SideNavigationVC
        return navVc
    }
    
    weak var playerVC: PlayerViewController?
    
    //Used when Deep-Linking is done
    var isComingFromDeepLinking: Bool = false
    var deepLinkingItem: Item?
    
    //Used to set/reset deep-linking item and related variable
    func setForDeepLinkingItem(isFromDL: Bool, item: Item?) {
        self.isComingFromDeepLinking = isFromDL
        self.deepLinkingItem = item
    }
    
    func processURLWhenComingFromDeeplinking(urlString: String) {
        var tappeditem = Item()
        if let url = URL(string: urlString) {
            let urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true)
            
            //Don't change the sequence
            let queryItems = urlComponent?.queryItems
            tappeditem.id = queryItems?[0].value
            tappeditem.latestId = queryItems?[1].value
            tappeditem.isPlaylist = Bool(queryItems?[2].value ?? "false")
            tappeditem.playlistId = queryItems?[3].value
            var appType = App()
            appType.type = Int(queryItems?[4].value ?? "0")
            tappeditem.app = appType
            tappeditem.tvStill = queryItems?[5].value
            self.setForDeepLinkingItem(isFromDL: true, item: tappeditem)
            if sideNavigationVC != nil {
                if self.playerVC != nil {
                    self.playerVC?.removePlayerController()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateToHomeVC()
                    }
                }
                else {
                    self.navigateToHomeVC()
                }
            }
            
        }
    }
    
    func navigateToHomeVC() {
        if sideNavigationVC?.presentedViewController != nil {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: {
                self.makeSideNavigationRootVC()
            })
        } else {
          makeSideNavigationRootVC()
        }
    }
    
    func makeSideNavigationRootVC() {
        let sideNavVC = SideNavigationVC(nibName: "SideNavigationVC", bundle: nil)
        let navController = UINavigationController(rootViewController: sideNavVC)
        JCDataStore.sharedDataStore.resetDataStore()
        navController.navigationBar.isHidden = true
        self.appDelegate?.window?.rootViewController = navController
    }
}
