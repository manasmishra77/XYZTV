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
    
    var homeData:BaseDataModel?
    var moviesData:BaseDataModel?
    var musicData:BaseDataModel?
    var tvData:BaseDataModel?
    var clipsData:BaseDataModel?
    var searchMovies:BaseDataModel?
    var languageData:BaseDataModel?
    var genreData:BaseDataModel?
    var mergedHomeData:[DataContainer]?
    
    var configData:ConfigData?
    var tvWatchList:WatchListDataModel?
    var moviesWatchList:WatchListDataModel?
    var resumeWatchList:ResumeWatchListDataModel?
    var userRecommendationList: UserRecommendationListDataModel?
    
    var languageGenreDetailModel:LanguageGenreDetailModel?
    
    var secretCdnTokenKey:String?
    var cdnEncryptionFlag:Bool = false
    var cdnUrlExpiryDuration:Int?
    
    enum Category
    {
        case Home
        case Movies
        case Music
        case TV
        case Clips
        case TVWatchList
        case MoviesWatchList
        case ResumeWatchList
        case Language
        case Genre
        case UserRecommendation
        
    }
    
    
    private init()
    {
        
    }
    
    public func setConfigData(withResponseData responseData:Data)
    {
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            self.configData = ConfigData(JSONString: responseString)
            if let configUrls = self.configData?.configDataUrls
            {
                if let cdnTokenKey = configUrls.cdnTokenKey
                {
                    self.setSecretCdnToken(recievedKey: cdnTokenKey)
                    
                }
                if let expiryDuration = configUrls.cdnUrlExpiryDuration
                {
                    self.cdnUrlExpiryDuration = expiryDuration
                }
                self.cdnEncryptionFlag = configUrls.cdnEncryptionFlag
            }
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
            case .TVWatchList:
                self.tvWatchList = WatchListDataModel(JSONString: responseString)
            case .MoviesWatchList:
                self.moviesWatchList = WatchListDataModel(JSONString: responseString)
            case .ResumeWatchList:
                self.resumeWatchList = ResumeWatchListDataModel(JSONString: responseString)
            case .UserRecommendation:
                self.userRecommendationList = UserRecommendationListDataModel(JSONString: responseString)
            case .Language:
                self.languageData = BaseDataModel(JSONString: responseString)
            case .Genre:
                self.genreData = BaseDataModel(JSONString: responseString)
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
                    self.mergedHomeData?.append(data)
                case .Movies:
                    self.moviesData?.data?.append(data)
                case .Music:
                    self.musicData?.data?.append(data)
                case .TV:
                    self.tvData?.data?.append(data)
                case .Clips:
                    self.clipsData?.data?.append(data)
                case .TVWatchList: break
                case .MoviesWatchList: break
                case .ResumeWatchList: break
                case .Language: break
                case .Genre: break
                case .UserRecommendation: break
                }
            }
        }
    }
    
    private func setSecretCdnToken(recievedKey:String) {
        var token:String = ""
        let cdnEncryptorKey = ["R:18", "e:5", "l:12", "i:9", "a:1", "n:14", "c:3", "e:5", "J:10", "i:9", "o:15"]
        let charArray = recievedKey.characters.map{String($0)}
        for key in cdnEncryptorKey{
            let index = Int(key.components(separatedBy: ":").last!)
            token.append(charArray[index! - 1])
        }
        self.secretCdnTokenKey = token
    }
    
}

