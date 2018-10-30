//
//  PlaybackRightsModel.swift
//  JioCinema
//
//  Created by manas on 06/12/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import ObjectMapper

//MARK:- PlaybackRight Model

class PlaybackRightsModel: Mappable
{
    var code:Int?
    var message:String?
    var duration:Float?
    var inqueue:Bool?
    var totalDuration:String?
    var isSubscribed:Bool?
    var subscription: Subscription?
    var aesUrl:String?
    var url:String?
    var tinyUrl:String?
    var text:String?
    var contentName:String?
    var thumb:String?
    var vendor: String?
    var maturityRating: String?
    var languageIndex: LanguageIndex?
    var defaultLanguage: String?
    var displayLanguages: [String]?
    
    var maturityAgeGrp: AgeGroup {
        if let value = self.maturityRating {
            return AgeGroup(rawValue: value.capitalized) ?? .age18Plus
        }
        return .age18Plus
    }
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        duration <- map["duration"]
        inqueue <- map["inqueue"]
        totalDuration <- map["totalDuration"]
        totalDuration <- map["totalDuration"]
        isSubscribed <- map["isSubscribed"]
        subscription <- map["subscription"]
        aesUrl <- map["aesUrl"]
        url <- map["url"]
        tinyUrl <- map["tinyUrl"]
        text <- map["text"]
        contentName <- map["contentName"]
        thumb <- map["thumb"]
        vendor <- map["vendorName"]
        maturityRating <- map["maturityRating"]
        languageIndex <- map["languageIndex"]
        defaultLanguage <- map["defaultLanguage"]
        displayLanguages <- map["displayLanguages"]

    }
}
//MARK:- Subscription Model

class Subscription:Mappable
{
    var isSubscribed:Bool?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        isSubscribed <- map["isSubscribed"]
    }
}
class LanguageIndex: Mappable
{
    var name: String?
    var code: String?
    var index: Int?
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        name <- map["name"]
        code <- map["code"]
        index <- map["index"]
    }
}
//MARK:- PlaylistDataModel Model

class PlaylistDataModel: Mappable {
    
    var more: [More]?
    
    required init(map:Map) {
    }
    
    func mapping(map:Map)
    {
        
        more <- map["more"]
    }
    
}
