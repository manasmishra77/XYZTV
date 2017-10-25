//
//  AnalyticsEvent.swift
//  JioCinema
//
//  Created by Atinderpal Singh on 23/10/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

let JCANALYTICSEVENT_LOGINFAILED    = "login_failed"
let JCANALYTICSEVENT_LOGGEDIN       = "logged_in"
let JCANALYTICSEVENT_SEARCH         = "search"
let JCANALYTICSEVENT_MEDIASTART     = "media_start"
let JCANALYTICSEVENT_MEDIAEND       = "media_end"
let JCANALYTICSEVENT_MEDIAERROR     = "media_error"
let JCANALYTICSEVENT_SNAV           = "snav"




class JCAnalyticsEvent: NSObject {
    
    static let sharedInstance = JCAnalyticsEvent()
    
    func getLoginFailedEventForInternalAnalytics(jioID:String, errorMessage:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["userid":jioID,"message":errorMessage,"key":JCANALYTICSEVENT_LOGINFAILED]
        return eventDictionary
    }
    
    func getLoggedInEventForInternalAnalytics(methodOfLogin:String,source:String,jioIdValue:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["method":methodOfLogin,"Source":source,"identity":jioIdValue]
        return eventDictionary
    }
    
    func getSearchEventForInternalAnalytics(query:String,isvoice:String,queryResultCount:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["key":JCANALYTICSEVENT_SEARCH,"stext":query,"isvoice":isvoice,"scount":queryResultCount,"platform":"TVOS"]
        return eventDictionary
    }
    
    func getMediaStartEventForInternalAnalytics(contentId:String,mbid:String,mediaStartTime:String,categoryTitle:String,rowPosition:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["cid":contentId,"mbid":mbid,"from":mediaStartTime,"Source":categoryTitle,"Row Position":rowPosition]
        return eventDictionary
    }
    
    func getMediaEndEventForInternalAnalytics(contentId:String, playerCurrentPositionWhenMediaEnds:String, ts:String,  videoStartPlayingTime:String, bufferDuration:String, bufferCount:String, screenName:String, bitrate:String, playList:String, rowPosition:String, categoryTitle: String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["cid":contentId,
                               "epos":playerCurrentPositionWhenMediaEnds,
                               "ts":ts,
                               "ref":"player",
                               "s":videoStartPlayingTime,
                               "bd":bufferDuration,
                               "bc":bufferCount,
                               "screenName":screenName,
                               "Bitrate":bitrate,
                               "Playlist":playList,
                               "Row Position":rowPosition,
                               "Source":categoryTitle]
        return eventDictionary
    }

    
    func getMediaErrorEventForInternalAnalytics(descriptionMessage:String, errorCode:String, videoType:String,  contentTitle:String, contentId:String, videoQuality:String, bitrate:String, episodeSubtitle:String, playerErrorMessage:String, apiFailureCode: String, message:String, fpsFailure:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["desc":descriptionMessage,
                               "code":errorCode,
                               "Type":videoType,
                               "Title":contentTitle,
                               "cid":contentId,
                               "Quality":videoQuality,
                               "Bitrate":bitrate,
                               "Episode":episodeSubtitle,
                               "msg":playerErrorMessage,
                               "sec":apiFailureCode,
                               "serr":message,
                               "failure":fpsFailure]
        return eventDictionary
    }

    func getSNAVEventForInternalAnalytics(currentScreen:String, nextScreen:String, durationInCurrentScreen:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["ref":currentScreen,"refSection":nextScreen,"st":durationInCurrentScreen]
        return eventDictionary
    }

}
