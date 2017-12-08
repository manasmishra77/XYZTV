//
//  JCAppUser.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 11/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
import UIKit

class JCAppUser:NSObject,NSCoding
{
    
    static var shared = JCAppUser()
    
    override init(){} //singleTone
    
    var jToken:String = ""
    var lbCookie:String = ""
    var commonName:String = ""
    var preferredLocale:String = ""
    var ssoLevel:String = ""
    var subscriberId:String = ""
    var ssoToken:String = ""
    var profileId:String = ""
    var profileName:String = ""
    var mail:String = ""
    var mobile:String = ""
    var uid:String = ""
    var unique:String = ""
    var userGroup:String = ""
    var mToken: String = ""
    
    
    required init?(coder aDecoder: NSCoder)
    {
        self.jToken = aDecoder.decodeObject(forKey: "jToken") as? String ?? ""
        self.lbCookie = aDecoder.decodeObject(forKey: "lbCookie") as? String ?? ""
        self.commonName = aDecoder.decodeObject(forKey: "commonName") as? String ?? ""
        self.preferredLocale = aDecoder.decodeObject(forKey: "preferredLocale") as? String ?? ""
        self.ssoLevel = aDecoder.decodeObject(forKey: "ssoLevel") as? String ?? ""
        self.subscriberId = aDecoder.decodeObject(forKey: "subscriberId") as? String ?? ""
        self.ssoToken = aDecoder.decodeObject(forKey: "ssoToken") as? String ?? ""
        self.profileId = aDecoder.decodeObject(forKey: "profileId") as? String ?? ""
        self.profileName = aDecoder.decodeObject(forKey: "profileName") as? String ?? ""
        self.mail = aDecoder.decodeObject(forKey: "mail") as? String ?? ""
        self.mobile = aDecoder.decodeObject(forKey: "mobile") as? String ?? ""
        self.uid = aDecoder.decodeObject(forKey: "uid") as? String ?? ""
        self.unique = aDecoder.decodeObject(forKey: "unique") as? String ?? ""
        self.userGroup = aDecoder.decodeObject(forKey: "userGroup") as? String ?? ""
        self.mToken = aDecoder.decodeObject(forKey: "mToken") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(jToken, forKey: "jToken")
        aCoder.encode(lbCookie, forKey: "lbCookie")
        aCoder.encode(commonName, forKey: "commonName")
        aCoder.encode(preferredLocale, forKey: "preferredLocale")
        aCoder.encode(ssoLevel, forKey: "ssoLevel")
        aCoder.encode(subscriberId, forKey: "subscriberId")
        aCoder.encode(ssoToken, forKey: "ssoToken")
        aCoder.encode(profileId, forKey: "profileId")
        aCoder.encode(profileName, forKey: "profileName")
        aCoder.encode(mail, forKey: "mail")
        aCoder.encode(mobile, forKey: "mobile")
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(unique, forKey: "unique")
        aCoder.encode(userGroup, forKey: "userGroup")
        aCoder.encode(mToken, forKey: "mToken")
        
    }
    
}

