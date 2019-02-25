//
//  SearchDataStore.swift
//  JioCinema
//
//  Created by SushantAlone on 11/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

/*
class SearchDataModel:Mappable
{
    var code:Int?
    var message:String?
    var searchData:SearchDataContainer?
    
    required init?(map: Map)
    {
        
    }
    
    func mapping(map: Map)
    {
        code <- map["code"]
        message <- map["message"]
        searchData <- map["data"]
    }
}

class SearchDataContainer:Mappable
{
    var currentPage:Int?
    var maxElemnts:Int?
    var categoryItems:[SearchedCategoryItem]?
    var searchedString:String?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        categoryItems <- map["items"]
        currentPage <- map["current"]
        maxElemnts <- map["max"]
        searchedString <- map["searchedTerm"]
    }
}



class SearchedCategoryItem: Mappable
{
    
    var categoryName:String?
    var seeMore:Bool?
    var categoryLayout:Int?
    var count:Int?
    var resultItems:[Item]?
    
    required init?(map: Map)
    {
       
    }
    func mapping(map: Map)
    {
        categoryName <- map["name"]
        seeMore <- map["seeMore"]
        categoryLayout <- map["layout"]
        count <- map["count"]
        resultItems <- map["items"]
    }
}

*/
struct SearchDataModel: Codable {
    var code: Int?
    var message: String?
    var searchData: SearchDataContainer?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case searchData = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        searchData = try values.decodeIfPresent(SearchDataContainer.self, forKey: .searchData)
    }
}

struct SearchDataContainer: Codable {
    var currentPage: Int?
    var maxElemnts: Int?
    var categoryItems: [SearchedCategoryItem]?
    var searchedString: String?
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current"
        case maxElemnts = "max"
        case categoryItems = "items"
        case searchedString = "searchedTerm"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try values.decodeIfPresent(Int.self, forKey: .currentPage)
        maxElemnts = try values.decodeIfPresent(Int.self, forKey: .maxElemnts)
        categoryItems = try values.decodeIfPresent([SearchedCategoryItem].self, forKey: .categoryItems)
        searchedString = try values.decodeIfPresent(String.self, forKey: .searchedString)
    }
}

struct SearchedCategoryItem: Codable {
    
    var categoryName: String?
    var seeMore: Bool?
    var categoryLayout: Int?
    var count: Int?
    var resultItems: [Item]?
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "name"
        case seeMore
        case categoryLayout = "layout"
        case count
        case resultItems = "items"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        categoryName = try values.decodeIfPresent(String.self, forKey: .categoryName)
        seeMore = try values.decodeIfPresent(Bool.self, forKey: .seeMore)
        categoryLayout = try values.decodeIfPresent(Int.self, forKey: .categoryLayout)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        resultItems = try values.decodeIfPresent([Item].self, forKey: .resultItems)
    }
}

