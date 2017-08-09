//
//  ConfigData.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class ConfigData: Mappable {
    
    var code:Int?
    var message:String?
    var configDataUrls:ConfigDataURLs?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        code <- map["code"]
        message <- map["message"]
        configDataUrls <- map["url"]
    }
}

class ConfigDataURLs: Mappable
{
    var analytics:String?
    var api:String?
    var conflist:String?
    var contentBaseUrl:String?
    var download:String?
    var dynamicImageUrl:String?
    var faq:String?
    var feedback:String?
    var feedbackSubmit:String?
    var genrePosition:Int?
    var home:String?
    var image:String?
    var languagePosition:Int?
    var privacyPolicy:String?
    var termsAndConditions:String?
    var thumb:String?
    var updateFrequency:Int?
    var video:String?
    var videoDRMurl:String?
    var wvProxyUrl:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        analytics <- map["analytics"]
        api <- map["api"]
        conflist <- map["conflist"]
        contentBaseUrl <- map["contentBaseUrl"]
        download <- map["download"]
        dynamicImageUrl <- map["dynamicImageUrl"]
        faq <- map["faq"]
        feedback <- map["feedback"]
        feedbackSubmit <- map["feedbackSubmit"]
        genrePosition <- map["genrePosition"]
        home <- map["home"]
        image <- map["image"]
        languagePosition <- map["languagePosition"]
        privacyPolicy <- map["privacyPolicy"]
        termsAndConditions <- map["termsAndConditions"]
        thumb <- map["thumb"]
        updateFrequency <- map["updateFrequency"]
        video <- map["video"]
        videoDRMurl <- map["videoDRMurl"]
        wvProxyUrl <- map["wvProxyUrl"]
    }
}
