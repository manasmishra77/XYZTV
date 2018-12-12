//
//  SideNavigationViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 12/5/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit

class SideNavigationViewModel: NSObject {
    
    var homeVC, moviesVC, tvVC, musicVC, clips, disneHomeVC : BaseViewController<BaseViewModel>?
//    var disneHomeVC : BaseViewController<BaseViewModel>?
    
    var settingsVC: JCSettingsVC?
    var searchVC: SearchNavigationController?

    override init() {
        super.init()
        self.initialiseControllers()
    }
    
    func initialiseControllers() {
        
        for i in 0..<ViewControllersType.allCases.count {
            switch ViewControllersType.allCases[i].rawValue {
            case ViewControllersType.disneyHome.rawValue :
                disneHomeVC = BaseViewController(.disneyHome)
            case ViewControllersType.settings.rawValue :
                settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsVCStoryBoardId) as? JCSettingsVC
            case ViewControllersType.home.rawValue :
                homeVC = BaseViewController(.home)
            case ViewControllersType.tv.rawValue :
                tvVC = BaseViewController(.tv)
            case ViewControllersType.music.rawValue :
                musicVC = BaseViewController(.music)
            case ViewControllersType.clips.rawValue :
                clips = BaseViewController(.clip)
            case ViewControllersType.movies.rawValue :
                moviesVC = BaseViewController(.movie)
                
            case ViewControllersType.search.rawValue :
                searchVC = self.getSearchController()
                
            default: break
            }
        }
    }
    
    func getSearchController() -> SearchNavigationController{
        let searchViewController = Utility.sharedInstance.prepareSearchViewController(searchText: "")
        let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        searchContainerController.view.backgroundColor = UIColor.black
        return SearchNavigationController(rootViewController: searchContainerController)
    }
    
}
