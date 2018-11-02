//
//  JCHomeScreenData.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseDataModel:Mappable
{
    var code:Int?
    var message:String?
    var totalPages:Int?
    var data:[DataContainer]?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        totalPages <- map["totalPages"]
        data <- map["data"]
        if (data == nil)
        {
            var temp:DataContainer?
            temp <- map["data"]
            data = [temp!]
            //data = temp["items"]
        }
    }
}

class WatchListDataModel: Mappable {
    var code:Int?
    var message:String?
    var data:DataContainer?
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        data <- map["data"]
    }
}

class LanguageGenreDataModel:Mappable
{
    var code:Int?
    var message:String?
    var data:DataContainer?
    var name:String?
    var `default`:String?
    var label:String?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        data <- map["data"]
        name <- map["name"]
        `default` <- map["`default`"]
        label <- map["label"]
    }
}


class ResumeWatchListDataModel:Mappable
{
    var code:Int?
    var message:String?
    var data:DataContainer?
    var title:String?
    var pageCount:Int?
    var seeMore:Bool?
    var layout:Int?
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        data <- map["data"]
        title <- map["title"]
        pageCount <- map["pageCount"]
        seeMore <- map["seeMore"]
        layout <- map["layout"]
    }
}

class UserRecommendationListDataModel:Mappable
{
    var code: Int?
    var message: String?
    var data: [DataContainer]?
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        data <- map["data"]
    }
}

class DataContainer:Mappable
{
    var items:[Item]?
    var url:String?
    var title:String?
    var seeMore:Bool?
    var order:Int?
    var isCarousal:Bool?
    var id:Int?
    var layout:Int?
    var position: Int? = nil
    
    //Multiple Audio Parameter
    private var defaultAudioLanguage: String?
    
    var categoryLanguage: AudioLanguage {
        return AudioLanguage(rawValue: defaultAudioLanguage ?? "") ?? .none
    }
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        items <- map["items"]
        url <- map["url"]
        title <- map["title"]
        seeMore <- map["seeMore"]
        order <- map["order"]
        isCarousal <- map["isCarousal"]
        id <- map["id"]
        layout <- map["layout"]
        position <- map["position"]
        defaultAudioLanguage <- map["defaultAudioLanguage"]
    }
}

class Item:Mappable
{
    var id:String?
    var name:String?
    var showname:String?
    var subtitle:String?
    var image:String?
    var tvImage:String?
    var description:String?
    var banner:String?
    var format:Int?
    var language:String?
    var genre:String?
    var vendor:String?
    var app:App?
    var latestId:String?
    var layout:Int?
    var duration:String?
    var durationInt:Int?
    var isPlaylist:Bool? = false
    var playlistId:String?
    var totalDuration:String?
    var totalDurationInt:Int?
    var episodeId: String?
    var list:[List]?
    
    //multiaudio parameter
    private var languageIndex : LanguageIndex?
    //Local Variable used for defult audio
    private var defaultAudioLanguage: String?
    func setDefaultAudioLanguage(_ audioLang: AudioLanguage?) {
        defaultAudioLanguage = audioLang?.name
    }
    
    var audioLanguage: AudioLanguage {
        return MultiAudioManager.getItemAudioLanguage(languageIndex: languageIndex, defaultAudioLanguage: defaultAudioLanguage, displayLanguage: language)
    }
    
    init() {
        
    }
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        var tempStore: Double?
        tempStore <- map["id"]
        
        id <- map["id"]
        
        if id == nil, tempStore != nil {
            id = "\(String(describing: Int(tempStore!)))"
        }
        name <- map["name"]
        showname <- map["showname"]
        subtitle <- map["subtitle"]
        image <- map["image"]
        tvImage <- map["tvImage"]
        description <- map["description"]
        banner <- map["banner"]
        isPlaylist <- map["isPlaylist"]
        
        if isPlaylist == nil {
            isPlaylist = false
        }
        
        tempStore <- map["playlistId"]
        playlistId <- map["playlistId"]
        if playlistId == nil, tempStore != nil {
            playlistId = "\(String(describing: Int(tempStore!)))"
        }
        
        format <- map["format"]
        language <- map["language"]
        genre <- map["genre"]
        vendor <- map["vendor"]
        app <- map["app"]
        
        tempStore <- map["latestId"]
        latestId <- map["latestId"]
        if latestId == nil, tempStore != nil {
            latestId = "\(String(describing: Int(tempStore!)))"
        }
        layout <- map["layout"]
        duration <- map["duration"]
        if duration == nil
        {
            durationInt <- map["duration"]
            if durationInt != nil
            {
                duration = String(describing: durationInt!)
            }
        }
        
        totalDuration <- map["totalDuration"]
        if totalDuration == nil
        {
            totalDurationInt <- map["totalDuration"]
            if totalDurationInt != nil
            {
                totalDuration = String(describing: totalDurationInt!)
            }
        }
        list <- map["list"]
        
        languageIndex <- map["languageIndex"]
        
    }
}

class List: Mappable {
    var id:Int?
    var name:String?
    
    required init(map:Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
}


class App: Mappable {
    var resolution:Int?
    var isNew:Bool?
    var type:Int?
    init() {
        
    }
    
    required init(map: Map) {
        
    }
    
    func mapping(map: Map) {
        resolution <- map["resolution"]
        isNew <- map["isNew"]
        type <- map["type"]
    }
}
enum VideoType: Int {
    case Search             = -2
    case Home               = -1
    case Movie              = 0
    case TVShow             = 1
    case Music              = 2
    case Trailer            = 3
    case Clip               = 6
    case Episode            = 7
    case ResumeWatching     = 8
    case Language           = 9
    case Genre              = 10
    case None               = -111
    
    var name: String {
        get { return String(describing: self) }
    }
}

enum Month: Int {
    case Jan = 1
    case Feb = 2
    case Mar = 3
    case Apr = 4
    case May = 5
    case Jun = 6
    case Jul = 7
    case Aug  = 8
    case Sep = 9
    case Oct = 10
    case Nov  = 11
    case Dec  = 12
    case None = 0
    
    var name: String {
        get { return String(describing: self) }
    }
}


