//
//  TopShelfModel.swift
//  JioCinema
//
//  Created by manas on 23/01/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
struct ResponseDict: Codable {
    var code: Int? = nil
    var message: String? = nil
    var sections: [Info]
}

struct Info: Codable {
    var title: String?
    var tiles: [VODTopShelfModel]
}

struct VODTopShelfModel: Codable{
    var title: String? = nil
    var subtitle: String? = nil
    var image_ratio: String? = nil
    var image_url: String? = nil
    var is_playable: Bool? = nil
    var action_data: String? = nil
    
    static func getModel(_ dataString: String) -> ContentModel{
        var model = ContentModel()
        if let data = dataString.data(using: .utf8){
            do{
                model = try JSONDecoder().decode(ContentModel.self, from: data)
            }catch{
                print(error)
            }
        }
        return model
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case image_ratio
        case image_url
        case action_data
        case is_playable
    }
}
struct ContentModel: Codable{
    var name: String? = nil
    var type: String? = nil
    var contentId: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case contentId = "id"
    }
    
}

