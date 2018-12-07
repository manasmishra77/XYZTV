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
    
//    var homeVC, moviesVC, tvVC, musicVC, disneHomeVC : BaseViewController<BaseViewModel>?
    var disneHomeVC : BaseViewController<BaseViewModel>?
    var settingsVC: JCSettingsVC?

    override init() {
        super.init()
        self.initialiseControllers()
    }
    
    func initialiseControllers() {
        
        for i in 0..<ViewControllersType.allCases.count {
            switch ViewControllersType.allCases[i].rawValue {
            case ViewControllersType.Disney.rawValue :
                disneHomeVC = BaseViewController(.disneyHome)
            case ViewControllersType.Settings.rawValue :
                settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsVCStoryBoardId) as? JCSettingsVC
            default: break
            }
        }
    }
    
}
