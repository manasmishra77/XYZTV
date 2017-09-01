//
//  JCLanguageGenreDetailModel.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

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
