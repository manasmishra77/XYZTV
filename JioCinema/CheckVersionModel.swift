

import Foundation
struct CheckVersionModel: Codable {
	var messageCode : Int?
	var result : CheckVersionResult?

    enum CodingKeys: String, CodingKey {

        case messageCode = "messageCode"
        case result
    }
    

//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        messageCode = try values.decodeIfPresent(Int.self, forKey: .messageCode)
//        result = try CheckVersionResult(from: decoder)
//    }

}
