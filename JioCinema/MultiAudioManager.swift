//
//  MultiAudioManager.swift
//  JioCinema
//
//  Created by Manas Mishra on 02/11/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class MultiAudioManager: NSObject {

    class func getItemAudioLanguage(languageIndex: LanguageIndex?, defaultAudioLanguage: String?, displayLanguage: String?) -> AudioLanguage {
        if let language = languageIndex?.name ?? defaultAudioLanguage ?? displayLanguage {
            if let audioLanguage = AudioLanguage(rawValue: language.lowercased()) {
                return audioLanguage
            }
        }
        return .none
    }
    
    //Check in my watchlist
    class func checkAndReturnFromMyWatchList(itemIdToBeChecked: String, appType: VideoType) -> Item? {
        if appType == .Movie {
            if let movieWatchListArray = JCDataStore.sharedDataStore.moviesWatchList?.data?.items {
                let itemMatched = movieWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
                return itemMatched
            }
        } else if appType == .TVShow || appType == .Episode {
            if let tvWatchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?.items {
                let itemMatched = tvWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
                return itemMatched
            }
        }
        return nil
    }
    //Check in resume watchlist
    class func checkAndReturnFromResumeWatchList(itemIdToBeChecked: String) -> Item? {
        if let resumeWatchListArray = JCDataStore.sharedDataStore.resumeWatchList?.data?.items {
            let itemMatched = resumeWatchListArray.filter{ $0.id == itemIdToBeChecked}.first
            return itemMatched
        }
        return nil
    }
    
    class func getAudioLanguageForLangGenreVC(defaultAudioLanguage: AudioLanguage?, item: Item) -> AudioLanguage {
        return defaultAudioLanguage ?? item.audioLanguage
    }
    
    class func changeDefaultAudioLangForGenreVC(selectedAudioLang: String?) -> AudioLanguage? {
        let audioLAng = AudioLanguage(rawValue: selectedAudioLang ?? "")
        return audioLAng
    }
    
   
    
    class func getFinalAudioLanguage(itemIdToBeChecked: String, appType: VideoType, defaultLanguage: AudioLanguage?) -> AudioLanguage {
        if let item = MultiAudioManager.checkAndReturnFromResumeWatchList(itemIdToBeChecked: itemIdToBeChecked) {
            return item.audioLanguage
        }
        if let item = MultiAudioManager.checkAndReturnFromMyWatchList(itemIdToBeChecked: itemIdToBeChecked, appType: appType) {
            return item.audioLanguage
        }
        return defaultLanguage ?? .none
    }
}

enum AudioLanguage: String {
    case english
    case hindi
    case tamil
    case telugu
    case marathi
    case bengali
    case none
    
    var code: String {
        return self.rawValue.subString(start: 0, end: 1)
    }
    var name: String {
        return self.rawValue.capitalized
    }
    
}
