//
//  TopShelfConnectionManager.swift
//  JCTopShelf
//
//  Created by Manas Mishra on 29/07/19.
//  Copyright © 2019 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

let kAppKeyValue = "06758e99be484fca56fb"
let prodBase = "https://prod.media.jio.com/apis/"
let qaBase = "https://qa.media.jio.com/mdp_qa/apis/"

typealias ResponseSuccessBlock = (_ isSuccess: Bool, _ model: [VODTopShelfModel]?) -> Void
let basepath = prodBase


class TopShelfConnectionManager: NSObject {
    
    class func getTopShelfs(completion: ResponseSuccessBlock?) {
        let urlString = basepath + kAppKeyValue + "/v3.1/tvhome/getget/70/0"
        guard let url = URL(string: urlString) else {
            completion?(false, nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let datatask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let response = response as? HTTPURLResponse else {return}
            guard response.statusCode == 200, let data = data else {
                completion?(false, nil)
                return
            }
            if let model = try? JSONDecoder().decode(BaseDataModel.self, from: data) {
                for eachContainer in model.data ?? [] where eachContainer.isCarousal == true {
                    completion?(true, eachContainer.items)
                    break
                }
                return
            }
            completion?(false, nil)
        }
        datatask.resume()
    }

}
