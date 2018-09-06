//
//  JCLanguageGenreDetailModel.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

struct LanguageGenreDetailModel: Codable {
    var code:Int?
    var message:String?
    var totalItems:Int?
    var pageCount:Int?
    var layout:Int?
    var data:LanguageGenreDataContainer?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case totalItems = "totalItems"
        case pageCount = "pageCount"
        case layout = "layout"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        totalItems = try values.decodeIfPresent(Int.self, forKey: .totalItems)
        pageCount = try values.decodeIfPresent(Int.self, forKey: .pageCount)
        layout = try values.decodeIfPresent(Int.self, forKey: .layout)
        data = try values.decodeIfPresent(LanguageGenreDataContainer.self, forKey: .data)
    }
}

struct LanguageGenreDataContainer: Codable {
    var items: [Item]?
    var filter: [List]?
    var categories: [List]?
    var genres: [List]?
    var languages: [List]?
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case filter = "filter"
        case categories = "categories"
        case genres = "genres"
        case languages = "languages"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decodeIfPresent([Item].self, forKey: .items)
        filter = try values.decodeIfPresent([List].self, forKey: .filter)
        categories = try values.decodeIfPresent([List].self, forKey: .categories)
        genres = try values.decodeIfPresent([List].self, forKey: .genres)
        languages = try values.decodeIfPresent([List].self, forKey: .languages)
    }
}


/*

class LanguageGenreDetailModel:Mappable
{
    var code:Int?
    var message:String?
    var totalItems:Int?
    var pageCount:Int?
    var layout:Int?
    var data:LanguageGenreDataContainer?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        code <- map["code"]
        message <- map["message"]
        totalItems <- map["totalItems"]
        pageCount <- map["pageCount"]
        totalItems <- map["totalItems"]
        layout <- map["layout"]
        data <- map["data"]
    }
}

class LanguageGenreDataContainer:Mappable
{
    var items:[Item]?
    var filter:[List]?
    var categories:[List]?
    var genres:[List]?
    var languages:[List]?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        items <- map["items"]
        filter <- map["filter"]
        categories <- map["categories"]
        genres <- map["genres"]
        languages <- map["languages"]
    }
}
*/
