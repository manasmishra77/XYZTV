//
//  SearchDataStore.swift
//  JioCinema
//
//  Created by SushantAlone on 11/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

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


