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
        case subId
        case lbCookie
        case ssoToken
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lbCookie = try values.decodeIfPresent(String.self, forKey: .lbCookie)
        ssoToken = try values.decodeIfPresent(String.self, forKey: .ssoToken)
        let sessionAttributeDict = try values.decodeIfPresent([String: [String: String]].self, forKey: .subId)
        subId = (sessionAttributeDict?["user"])?["subscriberId"]
        
    }
}
