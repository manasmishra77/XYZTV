//
//  JCHomeScreenData.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 18/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

struct BaseDataModel: Codable {
    var code: Int?
    var message: String?
    var totalPages: Int?
    var data: [DataContainer]?
    
    //For Resume-watch response
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case totalPages = "totalPages"
        case data = "data"
        
        //For Resume-watch response
        case title = "title"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            code = try values.decodeIfPresent(Int.self, forKey: .code)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages)
            do {
                let containerArr = try values.decodeIfPresent([DataContainer].self, forKey: .data)
                self.data = containerArr
            } catch {
                //For recumewatchlist response
                if let container = try values.decodeIfPresent(DataContainer.self, forKey: .data) {
                    self.data = [container]
                }
            }
            //For recumewatchlist response
            title = try values.decodeIfPresent(String.self, forKey: .title)
        } catch {
            print(error)
        }
    }
}

struct WatchListDataModel: Codable {
    var code: Int?
    var message: String?
    var data: DataContainer?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(DataContainer.self, forKey: .data)
    }
}

struct LanguageGenreDataModel: Codable {
    var code: Int?
    var message: String?
    var data: DataContainer?
    var name: String?
    var `default`: String?
    var label: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
        case name = "name"
        case `default` = "default"
        case label = "label"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(DataContainer.self, forKey: .data)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        `default` = try values.decodeIfPresent(String.self, forKey: .`default`)
        label = try values.decodeIfPresent(String.self, forKey: .label)
    }
}


struct ResumeWatchListDataModel: Codable {
    var code: Int?
    var message: String?
    var data: DataContainer?
    var title: String?
    var pageCount: Int?
    var seeMore: Bool?
    var layout: Int?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
        case title = "title"
        case pageCount = "pageCount"
        case seeMore = "seeMore"
        case layout = "layout"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(DataContainer.self, forKey: .data)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        pageCount = try values.decodeIfPresent(Int.self, forKey: .pageCount)
        seeMore = try values.decodeIfPresent(Bool.self, forKey: .seeMore)
        layout = try values.decodeIfPresent(Int.self, forKey: .layout)
    }
}

struct UserRecommendationListDataModel: Codable {
    var code: Int?
    var message: String?
    var data: [DataContainer]?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([DataContainer].self, forKey: .data)
    }
}

struct DataContainer: Codable {
    var items: [Item]?
    var url: String?
    var title: String?
    var seeMore: Bool?
    var order: Int?
    var isCarousal: Bool?
    var id: String?
    var layout: Int?
    var position: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case url = "url"
        case title = "title"
        case seeMore = "seeMore"
        case order = "order"
        case isCarousal = "isCarousal"
        case id = "id"
        case layout = "layout"
        case position = "position"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            do {
                items = try values.decodeIfPresent([Item].self, forKey: .items)
            } catch  {
                print(error)
            }
            
            url = try values.decodeIfPresent(String.self, forKey: .url)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            seeMore = try values.decodeIfPresent(Bool.self, forKey: .seeMore)
            isCarousal = try values.decodeIfPresent(Bool.self, forKey: .isCarousal)
            
            order = try values.decodeIfPresent(Int.self, forKey: .order)
            
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .id)
                self.id = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .id)
                self.id = "\(valNum ?? -1)"
            }
            layout = try values.decodeIfPresent(Int.self, forKey: .layout)
            position = try values.decodeIfPresent(Int.self, forKey: .position)
        } catch  {
            print(error)
        }
        
    }
}

struct Item: Codable {
    var id: String?
    var name: String?
    var showname: String?
    var subtitle: String?
    var image: String?
    var tvImage: String?
    var description: String?
    var banner: String?
    var format: Int?
    var language: String?
    var genre: String?
    var vendor: String?
    var app: App?
    var latestId:String?
    var layout:Int?
    var duration: Int?
    var isPlaylist: Bool? = false
    var playlistId: String?
    var totalDuration: Int?
    var episodeId: String?
    var list:[List]?
    
    var imageUrlString: String {
        guard let baseImageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image else {return ""}
        if let imageStr = image {
            return baseImageUrl + imageStr
        } else if let imageStr = banner {
            return baseImageUrl + imageStr
        }
        return ""
    }
    var appType: VideoType {
        let videoType = VideoType(rawValue: self.app?.type ?? -111)
        return videoType ?? .None
    }
    
    // For Metadata Items
    var rating: Int? //
    var year:Int? //
    var genres:[String]? //
    var srt:String? //
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case showname = "showname"
        case subtitle = "subtitle"
        case image = "image"
        case tvImage = "tvImage"
        case description = "description"
        case banner = "banner"
        case format = "format"
        case language = "language"
        case genre = "genre"
        case vendor = "vendor"
        case app = "app"
        case latestId = "latestId"
        case layout = "layout"
        case duration = "duration"
        case isPlaylist = "isPlaylist"
        case playlistId = "playlistId"
        case totalDuration = "totalDuration"
        case episodeId = "episodeId"
        case list = "list"
        
        // For Metadata Items
        case rating = "rating"
        case year = "year"
        case genres = "genres"
        case srt = "srt"
    }
    init() {
        
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .id)
                self.id = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .id)
                self.id = "\(valNum ?? -1)"
            }
            name = try values.decodeIfPresent(String.self, forKey: .name)
            showname = try values.decodeIfPresent(String.self, forKey: .showname)
            subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
            image = try values.decodeIfPresent(String.self, forKey: .image)
            tvImage = try values.decodeIfPresent(String.self, forKey: .tvImage)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            banner = try values.decodeIfPresent(String.self, forKey: .banner)
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .format)
                self.format = valNum
            } catch {
                let valString = try values.decodeIfPresent(String.self, forKey: .format)
                self.format = Int(valString ?? "0")
            }
            language = try values.decodeIfPresent(String.self, forKey: .language)
            genre = try values.decodeIfPresent(String.self, forKey: .genre)
            vendor = try values.decodeIfPresent(String.self, forKey: .vendor)
            app = try values.decodeIfPresent(App.self, forKey: .app)
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .latestId)
                self.latestId = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .latestId)
                self.latestId = "\(valNum ?? -1)"
            }
            
            layout = try values.decodeIfPresent(Int.self, forKey: .layout)
            
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .duration)
                self.duration = valNum
            } catch {
                let valString = try values.decodeIfPresent(String.self, forKey: .duration)
                self.duration = Int(valString ?? "0")
            }
            isPlaylist = try values.decodeIfPresent(Bool.self, forKey: .isPlaylist)
            
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .playlistId)
                self.playlistId = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .playlistId)
                self.playlistId = "\(valNum ?? -1)"
            }
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
                self.totalDuration = valNum
            } catch {
                let valString = try values.decodeIfPresent(String.self, forKey: .totalDuration)
                self.totalDuration = Int(valString ?? "0")
            }
            
            episodeId = try values.decodeIfPresent(String.self, forKey: .episodeId)
            list = try values.decodeIfPresent([List].self, forKey: .list)
            
            // For Metadata Items
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .rating)
                self.rating = valNum
            } catch {
                do {
                    let valDouble = try values.decodeIfPresent(Double.self, forKey: .rating)
                    self.rating = Int(valDouble ?? 0.0)
                } catch  {
                    let valString = try values.decodeIfPresent(String.self, forKey: .rating)
                    self.rating = Int(valString ?? "0")
                }
                
            }
            //year = try values.decodeIfPresent(Int.self, forKey: .year)
            do {
                year = try values.decodeIfPresent(Int.self, forKey: .year)
            }   catch {
                do{
                    if let yearString = try values.decodeIfPresent(String.self, forKey: .year){
                        year = Int(yearString)
                    }
                } catch {
                    print(error)
                }
            }

            genres = try values.decodeIfPresent([String].self, forKey: .genres)
            srt = try values.decodeIfPresent(String.self, forKey: .srt)
        } catch {
            print(error)
        }
    }
}

struct List: Codable {
    var id: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}


struct App: Codable {
    var resolution: Int?
    var isNew: Bool?
    var type: Int?
    
    enum CodingKeys: String, CodingKey {
        case resolution = "resolution"
        case isNew = "isNew"
        case type = "type"
    }
    
    init() {
        
    }
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            resolution = try values.decodeIfPresent(Int.self, forKey: .resolution)
            isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew)
            type = try values.decodeIfPresent(Int.self, forKey: .type)
        } catch {
            print(error)
        }
    }
}
enum BaseVCType: String {
    case home, movie, tv, music, clip, search, disneyHome, disneyMovies, disneyKids, disneyTVShow
    
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



/*
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

*/
