//
//  RJILApiManager+Parental.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/13/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

extension RJILApiManager {
    
    func getPinFromServer(completion: @escaping (_ pin: String?) -> ()) -> () {
        let request = RJILApiManager.defaultManager.prepareRequest(path: SetParentalPinUrl, encoding: .JSON)
        RJILApiManager.defaultManager.post(request: request) { (data, response, error) in
            if error != nil {
                completion(nil)
                return
            }
            if let response = response as? HTTPURLResponse {
                guard let data = data else {return}
                switch response.statusCode {
                case 200:
                    if let responseDict = RJILApiManager.parse(data: data) as? [String: String] {
                        let uniqueCode = responseDict["uniqueCode"]
                        completion(uniqueCode)
                    }
                    
                default:
                    print("Default")
                }
            }
            completion(nil)
        }
    }
    
    func getParentalPinForContentFromServer(completion: @escaping (_ pinModel: ParentalPinModel) -> ()) -> () {
        var request = RJILApiManager.defaultManager.prepareRequest(path: GetParentalPinDetailUrl, encoding: .JSON)
        let headerDict = ["uniqueId": JCAppUser.shared.unique]
        request.allHTTPHeaderFields = headerDict
        RJILApiManager.defaultManager.post(request: request) { (data, response, error) in

            if let response = response as? HTTPURLResponse {
                guard let data = data else {return}
                switch response.statusCode {
                case 200:
                    if let pinModel = RJILApiManager.parseData(data, modelType: ParentalPinModel.self){
                        completion(pinModel)
                    }
                default:
                    print("Default")
                }
            }
            
        }
    }
    
}
