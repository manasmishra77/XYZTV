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
let JCANALYTICSEVENT_APPLAUNCH      = "application_launched"
let JCANALYTICSEVENT_URL            = "https://collect.media.jio.com/postdata/event"


let JCANALYTICSEVENT_PARENTALPOPUP  = "Parental_PIN_Popup"
let JCANALYTICSEVENT_PARENTALTILE   = "Parental_Control_Tile"
let JCANALYTICSEVENT_PINENTRYSTATUS = "PIN_Entry_Status"
let JCANALYTICSEVENT_PARENTALPINASK = "PIN_Asked"
let JCANALYTICSEVENT_PARENTALCODE = "Code_Generated"

class JCAnalyticsEvent: NSObject {
    
    static let sharedInstance = JCAnalyticsEvent()
    private override init() {
        super.init()
    }
    
    private var isApplicationLaunchEventSent = false
    
    func getFinalEventDictionary(proDictionary: Dictionary<String, Any>, eventKey:String) -> Dictionary<String, Any>
    {
//        let sid = Date().toString(dateFormat: "yyyy-MM-dd hh:mm:ss") + UIDevice.current.identifierForVendor!.uuidString
//
//        let hash = convertStringToMD5Hash(artistName: sid)
//        let hexEncodedHash = hash.hexEncodedString()
//
//        let rtcEpoch = String(describing:Date().timeIntervalSince1970)
//
//        let finalDictionary = ["sid":hexEncodedHash,"akey":"109153001", "uid":JCAppUser.shared.uid,"crmid":JCAppUser.shared.unique, "profileid":JCAppUser.shared.profileId, "idamid":JCAppUser.shared.unique, "rtc":rtcEpoch,"did":UIDevice.current.identifierForVendor!.uuidString, "pf":"O", "nwk":"WIFI","dtpe":"B","osv":UIDevice.current.systemVersion,"mnu":"apple","avn":Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,"key":eventKey,"pro":proDictionary] as [String : Any]
//        return finalDictionary
        let sid = Date().toString(dateFormat: "yyyy-MM-dd hh:mm:ss") + UIDevice.current.identifierForVendor!.uuidString
        
        let hash = convertStringToMD5Hash(artistName: sid)
        let hexEncodedHash = hash.hexEncodedString()
        
        let rtcEpoch = String(describing: Date())// String(describing:Int(Date().timeIntervalSince1970))
        let avnString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        //        if let avnValue = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String{
        //            avnString = avnValue
        //        }
        
        let finalDictionary = ["sid":hexEncodedHash,"akey":"109153001","uid":JCAppUser.shared.uid, "crmid":JCAppUser.shared.unique,"profileid":JCAppUser.shared.profileId,"idamid":JCAppUser.shared.unique,"rtc":rtcEpoch,"did":UIDevice.current.identifierForVendor!.uuidString,"pf":"O","nwk": "WIFI","dtpe":"B","osv": UIDevice.current.systemVersion,"mnu":"apple","avn": avnString,"key":eventKey,"pro": proDictionary] as [String : Any]
        return finalDictionary
    }
    
    func sendAppLaunchEvent() {
        if isApplicationLaunchEventSent {
            return
        }
        let applaunchInternalEvent = JCAnalyticsEvent.sharedInstance.getApplaunchEventForInternalAnalytics()
        self.sendEventForInternalAnalytics(paramDict: applaunchInternalEvent)
        isApplicationLaunchEventSent = true
    }
    
    private func getApplaunchEventForInternalAnalytics() -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","sorce":"App_Launch","key":JCANALYTICSEVENT_APPLAUNCH]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_APPLAUNCH )
        
    }
    
    func getParentalPINPopupActionPerformedEvent(userAction: String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","User_Action":userAction,"key":JCANALYTICSEVENT_PARENTALPOPUP]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PARENTALPOPUP)
    }
    
    func getParentalPINAskEvent(userAction: String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","User_Action":userAction,"key":JCANALYTICSEVENT_PARENTALPINASK]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PARENTALPINASK)
    }
    
    func getParentalPINCodeGeneratedEvent(alreadySetPin: String) -> Dictionary<String, Any>
    {
        let eventDictionary = ["platform":"TVOS","User_Action":alreadySetPin,"key":JCANALYTICSEVENT_PARENTALCODE]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PARENTALCODE)
    }
    
    func getParentalControlTileEvent() -> Dictionary<String, Any> {
        let eventDictionary = ["platform":"TVOS","key":JCANALYTICSEVENT_PARENTALTILE]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PARENTALTILE)
    }
    
    func getParentalControlTileSelectEvent() -> Dictionary<String, Any> {
        let eventDictionary = ["platform":"TVOS", "click": "TRUE","key":JCANALYTICSEVENT_PARENTALTILE]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PARENTALTILE)
    }
    
    func getParentalPINEntryStatusEvent(resultStatus: String, errorString: String?) -> Dictionary<String, Any> {
        var eventDictionary = ["platform":"TVOS", "Result": resultStatus,"key":JCANALYTICSEVENT_PINENTRYSTATUS]
        
        if let error = errorString {
            eventDictionary = ["platform":"TVOS", "Result": resultStatus, "PIN_Entry_Error": error, "key":JCANALYTICSEVENT_PINENTRYSTATUS]
        }
        
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PINENTRYSTATUS)
    }
    
    func getParentalPINEntryViewedEvent() -> Dictionary<String, Any> {
        let eventDictionary = ["platform":"TVOS", "key":JCANALYTICSEVENT_PARENTALPINASK]
        return self.getFinalEventDictionary(proDictionary: eventDictionary,eventKey:JCANALYTICSEVENT_PARENTALPINASK)
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
    
    func getMediaEndEventForInternalAnalytics(contentId:String, playerCurrentPositionWhenMediaEnds: Int, ts:Int,  videoStartPlayingTime: Int, bufferDuration: Int, bufferCount: Int, screenName:String, bitrate:String, playList:String, rowPosition:String, categoryTitle: String, director: String, starcast: String, contentp: String) -> [String : Any]
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
                               "Source":categoryTitle,
                               "director": director,
                               "starcast": starcast,
                               "contentp": contentp
            ] as [String : Any]
        return self.getFinalEventDictionary(proDictionary: eventDictionary, eventKey: JCANALYTICSEVENT_MEDIAEND)
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
    
    func sendEventForInternalAnalytics(paramDict: [String: Any]) {
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: JCANALYTICSEVENT_URL, params: paramDict, encoding: .JSON)
        
        RJILApiManager.defaultManager.post(request: loginRequest)
        {
            (data, response, error) in
            if let responseError = error
            {
                print(responseError)
                return
            }
            
            if let responseData = data, let parsedResponse:[String: Any] = RJILApiManager.parse(data: responseData)
            {
                print(parsedResponse)
                let code = parsedResponse["code"] as? Int
                if(code == 200) {
                    
                }
                
            }
        }
    }
    
    func convertStringToMD5Hash(artistName:String) -> Data
    {
        let messageData = artistName.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
}


