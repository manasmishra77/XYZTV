//
//  Utility+ActivityIndicator.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/16/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit

extension Utility {
    //MARK: UIActivity Indicator
    func addIndicator(){
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        //  indicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.backgroundColor = UIColor.darkGray
        activityIndicator.alpha = 0.50
    }
    
    func showIndicator(){
        //show the Indicator
        activityIndicator.startAnimating()
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            window.addSubview(activityIndicator)
            window.bringSubviewToFront(activityIndicator)
        }
    }
    
    func hideIndicator(){
        //Hide the Indicator
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }

    }
}
