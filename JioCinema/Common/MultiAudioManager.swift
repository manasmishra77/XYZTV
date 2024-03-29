//
//  MultiAudioManager.swift
//  JioCinema
//
//  Created by Manas Mishra on 02/11/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class MultiAudioManager: NSObject {

    class func getItemAudioLanguage(languageIndex: LanguageIndex?, defaultAudioLanguage: String?, displayLanguage: String?) -> AudioLanguage? {
        if let language = languageIndex?.name ?? defaultAudioLanguage ?? displayLanguage {
            if let audioLanguage = AudioLanguage(rawValue: language.lowercased()) {
                return audioLanguage
            }
        }
        return nil
    }
    
    //Check in my watchlist
    class func checkAndReturnFromMyWatchList(itemIdToBeChecked: String, appType: VideoType) -> Item? {
        var iteMatched: Item? = nil
        if appType == .Movie {
            if let movieWatchListArray = JCDataStore.sharedDataStore.moviesWatchList?.data?[0].items {
                iteMatched = movieWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
            }
            if iteMatched == nil {
                if let disneyMovieWatchListArray = JCDataStore.sharedDataStore.disneyMovieWatchList?.data?[0].items {
                    iteMatched = disneyMovieWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
                }
            }
            return iteMatched
        } else if appType == .TVShow || appType == .Episode {
            if let tvWatchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?[0].items {
                iteMatched = tvWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
            }
            if iteMatched == nil {
                if let disneyTVWatchListArray = JCDataStore.sharedDataStore.disneyTVWatchList?.data?[0].items {
                    iteMatched = disneyTVWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
                }
                return iteMatched
            } 
            
        }
        return nil
    }
    //Check in resume watchlist
    class func checkAndReturnFromResumeWatchList(itemIdToBeChecked: String) -> Item? {
        var iteMatched: Item? = nil
        if let resumeWatchListArray = JCDataStore.sharedDataStore.resumeWatchList?.data?[0].items {
            iteMatched = resumeWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
        }
        if iteMatched == nil {
            if let disneyResumeWatchListArray = JCDataStore.sharedDataStore.disneyResumeWatchList?.data?[0].items {
                iteMatched = disneyResumeWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
            }
        }
        return iteMatched
    }
    
    class func getAudioLanguageForLangGenreVC(defaultAudioLanguage: AudioLanguage?, item: Item) -> AudioLanguage? {
        return defaultAudioLanguage ?? item.audioLanguage
    }
    
    class func changeDefaultAudioLangForGenreVC(selectedAudioLang: String?) -> AudioLanguage? {
        let audioLAng = AudioLanguage(rawValue: selectedAudioLang ?? "")
        return audioLAng
    }
    
   
    
    class func getFinalAudioLanguage(itemIdToBeChecked: String, appType: VideoType, defaultLanguage: AudioLanguage?) -> AudioLanguage? {
        if let item = MultiAudioManager.checkAndReturnFromResumeWatchList(itemIdToBeChecked: itemIdToBeChecked) {
            return item.audioLanguage
        }
        if let item = MultiAudioManager.checkAndReturnFromMyWatchList(itemIdToBeChecked: itemIdToBeChecked, appType: appType) {
            return item.audioLanguage
        }
        return defaultLanguage
    }
}
//Additon for multi-audio analytics
extension MultiAudioManager {
    class func getAudioChangedEventForInternalAnalytics(screenName :String, source :String,playerCurrentPositionWhenMediaEnds  :Int, contentId :String, bufferDuration :Int, timeSpent :Int, type :String, bufferCount :Int) -> Dictionary<String, Any>{
        let eventDictionary = [ "platform":"TVOS",
                                "screenname" : screenName,
                                "source": source,
                                "epos": playerCurrentPositionWhenMediaEnds,
                                "cid": contentId,
                                "bd": bufferDuration,
                                "ts": timeSpent,
                                "Type": type,
                                "bc": bufferCount] as [String : Any]
        return JCAnalyticsEvent.sharedInstance.getFinalEventDictionary(proDictionary: eventDictionary, eventKey: JCANALYTICSEVENT_AUDIOCHANGED)
    }
}

enum AudioLanguage: String {
    case english
    case hindi
    case tamil
    case telugu
    case marathi
    case bengali
    case kannada
    case punjabi
    case gujarati
    case bhojpuri
    case malayalam
    //case none
    
    var code: String {
        return self.rawValue.subString(start: 0, end: 1)
    }
    var name: String {
        return self.rawValue.capitalized
    }
    
}
