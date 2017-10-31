//
//  Utility.swift
//  JioCinema
//
//  Created by Atinderpal Singh on 04/10/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ReachabilitySwift

class Utility
{
    static let sharedInstance = Utility()
    var reachability:Reachability?
    var isNetworkAvailable = false

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
    
    @objc func reachabilityChanged(note: Notification) {
        let r = note.object as! Reachability
        if r.isReachable {
            isNetworkAvailable = true
            if (reachability?.isReachableViaWiFi)! {
                print("Reachable via WiFi")
                
            } else {
                print("Reachable via Cellular")
                
            }
        } else {
            isNetworkAvailable = false
            print("Network not reachable")
            let alertController = UIAlertController.init(title: networkErrorMessage, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            
            appDelegate?.window?.rootViewController?.present(alertController, animated: false, completion: nil)
        }
    }
    // MARK:- Show Alert
     func showAlert(viewController: UIViewController,title: String,message: String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func showDismissableAlert(title: String,message: String)
    {
        let topVC = UIApplication.topViewController()
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
               // topVC?.dismiss(animated: true, completion: nil)
            }))
            topVC?.present(alert, animated: true, completion: nil)
        }
    }
    
    func encodeStringWithBase64(aString: String?) -> String
    {
        if aString != nil
        {
            let encodedData = aString?.data(using: .utf8)
            let encodedString = encodedData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            return encodedString!
        }
        return ""
    }
    
    func handleScreenNavigation(screenName:String)
    {
        previousScreenName = currentScreenName
        currentScreenName = screenName
      let snavInternalEvent = JCAnalyticsEvent.sharedInstance.getSNAVEventForInternalAnalytics(currentScreen: previousScreenName, nextScreen: currentScreenName, durationInCurrentScreen: String(screenDisAppearTime))
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: snavInternalEvent)
    }
    
    
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
extension String {
    func subString(start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: end)
        
        let finalString = self.substring(from: startIndex)
        return finalString.substring(to: endIndex)
    }

    //Converting String to float
    func floatValue() -> Float? {
            if let floatval = Float(self) {
                return floatval
            }
            return nil
        }
}
