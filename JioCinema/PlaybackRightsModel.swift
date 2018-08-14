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
    
    var maturityAgeGrp: AgeGroup {
        if let value = self.maturityRating {
            return AgeGroup(rawValue: value) ?? .allAge
        }
        return .allAge
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
