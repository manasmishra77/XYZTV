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
    var vendor:String?
    var app:App?
    var latestId:String?
    var layout:Int?
    
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
        format <- map["format"]
        language <- map["language"]
        vendor <- map["vendor"]
        app <- map["app"]
        
        tempStore <- map["latestId"]
        latestId <- map["latestId"]
        if latestId == nil, tempStore != nil {
            latestId = "\(String(describing: Int(tempStore!)))"
        }
        layout <- map["layout"]
    }
}

class App:Mappable
{
    var resolution:Int?
    var isNew:Bool?
    var type:Int?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        resolution <- map["resolution"]
        isNew <- map["isNew"]
        type <- map["type"]
    }
    
}
