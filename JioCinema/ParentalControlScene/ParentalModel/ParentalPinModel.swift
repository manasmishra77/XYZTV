//
//  ParentalPinModel.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/14/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

struct ParentalPinModel : Codable {
    let emailId : String?
    let pin : String?
    let isPinActive : Bool?
    let parentalSettings : ParentalSettings?
    let isEmailVerified : Bool?
    
    enum CodingKeys: String, CodingKey {
        case emailId
        case pin
        case isPinActive
        case parentalSettings
        case isEmailVerified = "emailVerified"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        emailId = try values.decodeIfPresent(String.self, forKey: .emailId)
        pin = try values.decodeIfPresent(String.self, forKey: .pin)
        isPinActive = try values.decodeIfPresent(Bool.self, forKey: .isPinActive)
        parentalSettings = try values.decodeIfPresent(ParentalSettings.self, forKey: .parentalSettings)
        isEmailVerified = try values.decodeIfPresent(Bool.self, forKey: .isEmailVerified)
    }
    
}

struct ParentalSettings : Codable {
    let allAge : AgeCategory?
    let age3Plus : AgeCategory?
    let age7Plus : AgeCategory?
    let age13Plus : AgeCategory?
    let age18Plus : AgeCategory?
    
    enum CodingKeys: String, CodingKey {
        
        case allAge = "All"
        case age3Plus = "3+"
        case age7Plus = "7+"
        case age13Plus = "13+"
        case age18Plus = "18+"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        allAge = try values.decodeIfPresent(AgeCategory.self, forKey: .allAge)
        age3Plus = try values.decodeIfPresent(AgeCategory.self, forKey: .age3Plus)
        age7Plus = try values.decodeIfPresent(AgeCategory.self, forKey: .age7Plus)
        age13Plus = try values.decodeIfPresent(AgeCategory.self, forKey: .age13Plus)
        age18Plus = try values.decodeIfPresent(AgeCategory.self, forKey: .age18Plus)
    }
    
}
struct AgeCategory : Codable {
    let label : String?
    let value : String?
    let order : Int?
    
    enum CodingKeys: String, CodingKey {
        case label
        case value
        case order
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        order = try values.decodeIfPresent(Int.self, forKey: .order)
    }
    
}
