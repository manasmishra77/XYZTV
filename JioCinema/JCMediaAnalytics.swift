//
//  JCMediaAnalytics.swift
//  JioCinema
//
//  Created by Tania Jasam on 9/20/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMediaAnalytics
{
    static let manager = JCMediaAnalytics()
    
    func recordLoginEventwith(method: String, andSource source:String)
    {
        var params: Dictionary<String,String> = [:]
        params["method"] = method
        params["source"] = source
        params["identity"] = JCAppUser.shared.commonName
        
        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "logged_in", andEventProperties: params)
    }
    
    func recordLoginFailedEventwith(userDict: Dictionary<String, Any>)
    {
        var params: Dictionary<String,Any> = [:]
        params["pro"] = userDict
        params["key"] = "login_failed"
        
        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "login_failed", andEventProperties: params)
    }
    
    func trackSearchEventfor(dataDict: Dictionary<String, Any>)
    {
        var params: Dictionary<String,Any> = [:]
        params["key"] = "search"
        params["pro"] = dataDict
        params["platform"] = "TVOS"
        
        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "search", andEventProperties: params)
    }
    
    func trackMediaStart()
    {
        var params: Dictionary<String,Any> = [:]
        //        params["cid"] =
        //        params["mbid"] =
        //        params["from"] =
        //        params["Source"] =
        //        params["Row Position"] =
        
        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "media_start", andEventProperties: params)
    }
    
    func trackMediaEnd()
    {
        var params: Dictionary<String,Any> = [:]
//        params["cid"] =
//        params["epos"] =
//        params["ts"] =
//        params["ref"] =
//        params["s"] =
//        params["bd"] =
//        params["bc"] =
//        params["screenName"] =
//        params["Bitrate"] =
//        params["Playlist"] =
//        params["Row Position"] =
//        params["Source"] =
        
        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "media_end", andEventProperties: params)
    }
    
    func trackMediaError()
    {
        var params: Dictionary<String,Any> = [:]
//        params["desc"] =
//        params["code"] =
//        params["Type"] =
//        params["Title"] =
//        params["cid"] =
//        params["Quality"] =
//        params["Bitrate"] =
//        params["Episode"] =
//        params["msg"] =
//        params["sec"] =
//        params["serr"] =
//        
        JIOMediaAnalytics.sharedInstance().recordEvent(withEventName: "media_error", andEventProperties: params)
    }
}
