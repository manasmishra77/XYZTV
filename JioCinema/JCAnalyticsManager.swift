//
//  JCAnalyticsManager.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 26/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import CleverTapTVOS

class JCAnalyticsManager
{
    static let sharedInstance = JCAnalyticsManager()
    
    var tid : String?               //Google Analytics property id
    var cid: String?                //Google Analytics client id
    var appName : String?
    var appVersion : String?
    //var MPVersion : String?         //Measurement protocol version
    var ua : String?                //UserAgent
    var ul : String?                //Language
    
    init()
    {
        self.tid = googleAnalyticsTId
        self.appName = Bundle.main.infoDictionary!["CFBundleName"] as? String
        let appVsn: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        self.appVersion = appVsn as? String
        self.ua = "Mozilla/5.0 (Apple TV; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13T534YI"
       // self.MPVersion = "1"
        let defaults = UserDefaults.standard
        if let cid = defaults.string(forKey: "cid") {
            self.cid = cid
        }
        else {
            self.cid = NSUUID().uuidString
            defaults.set(self.cid, forKey: "cid")
        }
        
        let language = NSLocale.preferredLanguages.first
        if (language?.count)! > 0 {
            self.ul = language!
        } else {
            self.ul = "(not set)"
        }
    }
    
    func screenNavigation(screenName:String,customParameters:[String:String])
    {
        var params = ["cd" : screenName]
        if (customParameters.keys.count > 0) {
            for (key, value) in customParameters {
                params.updateValue(value, forKey: key)
            }
        }
        self.sendEvent(eventType: "screenNavigation", params: params)
    }
    
    func event(category: String, action: String, label: String?, customParameters: Dictionary<String, String>?) {
        
        var params = ["ec" : category, "ea" : action, "el" : label ?? ""]
        if (customParameters != nil) {
            for (key, value) in customParameters! {
                params.updateValue(value, forKey: key)
            }
        }
        self.sendEvent(eventType: "event", params: params)
    }
    
    func exception(description: String, isFatal:Bool, customParameters: Dictionary<String, String>?) {
        /*
         An exception hit with exception description (exd) and "fatality"  (Crashed or not) (exf)
         */
        var fatal="0"
        if (isFatal){
            fatal = "1"
        }
        
        var params = ["exd":description, "exf":fatal]
        if (customParameters != nil) {
            for (key, value) in customParameters! {
                params.updateValue(value, forKey: key)
            }
        }
        self.sendEvent(eventType: "exception", params: params)
        
    }
    
    func sendEvent(eventType:String,params:[String:String])
    {
        let endpoint = googleAnalyticsEndPoint
        
        var parameters = ""
        
        let mandatoryParams = ["an":self.appName,"tid":self.tid,"av":self.appVersion,"cid":self.cid,"t":eventType,"ua":self.ua,"ul":self.ul]
        
        for (key, value) in mandatoryParams {
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let escapedValue = (value as AnyObject).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            parameters += escapedKey! + "=" + escapedValue! + "&"
        }
       
        for (key, value) in params {
            parameters += "&" + key + "=" + value
        }
        
        //Encoding all the parameters
        if let paramEndcode = parameters.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        {
            let urlString = endpoint + paramEndcode
            let url = URL.init(string: urlString)
            
            #if DEBUG
                //print(urlString)
            #endif
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error)  in
                if let httpReponse = response as? HTTPURLResponse {
                    let statusCode = httpReponse.statusCode
                    #if DEBUG
                        print("Status code is----->\(statusCode)")
                    #endif
                }
                else {
                    if (error != nil) {
                        #if DEBUG
                           // print(error?.localizedDescription)
                        #endif
                    }
                }
            }
            task.resume()
        }
        
    }

    
    //MARK: Clever Tap Events
    func sendEventToCleverTap(eventName:String,properties:[String:Any])
    {
        CleverTap.sharedInstance().recordEvent(eventName, withProps: properties)
    }
    
}
