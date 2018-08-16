//
//  ParentalViewModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/13/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation


class SetParentalViewModel: NSObject {
    
    func getPinForParentalControl(completion: @escaping (_ pin: String?) -> ()) {
        RJILApiManager.defaultManager.getPinFromServer { (pin) in
            DispatchQueue.main.async {
                if let pin = pin {
                    completion(pin)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
