//
//  JCTrendingSearchTextSuperModel.swift
//  JioCinema
//
//  Created by manas on 24/05/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

struct JCTrendingSearchTextSuperModel : Codable {
    let code : Int?
    let message : String?
    let data : [String: [PopularSearches]]?
    
    enum CodingKeys: String, CodingKey {
        
        case code = "code"
        case message = "message"
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([String: [PopularSearches]].self, forKey: .data)
    }
    
}

struct PopularSearches : Codable {
    let key : String?
    let count : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case key = "key"
        case count = "count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decodeIfPresent(String.self, forKey: .key)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
    }
    
}

