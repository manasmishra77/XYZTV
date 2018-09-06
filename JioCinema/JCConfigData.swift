//
//  ConfigData.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper


struct ConfigData: Codable {
    
    var code: Int?
    var message: String?
    var configDataUrls: ConfigDataURLs?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case configDataUrls = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        configDataUrls = try values.decodeIfPresent(ConfigDataURLs.self, forKey: .configDataUrls)
    }
}

struct ConfigDataURLs: Codable {
    var analytics: String?
    var api: String?
    var conflist: String?
    var contentBaseUrl: String?
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
    var cdnEncryptionFlag:Bool? = false
    var cdnTokenKey:String?
    var cdnUrlExpiryDuration:Int?
    var parentalSession: String?
    var tvHomeUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case analytics = "analytics"
        case api = "api"
        case conflist = "conflist"
        case contentBaseUrl = "contentBaseUrl"
        case download = "download"
        case dynamicImageUrl = "dynamicImageUrl"
        case faq = "faq"
        case feedback = "feedback"
        case feedbackSubmit = "feedbackSubmit"
        case genrePosition = "genrePosition"
        case home = "home"
        case image = "image"
        case languagePosition = "languagePosition"
        case privacyPolicy = "privacyPolicy"
        case termsAndConditions = "termsAndConditions"
        case thumb = "thumb"
        case updateFrequency = "updateFrequency"
        case video = "video"
        case videoDRMurl = "videoDRMurl"
        case wvProxyUrl = "wvProxyUrl"
        case cdnEncryptionFlag = "cdnEncryptionFlag"
        case cdnTokenKey = "cdnTokenKey"
        case cdnUrlExpiryDuration = "cdnUrlExpiryDuration"
        case parentalSession = "parentalSession"
        case tvHomeUrl = "tvHomeUrl"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        analytics = try values.decodeIfPresent(String.self, forKey: .analytics)
        api = try values.decodeIfPresent(String.self, forKey: .api)
        conflist = try values.decodeIfPresent(String.self, forKey: .conflist)
        contentBaseUrl = try values.decodeIfPresent(String.self, forKey: .contentBaseUrl)
        download = try values.decodeIfPresent(String.self, forKey: .download)
        dynamicImageUrl = try values.decodeIfPresent(String.self, forKey: .dynamicImageUrl)
        faq = try values.decodeIfPresent(String.self, forKey: .faq)
        feedback = try values.decodeIfPresent(String.self, forKey: .feedback)
        feedbackSubmit = try values.decodeIfPresent(String.self, forKey: .feedbackSubmit)
        genrePosition = try values.decodeIfPresent(Int.self, forKey: .genrePosition)
        home = try values.decodeIfPresent(String.self, forKey: .home)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        languagePosition = try values.decodeIfPresent(Int.self, forKey: .languagePosition)
        privacyPolicy = try values.decodeIfPresent(String.self, forKey: .privacyPolicy)
        termsAndConditions = try values.decodeIfPresent(String.self, forKey: .termsAndConditions)
        thumb = try values.decodeIfPresent(String.self, forKey: .thumb)
        updateFrequency = try values.decodeIfPresent(Int.self, forKey: .updateFrequency)
        video = try values.decodeIfPresent(String.self, forKey: .video)
        videoDRMurl = try values.decodeIfPresent(String.self, forKey: .videoDRMurl)
        wvProxyUrl = try values.decodeIfPresent(String.self, forKey: .wvProxyUrl)
        cdnEncryptionFlag = try values.decodeIfPresent(Bool.self, forKey: .cdnEncryptionFlag)
        cdnTokenKey = try values.decodeIfPresent(String.self, forKey: .cdnTokenKey)
        cdnUrlExpiryDuration = try values.decodeIfPresent(Int.self, forKey: .cdnUrlExpiryDuration)
        parentalSession = try values.decodeIfPresent(String.self, forKey: .parentalSession)
        tvHomeUrl = try values.decodeIfPresent(String.self, forKey: .tvHomeUrl)
    }
}

/*

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

class ConfigDataURLs: Mappable {
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
    var cdnEncryptionFlag:Bool = false
    var cdnTokenKey:String?
    var cdnUrlExpiryDuration:Int?
    var parentalSession: String?
    var tvHomeUrl: String?
    
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
        tvHomeUrl <- map["tvhome"]
        image <- map["image"]
        languagePosition <- map["languagePosition"]
        privacyPolicy <- map["privacyPolicy"]
        termsAndConditions <- map["termsAndConditions"]
        thumb <- map["thumb"]
        updateFrequency <- map["updateFrequency"]
        video <- map["video"]
        videoDRMurl <- map["videoDRMurl"]
        wvProxyUrl <- map["wvProxyUrl"]
        cdnEncryptionFlag <- map["cdnencryption_flag"]
        cdnTokenKey <- map["tid"]
        cdnUrlExpiryDuration <- map["cdnUrlExpiry"]
        parentalSession <- map["parentalSession"]
    }
}
*/
