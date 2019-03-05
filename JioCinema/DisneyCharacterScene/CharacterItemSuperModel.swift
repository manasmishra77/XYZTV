//
//  CharacterItemSuperModel.swift
//  JioCinema
//
//  Created by Shweta Adagale on 21/02/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

struct CharacterItemSuperModel: Codable {
    var code: Int?
    var message: String?
    var id: String?
    var name: String?
    var image: String?
    var data: [DisneyCharacterItems]?
    
    enum CodingKeys: String, CodingKey {
        
        case code
        case message
        case id
        case name
        case image
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        do {
            let itemIdNum = try values.decodeIfPresent(Int.self, forKey: .id)
            id = "\(itemIdNum ?? -1)"
        } catch {
            let itemIdString = try values.decodeIfPresent(String.self, forKey: .id)
            id = itemIdString
        }
        name = try values.decodeIfPresent(String.self, forKey: .name)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        data = try values.decodeIfPresent([DisneyCharacterItems].self, forKey: .data)
    }
    
}
