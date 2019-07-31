//
//  TopShelfModel.swift
//  JioCinema
//
//  Created by manas on 23/01/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation

let baseImageUrl = "http://jioimages.cdn.jio.com/content/entry/data/"

struct VODTopShelfModel: Codable {
    var id: String?
    var name: String?
    var showname: String?
    var subtitle: String?
    var image: String?
    var tvImage: String?
    var description: String?
    var banner: String?
    var format: Int?
    var language: String?
    var genre: String?
    var vendor: String?
    var app: App?
    var latestId:String?
    var layout:Int?
    var duration: Int?
    var isPlaylist: Bool? = false
    var playlistId: String?
    var totalDuration: Int?
    var episodeId: String?
    
    var imageUrlPortraitContent: String {
        if let imageStr = image {
            return baseImageUrl + imageStr
        } else if let imageStr = banner {
            return baseImageUrl + imageStr
        }
        return ""
    }
    
    var imageUrlLandscapContent: String {
        if let imageStr = banner {
            return baseImageUrl + imageStr
        } else if let imageStr = image {
            return baseImageUrl + imageStr
        }
        return ""
    }
    
    var imageUrlForCarousel: String {
        if let imageStr = tvImage {
            return baseImageUrl + imageStr
        } else if let imageStr = banner {
            return baseImageUrl + imageStr
        }
        return ""
    }

    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case showname = "showname"
        case subtitle = "subtitle"
        case image = "image"
        case tvImage = "tvImage"
        case description = "description"
        case banner = "banner"
        case format = "format"
        case language = "language"
        case genre = "genre"
        case vendor = "vendor"
        case app = "app"
        case latestId = "latestId"
        case layout = "layout"
        case duration = "duration"
        case isPlaylist = "isPlaylist"
        case playlistId = "playlistId"
        case totalDuration = "totalDuration"
        case episodeId = "episodeId"
    }
    init() {
        
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .id)
                self.id = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .id)
                self.id = "\(valNum ?? -1)"
            }
            name = try values.decodeIfPresent(String.self, forKey: .name)
            showname = try values.decodeIfPresent(String.self, forKey: .showname)
            subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
            image = try values.decodeIfPresent(String.self, forKey: .image)
            tvImage = try values.decodeIfPresent(String.self, forKey: .tvImage)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            banner = try values.decodeIfPresent(String.self, forKey: .banner)
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .format)
                self.format = valNum
            } catch {
                let valString = try values.decodeIfPresent(String.self, forKey: .format)
                self.format = Int(valString ?? "0")
            }
            do {
                language = try values.decodeIfPresent(String.self, forKey: .language)
            } catch {
            }
            genre = try values.decodeIfPresent(String.self, forKey: .genre)
            vendor = try values.decodeIfPresent(String.self, forKey: .vendor)
            app = try values.decodeIfPresent(App.self, forKey: .app)
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .latestId)
                self.latestId = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .latestId)
                self.latestId = "\(valNum ?? -1)"
            }
            do {
                layout = try values.decodeIfPresent(Int.self, forKey: .layout)
            } catch {
                do {
                    if let layoutString = try values.decodeIfPresent(String.self, forKey: .layout){
                        layout = Int(layoutString)
                    }
                } catch {
                }
            }
            
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .duration)
                self.duration = valNum
            } catch {
                let valString = try values.decodeIfPresent(String.self, forKey: .duration)
                self.duration = Int(valString ?? "0")
            }
            isPlaylist = try values.decodeIfPresent(Bool.self, forKey: .isPlaylist)
            
            do {
                self.playlistId = try values.decodeIfPresent(String.self, forKey: .playlistId)
            } catch {
                do {
                    let valNum = try values.decodeIfPresent(Int.self, forKey: .playlistId)
                    self.playlistId = "\(valNum ?? -1)"
                } catch {
                    print(error)
                }
            }
            do {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
                self.totalDuration = valNum
            } catch {
                let valString = try values.decodeIfPresent(String.self, forKey: .totalDuration)
                self.totalDuration = Int(valString ?? "0")
            }
            
            episodeId = try values.decodeIfPresent(String.self, forKey: .episodeId)
        } catch {
            print(error)
        }
    }
}
struct ContentModel: Codable {
    var name: String?
    var type: String? = nil
    var contentId: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case contentId = "id"
    }
    
}

struct App: Codable {
    var resolution: Int?
    var isNew: Bool?
    var type: Int?
    
    enum CodingKeys: String, CodingKey {
        case resolution = "resolution"
        case isNew = "isNew"
        case type = "type"
    }
    
    init() {
        
    }
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            resolution = try values.decodeIfPresent(Int.self, forKey: .resolution)
            isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew)
            type = try values.decodeIfPresent(Int.self, forKey: .type)
        } catch {
            print(error)
        }
    }
}

struct BaseDataModel: Codable {
    var code: Int?
    var message: String?
    var totalPages: Int?
    var data: [DataContainer]?
    
    //For Resume-watch response
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case totalPages = "totalPages"
        case data = "data"
        
        //For Resume-watch response
        case title = "title"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            code = try values.decodeIfPresent(Int.self, forKey: .code)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages)
            do {
                let containerArr = try values.decodeIfPresent([DataContainer].self, forKey: .data)
                self.data = containerArr
            } catch {
                //For recumewatchlist response
                if let container = try values.decodeIfPresent(DataContainer.self, forKey: .data) {
                    self.data = [container]
                }
            }
            //For recumewatchlist response
            title = try values.decodeIfPresent(String.self, forKey: .title)
        } catch {
            print(error)
        }
    }
}

struct DataContainer: Codable {
    var items: [VODTopShelfModel]?
    var url: String?
    var title: String?
    var seeMore: Bool?
    var order: Int?
    var isCarousal: Bool?
    var id: String?
    var position: Int?
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case url = "url"
        case title = "title"
        case seeMore = "seeMore"
        case order = "order"
        case isCarousal = "isCarousal"
        case id = "id"
        case position = "position"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            do {
                items = try values.decodeIfPresent([VODTopShelfModel].self, forKey: .items)
            } catch  {
                print(error)
            }
            
            url = try values.decodeIfPresent(String.self, forKey: .url)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            seeMore = try values.decodeIfPresent(Bool.self, forKey: .seeMore)
            do {
                isCarousal = try values.decodeIfPresent(Bool.self, forKey: .isCarousal)
            } catch {
                isCarousal = false
            }
            order = try values.decodeIfPresent(Int.self, forKey: .order)
            
            do {
                let valString = try values.decodeIfPresent(String.self, forKey: .id)
                self.id = valString
            } catch {
                let valNum = try values.decodeIfPresent(Int.self, forKey: .id)
                self.id = "\(valNum ?? -1)"
            }
            position = try values.decodeIfPresent(Int.self, forKey: .position)
        } catch  {
            print(error)
        }
        
    }
}
