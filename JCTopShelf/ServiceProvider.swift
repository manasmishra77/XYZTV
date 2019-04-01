////
////  ServiceProvider.swift
////  JCTopShelf
////
////  Created by manas on 22/01/18.
////  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
////
//
////BasePath
//let prodBase = "https://prod.media.jio.com/apis/"
//let qaBase = "https://qa.media.jio.com/mdp_qa/apis/"
//
//let basePath = prodBase
//let topShelfItemURL = basePath.appending("common/v3/accelerator/get")
//
//import Foundation
//import TVServices
//
//class ServiceProvider: NSObject, TVTopShelfProvider {
//
//    override init() {
//        super.init()
//    }
//
//    // MARK: - TVTopShelfProvider protocol
//    var topShelfStyle: TVTopShelfContentStyle {
//        // Return desired Top Shelf style.
//        return .sectioned
//    }
//    var topShelfItems: [TVContentItem] {
//        return []
//        let topShelfIdentifier = TVContentIdentifier(identifier:
//            "Featured", container: nil)!
//        let topShelfSection = TVContentItem(contentIdentifier:
//            topShelfIdentifier)!
//        topShelfSection.title = "Featured"
//
//        var topShelfItemArray = [TVContentItem]()
//        
//        if let shelfModelArray = self.webServiceCallForTopShelfItems() {
//
//            for eachShelfModel in shelfModelArray{
//                if let tvContentIdentifier = TVContentIdentifier(identifier: eachShelfModel.title ?? "", container: nil){
//                    let topShelfItem = TVContentItem(contentIdentifier: tvContentIdentifier)
//                    topShelfItem?.imageURL = URL(string: eachShelfModel.image_url ?? "")
//                    if let displayUrl = self.urlFor(identifier: eachShelfModel.action_data ?? ""){
//                        topShelfItem?.displayURL = displayUrl
//                        topShelfItem?.imageShape = .HDTV
//                    }
//                    if let topShelfItem = topShelfItem{
//                        topShelfItemArray.append(topShelfItem)
//                    }
//                }
//            }
//        }
//        topShelfSection.topShelfItems = topShelfItemArray
//        return [topShelfSection]
//    }
//
//    private func urlFor(identifier: String) -> URL? {
//        var components = URLComponents()
//        components.scheme = "jCApp"
//        components.queryItems = [URLQueryItem(name: "identifier", value: identifier)]
//
//        return components.url
//    }
//
//    private func webServiceCallForTopShelfItems() -> [VODTopShelfModel]?{
//        let dispatchGroup = DispatchGroup()
//        var shelfModelArray: [VODTopShelfModel]? = nil
//        if let url = URL(string: topShelfItemURL){
//
//            weak var weakSelf = self
//
//            dispatchGroup.enter()
//            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//                if error != nil{
//
//                }
//                if let response = response as? HTTPURLResponse{
//                    if response.statusCode == 200, let data = data{
//                        shelfModelArray = (weakSelf?.parseResponse(data))
//                    }
//                }
//                dispatchGroup.leave()
//                return
//            }
//            task.resume()
//        }
//        dispatchGroup.wait()
//        return shelfModelArray
//    }
//
//    private func parseResponse(_ data: Data) -> [VODTopShelfModel] {
//        var shelfModelArray = [VODTopShelfModel]()
//        do{
//            let jsonDict = try JSONDecoder().decode(ResponseDict.self, from: data)
//            if let tiles = jsonDict.sections.first?.tiles{
//                shelfModelArray = tiles
//            }
//
//        }catch{
//            print(error)
//
//        }
//        return shelfModelArray
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
