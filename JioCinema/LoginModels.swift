//
//  LoginModels.swift
//  JioCinema
//
//  Created by Manas Mishra on 24/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

struct SignInSuperModel: Codable {
    var code: Int?
    var result: SignInModel?
    var userGrp: String?
}

struct SignInModel: Codable {
    var lbCookie: String?
    var ssoToken: String?
    var displayName: String?
    var subscriberId: String?
    var mail: String?
    var profileId: String?
    var uId: String?
    var uniqueId: String?
    var mToken: String?
    //Login via subId
    var name: String?
    var userGrp: String?
}

struct OTPModel: Codable {
    var subId: String?
    var lbCookie: String?
    var ssoToken: String?
    enum CodingKeys: String, CodingKey {
        case subId = "sessionAttributes"
        case lbCookie
        case ssoToken
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lbCookie = try values.decodeIfPresent(String.self, forKey: .lbCookie)
        ssoToken = try values.decodeIfPresent(String.self, forKey: .ssoToken)
        let sessionAttribute = try values.decodeIfPresent(SessionAttributes.self, forKey: .subId)
        subId = sessionAttribute?.user?.subscriberId
        
    }
}
struct SessionAttributes : Codable {
    let otpValidatedDate : String?
    let passwordExpiry : String?
    let profile : OTPProfile?
    let user : OTPUser?
    
    enum CodingKeys: String, CodingKey {
        
        case otpValidatedDate = "otpValidatedDate"
        case passwordExpiry = "passwordExpiry"
        case profile = "profile"
        case user = "user"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        otpValidatedDate = try values.decodeIfPresent(String.self, forKey: .otpValidatedDate)
        passwordExpiry = try values.decodeIfPresent(String.self, forKey: .passwordExpiry)
        profile = try values.decodeIfPresent(OTPProfile.self, forKey: .profile)
        user = try values.decodeIfPresent(OTPUser.self, forKey: .user)
    }
    
}
struct OTPProfile : Codable {
    let billingId : String?
    let entitlements : [String]?
    let profileId : String?
    let profileName : String?
    
    enum CodingKeys: String, CodingKey {
        
        case billingId = "billingId"
        case entitlements = "entitlements"
        case profileId = "profileId"
        case profileName = "profileName"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        billingId = try values.decodeIfPresent(String.self, forKey: .billingId)
        entitlements = try values.decodeIfPresent([String].self, forKey: .entitlements)
        profileId = try values.decodeIfPresent(String.self, forKey: .profileId)
        profileName = try values.decodeIfPresent(String.self, forKey: .profileName)
    }
    
}
struct OTPUser : Codable {
    let commonName : String?
    let mail : String?
    let mobile : String?
    let preferredLocale : String?
    let ssoLevel : String?
    let subscriberId : String?
    let uid : String?
    let unique : String?
    
    enum CodingKeys: String, CodingKey {
        
        case commonName = "commonName"
        case mail = "mail"
        case mobile = "mobile"
        case preferredLocale = "preferredLocale"
        case ssoLevel = "ssoLevel"
        case subscriberId = "subscriberId"
        case uid = "uid"
        case unique = "unique"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        commonName = try values.decodeIfPresent(String.self, forKey: .commonName)
        mail = try values.decodeIfPresent(String.self, forKey: .mail)
        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
        preferredLocale = try values.decodeIfPresent(String.self, forKey: .preferredLocale)
        ssoLevel = try values.decodeIfPresent(String.self, forKey: .ssoLevel)
        subscriberId = try values.decodeIfPresent(String.self, forKey: .subscriberId)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        unique = try values.decodeIfPresent(String.self, forKey: .unique)
    }
    
}

