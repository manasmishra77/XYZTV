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
    var isPinActive : Bool?
    let isParentalLockEnabled: Bool?
    let parentalSettings : ParentalSettings?
    let isEmailVerified : Bool?
    
    enum CodingKeys: String, CodingKey {
        case emailId
        case pin
        case isPinActive
        case parentalSettings
        case isParentalLockEnabled = "parentalLockEnabled"
        case isEmailVerified = "emailVerified"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        emailId = try values.decodeIfPresent(String.self, forKey: .emailId)
        pin = try values.decodeIfPresent(String.self, forKey: .pin)
        if let pinActive = try values.decodeIfPresent(String.self, forKey: .isPinActive) {
            isPinActive = (pinActive == "Y")
        } else {
            isPinActive = false
        }
        if let parentalEnable = try values.decodeIfPresent(String.self, forKey: .isParentalLockEnabled) {
            isParentalLockEnabled = (parentalEnable == "Y")
        }
        else {
            isParentalLockEnabled = false
        }
        parentalSettings = try values.decodeIfPresent(ParentalSettings.self, forKey: .parentalSettings)
        if let emailVerified = try values.decodeIfPresent(String.self, forKey: .isEmailVerified) {
            isEmailVerified = (emailVerified == "Y")
        } else {
            isEmailVerified = false
        }
    }
    
}

struct ParentalSettings : Codable {
    let allAge : AgeCategory?
    let age3Plus : AgeCategory?
    let age7Plus : AgeCategory?
    let age13Plus : AgeCategory?
    let age18Plus : AgeCategory?
    
    var allowedAgeGrpCategory: AgeGroup {
        let ageGrps = [age18Plus, age13Plus, age7Plus, age3Plus, allAge]
        for each in ageGrps {
            if each?.isAllowed == true {
                return each?.ageGroup ?? .allAge
            }
        }
        return .allAge
    }
    
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
    let isAllowed: Bool?
    var ageGroup: AgeGroup? {
        if let value = self.value {
            return AgeGroup(rawValue: value)
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case label
        case value
        case order
        case isAllowed = "selected"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        order = try values.decodeIfPresent(Int.self, forKey: .order)
        isAllowed = try values.decodeIfPresent(Bool.self, forKey: .isAllowed)
    }
    
}

enum AgeGroup: String {
    case allAge = "All"
    case age3Plus = "3+"
    case age7Plus = "7+"
    case age13Plus = "13+"
    case age18Plus = "18+"
    
    var ageIntValue: Int {
        if let ageInt = Int(self.rawValue.dropLast()) {
            return ageInt
        }
        return 0
    }
}
