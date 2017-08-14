//
//  JCMetadataModel.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 09/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class MetadataModel:Mappable
{
    var appkey:String?
    var type:Int?
    var contentId:String?
    var showdate:String?
    var isTrailerAvailable:Bool?
    var trailerId:String?
    var releasedDate:String?
    var createdDate:String?
    var version:Int?
    var isDRM:Bool?
    var videoId:String?
    var folder1:Int?
    var folder2:Int?
    var imageId:String?
    var videoExt:String?
    var imageExt:String?
    var flavorParamsId:String?
    var tags:String?
    var singer:[String]?
    var categories:String?
    var category:String?
    var label:[String]?
    var views:Int?
    var validTo:String?
    var validFrom:String?
    var isSTB:Bool?
    var productionHouse:String?
    var approved:Bool?
    var isHD:Bool?
    var isLegal:Bool?
    var updatedAt:String?
    var censorCertificate:String?
    var id:String?
    var intCensorCertificate:Int?
    var costStructure:String?
    var vendor:String?
    var albumname:String?
    var awards:String?
    var writer:String?
    var isEncrypt:Bool?
    var newmpd:Int?
    var AESkey:String?
    var musicDirector:[String]?
    var latestEpisodeId:String?
    var lyricist:[String]?
    var publisher:String?
    var name:String?
    var subtitle:String?
    var resumeSubtitle:String?
    var listSubtitle:String?
    var year:Int?
    var artist:[String]?
    var genres:[String]?
    var artistObj:[ArtistObj]?
    var directors:[String]?
    var description:String?
    var rating:String?
    var review:[String]?
    var image:String?
    var banner:String?
    var format:Int?
    var language:String?
    var totalDuration:Int?
    var recomTime:Int?
    var isDownloadable:Bool?
    var thumb:String?
    var srt:String?
    var dateUploaded:String?
    var dateTranscoded:String?
    var status:Int?
    var bitrate:String?
    var threshold:Int?
    var app:App?
    var categoryName:[String]?
    var categoryId:[Int]?
    var tinyUrl:String?
    var download:Bool?
    var primaryGenres:[String]?
    var recTags:String?
    var fpsKey:String?
    var fpsIv:String?
    var catData:[CategoryData]?
    var newSubtitle:String?
    var flavorCount:Int?
    var oldFolder1:Int?
    var oldFolder2:Int?
    var isMoved:Bool?
    var meta:Meta?
    var code:Int?
    var displayText:String?
    var more:[More]?
    

    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        appkey <- map["appkey"]
        type <- map["type"]
        contentId <- map["contentId"]
        showdate <- map["showdate"]
        isTrailerAvailable <- map["isTrailerAvailable"]
        trailerId <- map["trailerId"]
        releasedDate <- map["releasedDate"]
        createdDate <- map["createdDate"]
        version <- map["version"]
        isDRM <- map["isDRM"]
        videoId <- map["videoId"]
        folder1 <- map["folder1"]
        folder2 <- map["folder2"]
        imageId <- map["imageId"]
        videoExt <- map["videoExt"]
        imageExt <- map["imageExt"]
        flavorParamsId <- map["flavorParamsId"]
        tags <- map["tags"]
        singer <- map["singer"]
        categories <- map["categories"]
        category <- map["category"]
        label <- map["label"]
        views <- map["views"]
        validTo <- map["validTo"]
        validFrom <- map["validFrom"]
        isSTB <- map["isSTB"]
        productionHouse <- map["productionHouse"]
        approved <- map["approved"]
        isHD <- map["isHD"]
        isLegal <- map["isLegal"]
        updatedAt <- map["updatedAt"]
        censorCertificate <- map["censorCertificate"]
        id <- map["id"]
        intCensorCertificate <- map["intCensorCertificate"]
        costStructure <- map["costStructure"]
        vendor <- map["vendor"]
        albumname <- map["albumname"]
        awards <- map["awards"]
        writer <- map["writer"]
        isEncrypt <- map["isEncrypt"]
        newmpd <- map["newmpd"]
        AESkey <- map["AESkey"]
        musicDirector <- map["musicDirector"]
        latestEpisodeId <- map["latestEpisodeId"]
        lyricist <- map["lyricist"]
        publisher <- map["publisher"]
        name <- map["name"]
        subtitle <- map["subtitle"]
        resumeSubtitle <- map["resumeSubtitle"]
        listSubtitle <- map["listSubtitle"]
        year <- map["year"]
        artist <- map["artist"]
        genres <- map["genres"]
        artistObj <- map["artistObj"]
        directors <- map["directors"]
        description <- map["description"]
        rating <- map["rating"]
        review <- map["review"]
        image <- map["image"]
        banner <- map["banner"]
        format <- map["format"]
        language <- map["language"]
        totalDuration <- map["totalDuration"]
        recomTime <- map["recomTime"]
        isDownloadable <- map["isDownloadable"]
        thumb <- map["thumb"]
        srt <- map["srt"]
        dateUploaded <- map["dateUploaded"]
        dateTranscoded <- map["dateTranscoded"]
        status <- map["status"]
        bitrate <- map["bitrate"]
        threshold <- map["threshold"]
        app <- map["app"]
        categoryName <- map["categoryName"]
        categoryId <- map["categoryId"]
        tinyUrl <- map["tinyUrl"]
        download <- map["download"]
        primaryGenres <- map["primaryGenres"]
        recTags <- map["recTags"]
        fpsKey <- map["fpsKey"]
        fpsIv <- map["fpsIv"]
        catData <- map["catData"]
        newSubtitle <- map["newSubtitle"]
        flavorCount <- map["flavorCount"]
        oldFolder1 <- map["oldFolder1"]
        oldFolder2 <- map["oldFolder2"]
        isMoved <- map["isMoved"]
        meta <- map["meta"]
        code <- map["code"]
        displayText <- map["displayText"]
        more <- map["more"]
    }
}

class ArtistObj:Mappable
{
    var first:String?
    var last:String?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        first <- map["first"]
        last <- map["last"]
    }
}

class CategoryData:Mappable
{
    var id:Int?
    var name:String?
    var order:Int?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        id <- map["id"]
        name <- map["name"]
        order <- map["order"]
    }
}

class Meta:Mappable
{
    var revision:Int?
    var created:String?
    var version:Int?
    var updated:String?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        revision <- map["revision"]
        created <- map["created"]
        version <- map["version"]
        updated <- map["version"]
    }
}

class More:Mappable
{
    var id:String?
    var name:String?
    var subtitle:String?
    var banner:String?
    var format:Int?
    var language:String?
    var app:App?
    var rating:Double?
    var description:String?
    var year:Int?
    var genres:[String]?
    var totalDuration:Int?
    var srt:String?
    var totalDurationString:String?
    var image:String?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        id <- map["id"]
        name <- map["name"]
        subtitle <- map["subtitle"]
        banner <- map["banner"]
        format <- map["format"]
        language <- map["language"]
        app <- map["app"]
        rating <- map["rating"]
        description <- map["description"]
        year <- map["year"]
        genres <- map["genres"]
        totalDuration <- map["totalDuration"]
        srt <- map["srt"]
        totalDurationString <- map["totalDurationString"]
        image <- map["image"]
    }
}



