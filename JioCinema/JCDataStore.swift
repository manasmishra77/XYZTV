//
//  JCDataStore.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

class JCDataStore
{
    static let sharedDataStore: JCDataStore = JCDataStore()
    
    var configData:ConfigData?
    var homeData:BaseDataModel?
    var moviesData:BaseDataModel?
    var musicData:BaseDataModel?
    var tvData:BaseDataModel?
    var clipsData:BaseDataModel?
    var searchMovies:BaseDataModel?
    
    enum Category
    {
        case Home
        case Movies
        case Music
        case TV
        case Clips
    }
    
    enum SearchResultType:String
    {
        case Movies = "Movies"
        case MusicVideos = "Music Videos"
        case Episodes = "Episodes"
        case ShortMovies = "Short Movies"
        case Brand = "Eros Now"
        case Trailer = "Trailers"
    }
    
    
    private init()
    {
    
    }
    
    public func setConfigData(withResponseData responseData:Data)
    {
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            self.configData = ConfigData(JSONString: responseString)
        }
    }
    

    
    public func setData(withResponseData responseData:Data, category:Category)
    {
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            switch category {
            case .Home:
                self.homeData = BaseDataModel(JSONString: responseString)
            case .Movies:
                self.moviesData = BaseDataModel(JSONString: responseString)
            case .Music:
                self.musicData = BaseDataModel(JSONString: responseString)
            case .Clips:
                self.clipsData = BaseDataModel(JSONString: responseString)
            case .TV:
                self.tvData = BaseDataModel(JSONString: responseString)
            }
            
        }
    }
    
    public func appendData(withResponseData responseData:Data, category:Category)
    {
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            let newData = BaseDataModel(JSONString: responseString)
            for data in (newData?.data)! {
                switch category {
                case .Home:
                    self.homeData?.data?.append(data)
                case .Movies:
                    self.moviesData?.data?.append(data)
                case .Music:
                    self.musicData?.data?.append(data)
                case .TV:
                    self.tvData?.data?.append(data)
                case .Clips:
                    self.clipsData?.data?.append(data)
                }
            }
        }
    }
}
