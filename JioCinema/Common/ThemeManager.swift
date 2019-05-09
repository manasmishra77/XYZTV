//
//  ThemeManager.swift
//  JioCinema
//
//  Created by Shweta on 08/05/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit
class ThemeManager {
    static let shared = ThemeManager()
    
    enum Themes {
        case jioCinema
        case jioDisney
    }
    var currentTheme : Themes = .jioCinema
    private init() {
    }
    
    var backgroundColor : UIColor{
        switch currentTheme {
        case .jioCinema:
            return ViewColor.commonBackground
        case .jioDisney:
            return ViewColor.disneyBackground
        }
    }
    var selectionColor : UIColor{
        switch currentTheme {
        case .jioCinema:
            return ViewColor.selectionBarOnLeftNavigationColor
        case .jioDisney:
            return ViewColor.selectionBarOnLeftNavigationColorForDisney
        }
    }
    
}
