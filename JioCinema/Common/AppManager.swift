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
    
    //Used when Deep-Linking is done
    var isComingFromDeepLinking: Bool = false
    var vcOpenType: VCOpenType?
    var deepLinkingItem: Item?
    
    //Used to set/reset deep-linking item and related variable
    func setForDeepLinkingItem(isFromDL: Bool, vcOpenType: VCOpenType?, item: Item?) {
        self.isComingFromDeepLinking = isFromDL
        self.vcOpenType = vcOpenType
        self.deepLinkingItem = item
    }

}
