

import Foundation
struct CheckVersionData {
	var version : Float?
	var url : String?
	var mandatory : Bool?
	var description : String?
	var heading : String?
    var buildNumber: Int? = nil
    
    

//    enum CodingKeys: String, CodingKey {
//
//        case version = "version"
//        case url = "url"
//        case mandatory = "mandatory"
//        case description = "description"
//        case heading = "heading"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        version = try values.decodeIfPresent(Int.self, forKey: .version)
//        url = try values.decodeIfPresent(String.self, forKey: .url)
//        mandatory = try values.decodeIfPresent(String.self, forKey: .mandatory)
//        description = try values.decodeIfPresent(String.self, forKey: .description)
//        heading = try values.decodeIfPresent(String.self, forKey: .heading)
//    }

}
