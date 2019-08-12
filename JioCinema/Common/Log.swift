//
//  Log.swift
//  JioCinema
//
//  Created by Atinderpal Singh on 30/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

class Log {
    static  func DLog(message: AnyObject, function: String = #function) {
        #if DEBUG
            print("\(function): \(message)")
        #endif
    }
}
