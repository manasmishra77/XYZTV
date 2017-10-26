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
    
    func getFinalEventDictionary(proDictionary:Dictionary<String, Any>,eventKey:String) -> Dictionary<String, Any>
    {
        let sid = Date().toString(dateFormat: "yyyy-MM-dd hh:mm:ss") + UIDevice.current.identifierForVendor!.uuidString
        let finalDictionary = ["sid":sid,
                               "akey":kAppKeyValue,
                               "uid":JCAppUser.shared.uid,
                               "crmid":JCAppUser.shared.unique,
                               "profileid":JCAppUser.shared.profileId,
                               "idamid":JCAppUser.shared.unique,
                               "rtc":Date().toString(dateFormat: "yyyy-MM-dd hh:mm:ss"),
                               "did":UIDevice.current.identifierForVendor!.uuidString,
                               "pf":"O",
                               "nwk":"WIFI",
                               "dtpe":"B",
                               "osv":UIDevice.current.systemVersion,
                               "mnu":"apple",
                               "avn":Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                               "key":eventKey,
                               "pro":proDictionary] as [String : Any]
        return finalDictionary
    }
    
    func getLoginFailedEventForInternalAnalytics(jioID:String, errorMessage:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","userid":jioID,"message":errorMessage,"key":JCANALYTICSEVENT_LOGINFAILED]
        
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_LOGINFAILED )
    }
    
    func getLoggedInEventForInternalAnalytics(methodOfLogin:String,source:String,jioIdValue:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","method":methodOfLogin,"Source":source,"identity":jioIdValue]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_LOGGEDIN )
    }
    
    func getSearchEventForInternalAnalytics(query:String,isvoice:String,queryResultCount:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","key":JCANALYTICSEVENT_SEARCH,"stext":query,"isvoice":isvoice,"scount":queryResultCount]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_SEARCH )
    }
    
    func getMediaStartEventForInternalAnalytics(contentId:String,mbid:String,mediaStartTime:String,categoryTitle:String,rowPosition:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","cid":contentId,"mbid":mbid,"from":mediaStartTime,"Source":categoryTitle,"Row Position":rowPosition]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_MEDIASTART )
    }
    
    func getMediaEndEventForInternalAnalytics(contentId:String, playerCurrentPositionWhenMediaEnds:String, ts:String,  videoStartPlayingTime:String, bufferDuration:String, bufferCount:String, screenName:String, bitrate:String, playList:String, rowPosition:String, categoryTitle: String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS",
                               "cid":contentId,
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
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_MEDIAEND )
    }

    
    func getMediaErrorEventForInternalAnalytics(descriptionMessage:String, errorCode:String, videoType:String,  contentTitle:String, contentId:String, videoQuality:String, bitrate:String, episodeSubtitle:String, playerErrorMessage:String, apiFailureCode: String, message:String, fpsFailure:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS",
                               "desc":descriptionMessage,
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
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_MEDIAERROR )
    }

    func getSNAVEventForInternalAnalytics(currentScreen:String, nextScreen:String, durationInCurrentScreen:String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS",
                               "ref":currentScreen,"refSection":nextScreen,"st":durationInCurrentScreen]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_SNAV )
    }

}
