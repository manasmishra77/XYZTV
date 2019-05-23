//
//  PlaybackRightsModel.swift
//  JioCinema
//
//  Created by manas on 06/12/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

struct PlaybackRightsModel: Codable {
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
    var defaultLanguage: String?
    
    var maturityAgeGrp: AgeGroup {
        if let value = self.maturityRating {
            return AgeGroup(rawValue: value) ?? .allAge
        }
        return .allAge
    }
    var languageIndex: LanguageIndex?
    var aes:Bitcode?
    var fps:Bitcode?
    var displayLanguages: [String]?
    var displaySubtitles: [String]?
    var kids: Bool?
    var download: String?
    var introCreditStart: String?
    var introCreditEnd: String?
    var endCreditStart: String?
    var endCreditEnd: String?
    var recapCreditStart: String?
    var recapCreditEnd: String?
    var precapCreditStart: String?
    var precapCreditEnd: String?
    var mpdRevision: Int?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case duration = "duration"
        case inqueue = "inqueue"
        case totalDuration = "totalDuration"
        case isSubscribed = "isSubscribed"
        case subscription = "subscription"
        case aesUrl = "aesUrl"
        case url = "url"
        case aes = "aes"
        case fps = "fps"
        case tinyUrl = "tinyUrl"
        case text = "text"
        case contentName = "contentName"
        case thumb = "thumb"
        case vendor = "vendor"
        case maturityRating = "maturityRating"
        case languageIndex
        case defaultLanguage = "defaultLanguage"
        case displayLanguages = "displayLanguages"
        case displaySubtitles = "displaySubtitles"
        case kids = "kids"
        case download = "download"
        case introCreditStart = "introCreditStart"
        case endCreditStart = "endCreditStart"
        case introCreditEnd = "introCreditEnd"
        case endCreditEnd = "endCreditEnd"
        case recapCreditStart = "recapCreditStart"
        case precapCreditStart = "precapCreditStart"
        case recapCreditEnd = "recapCreditEnd"
        case precapCreditEnd = "precapCreditEnd"
        case mpdRevision = "mpdRevision"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        do {
            let floatDuration = try values.decodeIfPresent(Float.self, forKey: .duration)
            duration = floatDuration
        } catch {
            do {
                let intDuration = try values.decodeIfPresent(Int.self, forKey: .duration)
                duration = Float(intDuration ?? 0)
            } catch {
                do {
                    let strDuration = try values.decodeIfPresent(String.self, forKey: .duration)
                    duration = Float(strDuration ?? "0.0")
                } catch {
                    print(error)
                }
            }
        }
        inqueue = try values.decodeIfPresent(Bool.self, forKey: .inqueue)
        do {
            let stringDuration = try values.decodeIfPresent(String.self, forKey: .totalDuration)
            totalDuration = stringDuration
        } catch {
            do {
                let intDuration = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
                totalDuration = "\(intDuration ?? 0)"
            } catch {
                do {
                    let floatDuration = try values.decodeIfPresent(Float.self, forKey: .totalDuration)
                    totalDuration = "\(floatDuration ?? 0)"
                } catch {
                    
                }
            }
        }
        isSubscribed = try values.decodeIfPresent(Bool.self, forKey: .isSubscribed)
        subscription = try values.decodeIfPresent(Subscription.self, forKey: .subscription)
        aesUrl = try values.decodeIfPresent(String.self, forKey: .aesUrl)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        fps = try values.decodeIfPresent(Bitcode.self, forKey: .fps)
        aes = try values.decodeIfPresent(Bitcode.self, forKey: .aes)
        tinyUrl = try values.decodeIfPresent(String.self, forKey: .tinyUrl)
        text = try values.decodeIfPresent(String.self, forKey: .text)
        contentName = try values.decodeIfPresent(String.self, forKey: .contentName)
        thumb = try values.decodeIfPresent(String.self, forKey: .thumb)
        vendor = try values.decodeIfPresent(String.self, forKey: .vendor)
        maturityRating = try values.decodeIfPresent(String.self, forKey: .maturityRating)
        languageIndex = try values.decodeIfPresent(LanguageIndex.self, forKey: .languageIndex)
        defaultLanguage = try values.decodeIfPresent(String.self, forKey: .defaultLanguage)
        displayLanguages = try values.decodeIfPresent([String].self, forKey: .displayLanguages)
        displaySubtitles = try values.decodeIfPresent([String].self, forKey: .displaySubtitles)
        displaySubtitles?.insert("Off", at: 0)
        kids = try values.decodeIfPresent(Bool.self, forKey: .kids)
        download = try values.decodeIfPresent(String.self, forKey: .download)
        introCreditStart = try values.decodeIfPresent(String.self, forKey: .introCreditStart)
        endCreditStart = try values.decodeIfPresent(String.self, forKey: .endCreditStart)
        introCreditEnd = try values.decodeIfPresent(String.self, forKey: .introCreditEnd)
        endCreditEnd = try values.decodeIfPresent(String.self, forKey: .endCreditEnd)
        recapCreditStart = try values.decodeIfPresent(String.self, forKey: .recapCreditStart)
        precapCreditStart = try values.decodeIfPresent(String.self, forKey: .precapCreditStart)
        recapCreditEnd = try values.decodeIfPresent(String.self, forKey: .recapCreditEnd)
        precapCreditEnd = try values.decodeIfPresent(String.self, forKey: .precapCreditEnd)
        mpdRevision = try values.decodeIfPresent(Int.self, forKey: .mpdRevision)
    }
}

// MARK : Subscription Model
struct Subscription: Codable {
    var isSubscribed:Bool?
    
    enum CodingKeys: String, CodingKey {
        case isSubscribed = "isSubscribed"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isSubscribed = try values.decodeIfPresent(Bool.self, forKey: .isSubscribed)
    }
}

// MARK : Bitcode Model
struct Bitcode: Codable {
    
    var low: String?
    var medium: String?
    var high: String?
    var auto: String?
    
    enum CodingKeys: String, CodingKey {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case auto = "auto"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        low = try values.decodeIfPresent(String.self, forKey: .low) ?? ""
        medium = try values.decodeIfPresent(String.self, forKey: .medium) ?? ""
        high = try values.decodeIfPresent(String.self, forKey: .high) ?? ""
        auto = try values.decodeIfPresent(String.self, forKey: .auto) ?? ""
    }
    
}


// MARK: PlaylistDataModel Model
struct PlaylistDataModel: Codable {
    var more: [Item]?
    
    enum CodingKeys: String, CodingKey {
        case more = "more"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        more = try values.decodeIfPresent([Item].self, forKey: .more)
    }
}



//MARK:- PlaybackRight Model
/*
 
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
 init() {
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
 */
