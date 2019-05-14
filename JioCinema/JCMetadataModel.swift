//
//  JCMetadataModel.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 09/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import Foundation
struct MetadataModel: Codable {
    var appkey:String?
    var type:Int?
    var contentId:String?
    var showdate:String?
    var isTrailerAvailable:Bool?
    var trailerId:String?
    var releasedDate:String?
    var createdDate:String?
    var version:Int?
    var isDRM:Bool?
    var videoId:String?
    var folder1:Int?
    var folder2:Int?
    var imageId:String?
    var videoExt:String?
    var imageExt:String?
    var flavorParamsId:String?
    var tags:String?
    var singer:[String]?
    var categories:String?
    var category:String?
    var label:[String]?
    var views:Int?
    var validTo:String?
    var validFrom:String?
    var isSTB:Bool?
    var productionHouse:String?
    var approved:Bool?
    var isHD:Bool?
    var isLegal:Bool?
    var isSeason:Bool?
    var updatedAt:String?
    var censorCertificate:String?
    var id:String?
    var intCensorCertificate:Int?
    var costStructure:String?
    var vendor:String?
    var albumname:String?
    var awards:String?
    var writer:String?
    var isEncrypt:Bool?
    var newmpd:Int?
    var AESkey:String?
    var musicDirector:[String]?
    var latestEpisodeId:String?
    var lyricist:[String]?
    var publisher:String?
    var name:String?
    var subtitle:String?
    var resumeSubtitle:String?
    var listSubtitle:String?
    var year:Int?
    var artist:[String]?
    var genres:[String]?
    var artistObj:[ArtistObj]?
    var directors:[String]?
    var description:String?
    var descriptionForTVShow: String?
    var rating:String?
    var review:[String]?
    var image:String?
    var banner:String?
    var format:Int?
    var language:String?
    var totalDuration:Int?
    var recomTime:Int?
    var isDownloadable:Bool?
    var thumb:String?
    var srt:String?
    var dateUploaded:String?
    var dateTranscoded:String?
    //var dateTranscoded:Int?
    var bitrate:String?
    var threshold:Int?
    var app:App?
    var categoryName:[String]?
    var categoryId:[Int]?
    var tinyUrl:String?
    var download:Bool?
    var primaryGenres:[String]?
    var recTags:String?
    var fpsKey:String?
    var fpsIv:String?
    var catData:[CategoryData]?
    var newSubtitle:String?
    var flavorCount:Int?
    var oldFolder1:Int?
    var oldFolder2:Int?
    var isMoved:Bool?
    var meta: Meta?
    var code:Int?
    var displayText:String?
    var more:[Item]?
    var episodes:[Episode]?
    var inQueue:Bool?
    var filter:[Filter]?
    var maturityRating: String?
    var subtitles: String?
    
    var maturityAgeGrp: AgeGroup {
        if let value = self.maturityRating {
            return AgeGroup(rawValue: value) ?? .allAge
        }
        return .allAge
    }
    
    var multipleAudio: String?
    
    enum CodingKeys: String, CodingKey {
        case appkey = "appkey"
        case type = "type"
        case contentId = "contentId"
        case showdate = "showdate"
        case isTrailerAvailable = "isTrailerAvailable"
        case trailerId = "trailerId"
        case releasedDate = "releasedDate"
        case createdDate = "createdDate"
        case version = "version"
        case isDRM = "isDRM"
        case videoId = "videoId"
        case folder1 = "folder1"
        case folder2 = "folder2"
        case imageId = "imageId"
        case videoExt = "videoExt"
        case imageExt = "imageExt"
        case flavorParamsId = "flavorParamsId"
        case tags = "tags"
        case singer = "singer"
        case categories = "categories"
        case category = "category"
        case label = "label"
        case views = "views"
        case validTo = "validTo"
        case validFrom = "validFrom"
        case isSTB = "isSTB"
        case productionHouse = "productionHouse"
        case approved = "approved"
        case isHD = "isHD"
        case isLegal = "isLegal"
        case isSeason = "isSeason"
        case updatedAt = "updatedAt"
        case censorCertificate = "censorCertificate"
        case id = "id"
        case intCensorCertificate = "intCensorCertificate"
        case costStructure = "costStructure"
        case vendor = "vendor"
        case albumname = "albumname"
        case awards = "awards"
        case writer = "writer"
        case isEncrypt = "isEncrypt"
        case newmpd = "newmpd"
        case AESkey = "AESkey"
        case musicDirector = "musicDirector"
        case latestEpisodeId = "latestEpisodeId"
        case lyricist = "lyricist"
        case publisher = "publisher"
        case name = "name"
        case subtitle = "subtitle"
        case resumeSubtitle = "resumeSubtitle"
        case listSubtitle = "listSubtitle"
        case year = "year"
        case artist = "artist"
        case genres = "genres"
        case artistObj = "artistObj"
        case directors = "directors"
        case description = "description"
        case descriptionForTVShow = "desc"
        case rating = "rating"
        case review = "review"
        //case totalDurationString = "totalDurationString"
        case image = "image"
        case banner = "banner"
        case format = "format"
        case language = "language"
        case totalDuration = "totalDuration"
        case recomTime = "recomTime"
        case isDownloadable = "isDownloadable"
        case thumb = "thumb"
        case srt = "srt"
        case dateUploaded = "dateUploaded"
        case dateTranscoded = "dateTranscoded"
        //case dateTranscoded = "dateTranscoded"
        case bitrate = "bitrate"
        case threshold = "threshold"
        case app = "app"
        case categoryName = "categoryName"
        case categoryId = "categoryId"
        case tinyUrl = "tinyUrl"
        case download = "download"
        case primaryGenres = "primaryGenres"
        case recTags = "recTags"
        case fpsKey = "fpsKey"
        case fpsIv = "fpsIv"
        case catData = "catData"
        case newSubtitle = "newSubtitle"
        case flavorCount = "flavorCount"
        case oldFolder1 = "oldFolder1"
        case oldFolder2 = "oldFolder2"
        case isMoved = "isMoved"
        case meta = "meta"
        case code = "code"
        case displayText = "displayText"
        case more = "more"
        case episodes = "episodes"
        case inQueue = "inQueue"
        case filter = "filter"
        case maturityRating = "maturityRating"
        case multipleAudio = "audios"
        case subtitles
    }
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            appkey = try values.decodeIfPresent(String.self, forKey: .appkey)
            type = try values.decodeIfPresent(Int.self, forKey: .type)
            do {
                let stringValue = try values.decodeIfPresent(String.self, forKey: .contentId)
                self.contentId = stringValue
            } catch {
                let intValue = try values.decodeIfPresent(Int.self, forKey: .contentId)
                self.contentId  = "\(intValue ?? -1)"
            }
            showdate = try values.decodeIfPresent(String.self, forKey: .showdate)
            isTrailerAvailable = try values.decodeIfPresent(Bool.self, forKey: .isTrailerAvailable)
            trailerId = try values.decodeIfPresent(String.self, forKey: .trailerId)
            releasedDate = try values.decodeIfPresent(String.self, forKey: .releasedDate)
            createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
            do{
            version = try values.decodeIfPresent(Int.self, forKey: .version)
            } catch {
                do {
                    if let newVersion = try values.decodeIfPresent(String.self, forKey: .version){
                    version = Int(newVersion)
                    }
                    
                } catch {
                    print(error)
                }
            }
            isDRM = try values.decodeIfPresent(Bool.self, forKey: .isDRM)
            do {
                let stringValue = try values.decodeIfPresent(String.self, forKey: .videoId)
                self.videoId = stringValue
            } catch {
                let intValue = try values.decodeIfPresent(Int.self, forKey: .videoId)
                self.videoId  = "\(intValue ?? -1)"
            }
            do {
            folder1 = try values.decodeIfPresent(Int.self, forKey: .folder1)
            } catch {
                do {
                    if let folder1String = try values.decodeIfPresent(String.self, forKey: .folder1) {
                        folder1 = Int(folder1String)
                    }
                } catch {
                    print(error)
                }
            }
            //folder2 = try values.decodeIfPresent(Int.self, forKey: .folder2)
            do {
                folder2 = try values.decodeIfPresent(Int.self, forKey: .folder2)
            } catch {
                do {
                    if let folder2String = try values.decodeIfPresent(String.self, forKey: .folder2) {
                        folder2 = Int(folder2String)
                    }
                } catch {
                    print(error)
                }
            }
            imageId = try values.decodeIfPresent(String.self, forKey: .imageId)
            videoExt = try values.decodeIfPresent(String.self, forKey: .videoExt)
            imageExt = try values.decodeIfPresent(String.self, forKey: .imageExt)
            flavorParamsId = try values.decodeIfPresent(String.self, forKey: .flavorParamsId)
            do {
                let stringValue = try values.decodeIfPresent(String.self, forKey: .tags)
                self.tags = stringValue
            } catch {
                do {
                    let intValue = try values.decodeIfPresent(Int.self, forKey: .tags)
                    self.tags  = "\(intValue ?? -1)"
                } catch {
                   //print("Error in tag \(error)")
                }
            }
            singer = try values.decodeIfPresent([String].self, forKey: .singer)
            categories = try values.decodeIfPresent(String.self, forKey: .categories)
            category = try values.decodeIfPresent(String.self, forKey: .category)
            do {
                label = try values.decodeIfPresent([String].self, forKey: .label)
            } catch{
                do {
                    if let labelString = try values.decodeIfPresent(String.self, forKey: .label) {
                    label?.append(labelString)
                    }
                } catch {
                    print(error)
                }
            }
            views = try values.decodeIfPresent(Int.self, forKey: .views)
            validTo = try values.decodeIfPresent(String.self, forKey: .validTo)
            validFrom = try values.decodeIfPresent(String.self, forKey: .validFrom)
            do {
            isSTB = try values.decodeIfPresent(Bool.self, forKey: .isSTB)
            } catch {
                do {
                    let isSTBString = try values.decodeIfPresent(String.self, forKey: .isSTB)
                    if isSTBString == "yes" {
                        isSTB = true
                    } else {
                        isSTB = false
                    }
                } catch {
                    print(error)
                }
            }
            productionHouse = try values.decodeIfPresent(String.self, forKey: .productionHouse)
            do {
                approved = try values.decodeIfPresent(Bool.self, forKey: .approved)
            } catch  {
                do {
                    let approvedString = try values.decodeIfPresent(String.self, forKey: .approved)
                    if approvedString == "yes" {
                        approved = true
                    } else if approvedString == "no" {
                        approved = false
                    }
                } catch {
                 //approved = false
                    print(error)
                }
            }
            do {
            isHD = try values.decodeIfPresent(Bool.self, forKey: .isHD)
            } catch {
                isHD = false
            }
            do {
            isLegal = try values.decodeIfPresent(Bool.self, forKey: .isLegal)
            } catch{
                let isLegalString = try values.decodeIfPresent(String.self, forKey: .isLegal)
                if isLegalString == "Y" {
                    isLegal = true
                } else {
                    isLegal = false
                }
            }
            isSeason = try values.decodeIfPresent(Bool.self, forKey: .isSeason)
            updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
            censorCertificate = try values.decodeIfPresent(String.self, forKey: .censorCertificate)
            do {
                let stringValue = try values.decodeIfPresent(String.self, forKey: .id)
                self.id = stringValue
            } catch {
                let intValue = try values.decodeIfPresent(Int.self, forKey: .id)
                self.id = "\(intValue ?? -1)"
            }
            do {
                let stringValue = try values.decodeIfPresent(Int.self, forKey: .intCensorCertificate)
                self.intCensorCertificate = stringValue
            } catch {
                let intValue = try values.decodeIfPresent(String.self, forKey: .intCensorCertificate)
                self.intCensorCertificate = Int(intValue ?? "0")
            }
            costStructure = try values.decodeIfPresent(String.self, forKey: .costStructure)
            vendor = try values.decodeIfPresent(String.self, forKey: .vendor)
            albumname = try values.decodeIfPresent(String.self, forKey: .albumname)
            awards = try values.decodeIfPresent(String.self, forKey: .awards)
            do {
            writer = try values.decodeIfPresent(String.self, forKey: .writer)
            }
            catch {
               // print(error)
                do {
                    if let writerArray = try values.decodeIfPresent([String].self, forKey: .writer) {
                        writer = writerArray.joined(separator: " ")
                        }
                    } catch {
                        //mprint(error)
                    }
            }
            do {
            isEncrypt = try values.decodeIfPresent(Bool.self, forKey: .isEncrypt)
            }
            catch {
                isEncrypt = true
            }

            newmpd = try values.decodeIfPresent(Int.self, forKey: .newmpd)
            AESkey = try values.decodeIfPresent(String.self, forKey: .AESkey)
            do {
                musicDirector = try values.decodeIfPresent([String].self, forKey: .musicDirector)
            } catch {
                do {
                    if let musicDiretorString = try values.decodeIfPresent(String.self, forKey: .musicDirector) {
                    musicDirector?.append(musicDiretorString)
                    }
                } catch {
                    print(error)
                }
            }
            latestEpisodeId = try values.decodeIfPresent(String.self, forKey: .latestEpisodeId)
            lyricist = try values.decodeIfPresent([String].self, forKey: .lyricist)
            do {
                publisher = try values.decodeIfPresent(String.self, forKey: .publisher)
            } catch {
                //print(error)
            }
            name = try values.decodeIfPresent(String.self, forKey: .name)
            subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
            resumeSubtitle = try values.decodeIfPresent(String.self, forKey: .resumeSubtitle)
            listSubtitle = try values.decodeIfPresent(String.self, forKey: .listSubtitle)
            //year = try values.decodeIfPresent(Int.self, forKey: .year)
            do {
                year = try values.decodeIfPresent(Int.self, forKey: .year)
            }   catch {
                do{
                    if let yearString = try values.decodeIfPresent(String.self, forKey: .year){
                        year = Int(yearString)
                    }
                } catch {
                    print(error)
                }
            }
            artist = try values.decodeIfPresent([String].self, forKey: .artist)
            do{
            totalDuration = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
            } catch {
                do {
                    if let totalDurationString = try values.decodeIfPresent(String.self, forKey: .totalDuration) {
                    totalDuration = Int(totalDurationString)
                    }
                } catch {
                    print(error)
                }
            }
            srt = try values.decodeIfPresent(String.self, forKey: .srt)
            genres = try values.decodeIfPresent([String].self, forKey: .genres)
            artistObj = try values.decodeIfPresent([ArtistObj].self, forKey: .artistObj)
            directors = try values.decodeIfPresent([String].self, forKey: .directors)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            descriptionForTVShow = try values.decodeIfPresent(String.self, forKey: .descriptionForTVShow)
            rating = try values.decodeIfPresent(String.self, forKey: .rating)
            review = try values.decodeIfPresent([String].self, forKey: .review)
            image = try values.decodeIfPresent(String.self, forKey: .image)
            banner = try values.decodeIfPresent(String.self, forKey: .banner)
            format = try values.decodeIfPresent(Int.self, forKey: .format)
            language = try values.decodeIfPresent(String.self, forKey: .language)
            do {
            totalDuration = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
            } catch {
                do {
                    if let stringTotalDuration = try values.decodeIfPresent(String.self, forKey: .totalDuration){
                        totalDuration = Int(stringTotalDuration) }
                } catch {
                    print(error)
                }
            }
            do {
            recomTime = try values.decodeIfPresent(Int.self, forKey: .recomTime)
            } catch {
                do {
                    if let stringRecomTime = try values.decodeIfPresent(String.self, forKey: .recomTime){
                    recomTime = Int(stringRecomTime)
                    }
                } catch {
                    print(error)
                }
            }
            do {
            isDownloadable = try values.decodeIfPresent(Bool.self, forKey: .isDownloadable)
            } catch {
                do {
                    let isDownloadableString = try values.decodeIfPresent(String.self, forKey: .isDownloadable)
                    if isDownloadableString == "yes" {
                        isDownloadable = true
                    } else {
                        isDownloadable = false
                    }
                } catch {
                    print(error)
                }
            }
            thumb = try values.decodeIfPresent(String.self, forKey: .thumb)
            srt = try values.decodeIfPresent(String.self, forKey: .srt)
            dateUploaded = try values.decodeIfPresent(String.self, forKey: .dateUploaded)
            do {
                let stringValue = try values.decodeIfPresent(String.self, forKey: .dateTranscoded)
                self.dateTranscoded = stringValue
            } catch {
                let intValue = try values.decodeIfPresent(Int.self, forKey: .dateTranscoded)
                self.dateTranscoded = "\(intValue ?? -1)"
            }
            //dateTranscoded = try values.decodeIfPresent(Int.self, forKey: .dateTranscoded)
            bitrate = try values.decodeIfPresent(String.self, forKey: .bitrate)
            threshold = try values.decodeIfPresent(Int.self, forKey: .threshold)
            app = try values.decodeIfPresent(App.self, forKey: .app)
            categoryName = try values.decodeIfPresent([String].self, forKey: .categoryName)
            do {
                categoryId = try values.decodeIfPresent([Int].self, forKey: .categoryId)
            } catch {
                do {
                    if let categoryIdString = try values.decodeIfPresent([String].self, forKey: .categoryId) {
                        for item in categoryIdString{
                            if let intItem = Int(item) {
                            categoryId?.append(intItem)
                            }
                        }
                    }
                } catch {
                    //print(error)
                }
                
            }
            tinyUrl = try values.decodeIfPresent(String.self, forKey: .tinyUrl)
            do {
                download = try values.decodeIfPresent(Bool.self, forKey: .download)
            } catch {
                download = nil
            }
            do {
                primaryGenres = try values.decodeIfPresent([String].self, forKey: .primaryGenres)
            } catch {
                do {
                    let primaryGenresString = try values.decodeIfPresent(String.self, forKey: .primaryGenres)
                    primaryGenres?.append(primaryGenresString ?? "")
                } catch {
                    print(error)
                }
            }
            recTags = try values.decodeIfPresent(String.self, forKey: .recTags)
            fpsKey = try values.decodeIfPresent(String.self, forKey: .fpsKey)
            fpsIv = try values.decodeIfPresent(String.self, forKey: .fpsIv)
            catData = try values.decodeIfPresent([CategoryData].self, forKey: .catData)
            newSubtitle = try values.decodeIfPresent(String.self, forKey: .newSubtitle)
            flavorCount = try values.decodeIfPresent(Int.self, forKey: .flavorCount)
            do {
            oldFolder1 = try values.decodeIfPresent(Int.self, forKey: .oldFolder1)
            } catch {
                do {
                if let oldFolder1String = try values.decodeIfPresent(String.self, forKey: .oldFolder1)
                {
                oldFolder1 = Int(oldFolder1String)
                }
                } catch {
                    print(error)
                }
            }
            do {
            oldFolder2 = try values.decodeIfPresent(Int.self, forKey: .oldFolder2)
            } catch {
                //print(error)
            }
            do {
            isMoved = try values.decodeIfPresent(Bool.self, forKey: .isMoved)
            } catch {
                //print(error)
            }
            meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
            code = try values.decodeIfPresent(Int.self, forKey: .code)
            displayText = try values.decodeIfPresent(String.self, forKey: .displayText)
            do {
                more = try values.decodeIfPresent([Item].self, forKey: .more)
            } catch {
                print(error)
            }
            do {
            episodes = try values.decodeIfPresent([Episode].self, forKey: .episodes)
            } catch {
                print(error)
            }
            inQueue = try values.decodeIfPresent(Bool.self, forKey: .inQueue)
            filter = try values.decodeIfPresent([Filter].self, forKey: .filter)
            maturityRating = try values.decodeIfPresent(String.self, forKey: .maturityRating)
            multipleAudio = try values.decodeIfPresent(String.self, forKey: .multipleAudio)
            subtitles = try values.decodeIfPresent(String.self, forKey: .subtitles)
        } catch {
            print(error)
        }
        
    }
}

struct ArtistObj: Codable {
    var first:String?
    var last:String?
    enum CodingKeys: String, CodingKey {
        case first = "first"
        case last = "last"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        first = try values.decodeIfPresent(String.self, forKey: .first)
        last = try values.decodeIfPresent(String.self, forKey: .last)
    }
}

struct CategoryData: Codable {
    var id:Int?
    var name:String?
    var order:Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case order = "order"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try values.decodeIfPresent(Int.self, forKey: .id)
        } catch {
            do {
                if let idString = try values.decodeIfPresent(String.self, forKey: .id){
                    self.id = Int(idString)
                }
            } catch {
                print(error)
            }
        }
        name = try values.decodeIfPresent(String.self, forKey: .name)
        order = try values.decode(Int.self, forKey: .order)
    }
}

struct Meta: Codable {
    var revision:Int?
    var created:String?
    var version:Int?
    var updated:String?
    
    enum CodingKeys: String, CodingKey {
        case revision = "revision"
        case created = "created"
        case version = "version"
        case updated = "updated"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        revision = try values.decodeIfPresent(Int.self, forKey: .revision)
        do {
            created = try values.decodeIfPresent(String.self, forKey: .created)
        } catch {
            do {
                if let createdInt = try values.decodeIfPresent(Int.self, forKey: .created ) {
                created = String(createdInt)
                }
            } catch {
                print(error)
            }
        }
        
        //version = try values.decodeIfPresent(Int.self, forKey: .version)
        do{
            version = try values.decodeIfPresent(Int.self, forKey: .version)
        } catch {
            do {
                if let newVersion = try values.decodeIfPresent(String.self, forKey: .version){
                    version = Int(newVersion)
                }
                
            } catch {
                print(error)
            }
        }
        do {
        updated = try values.decodeIfPresent(String.self, forKey: .updated)
        } catch {
            do{
                if let newUpdated = try values.decodeIfPresent(Int.self, forKey: .updated) {
                updated = String(newUpdated)
                }
            } catch {
                print(error)
            }
        }
    }
}

struct More: Codable {
    var id:String?
    var name:String?
    var subtitle:String?
    var banner:String?
    var format:Int?
    var language:String?
    var app:App?
    var rating:Double? //
    var description:String?
    var year:Int? //
    var genres:[String]? //
    var totalDuration:Int?
    var srt:String? //
    var totalDurationString:String?
    var image:String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case subtitle = "subtitle"
        case banner = "banner"
        case format = "format"
        case language = "language"
        case app = "app"
        case rating = "rating"
        case description = "description"
        case year = "year"
        case genres = "genres"
        case totalDuration = "totalDuration"
        case srt = "srt"
        case totalDurationString = "totalDurationString"
        case image = "image"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let stringValue = try values.decodeIfPresent(String.self, forKey: .id)
            self.id = stringValue
        } catch {
            let intValue = try values.decodeIfPresent(Int.self, forKey: .id)
            self.id = "\(intValue ?? -1)"
        }
        name = try values.decodeIfPresent(String.self, forKey: .name)
        subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
        banner = try values.decodeIfPresent(String.self, forKey: .banner)
        format = try values.decodeIfPresent(Int.self, forKey: .format)
        language = try values.decodeIfPresent(String.self, forKey: .language)
        app = try values.decodeIfPresent(App.self, forKey: .app)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        do {
            year = try values.decodeIfPresent(Int.self, forKey: .year)
        } catch {
            do{
                if let yearString = try values.decodeIfPresent(String.self, forKey: .year){
                year = Int(yearString)
                }
            } catch {
                print(error)
            }
        }
        genres = try values.decodeIfPresent([String].self, forKey: .genres)
        totalDuration = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
        srt = try values.decodeIfPresent(String.self, forKey: .srt)
        totalDurationString = try values.decodeIfPresent(String.self, forKey: .totalDurationString)
        image = try values.decodeIfPresent(String.self, forKey: .image)
    }
}

struct Episode: Codable {
    var id:String?
    var name:String?
    var image:String?
    var banner:String?
    var showdate:String?
    var subtitle:String?
    var duration:Int?
    var totalDuration:Int?
    var epochShowDate:String?
    var episodeNo:Int?
    var legal:Bool?
    var approved:Bool?
    
    //Converting Episode to Item
    var getItem: Item {
        var item = Item()
        item.id = self.id
        item.banner = self.banner
        item.image = image
        item.subtitle = subtitle
        var appType: App = App()
        appType.type = VideoType.Episode.rawValue
        item.app = appType
        return item
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case image = "image"
        case banner = "banner"
        case showdate = "showdate"
        case subtitle = "subtitle"
        case duration = "duration"
        case totalDuration = "totalDuration"
        case epochShowDate = "epochShowDate"
        case episodeNo = "episodeNo"
        case legal = "legal"
        case approved = "approved"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        banner = try values.decodeIfPresent(String.self, forKey: .banner)
        showdate = try values.decodeIfPresent(String.self, forKey: .showdate)
        subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
        duration = try values.decodeIfPresent(Int.self, forKey: .duration)
        totalDuration = try values.decodeIfPresent(Int.self, forKey: .totalDuration)
        do {
        epochShowDate = try values.decodeIfPresent(String.self, forKey: .epochShowDate)
        } catch {
            do{
                if let epochShowDateInt = try values.decodeIfPresent(Int.self, forKey: .epochShowDate) {
                epochShowDate = String(epochShowDateInt)
                }
            } catch {
                print(error)
            }
        }
        do {
            episodeNo = try values.decodeIfPresent(Int.self, forKey: .episodeNo)
        } catch {
            do {
                if let episodeNoString = try values.decodeIfPresent(String.self, forKey: .episodeNo){
                    self.episodeNo = Int(episodeNoString)
                }
            } catch {
                print(error)
            }
        }
        do {
        legal = try values.decodeIfPresent(Bool.self, forKey: .legal)
        } catch {
            do {
                let legalString = try values.decodeIfPresent(String.self, forKey: .legal)
                if legalString == "Y"{
                    legal = true
                } else {
                    legal = false
                }
            } catch {
                print(error)
            }
        }
//        approved = try values.decodeIfPresent(Bool.self, forKey: .approved)
        do {
            approved = try values.decodeIfPresent(Bool.self, forKey: .approved)
        } catch {
            do {
                let approvedString = try values.decodeIfPresent(String.self, forKey: .approved)
                if approvedString == "yes" {
                    approved = true
                } else if approvedString == "no" {
                    approved = false
                }
            } catch {
                //approved = false
                //print(error)
            }
            //print(error)
        }

    }
}

struct Filter: Codable {
    var filter: String?
    var season:Int?
    var month:[String]?
    
    enum CodingKeys: String, CodingKey {
        case filter = "filter"
        case season = "season"
        case month = "month"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        filter = try values.decodeIfPresent(String.self, forKey: .filter)
        season = try values.decodeIfPresent(Int.self, forKey: .season)
        month = try values.decode([String].self, forKey: .month)
    }
}


/*
class MetadataModel:Mappable
{
    var appkey:String?
    var type:Int?
    var contentId:String?
    var showdate:String?
    var isTrailerAvailable:Bool?
    var trailerId:String?
    var releasedDate:String?
    var createdDate:String?
    var version:Int?
    var isDRM:Bool?
    var videoId:String?
    var folder1:Int?
    var folder2:Int?
    var imageId:String?
    var videoExt:String?
    var imageExt:String?
    var flavorParamsId:String?
    var tags:String?
    var singer:[String]?
    var categories:String?
    var category:String?
    var label:[String]?
    var views:Int?
    var validTo:String?
    var validFrom:String?
    var isSTB:Bool?
    var productionHouse:String?
    var approved:Bool?
    var isHD:Bool?
    var isLegal:Bool?
    var isSeason:Bool?
    var updatedAt:String?
    var censorCertificate:String?
    var id:String?
    var intCensorCertificate:Int?
    var costStructure:String?
    var vendor:String?
    var albumname:String?
    var awards:String?
    var writer:String?
    var isEncrypt:Bool?
    var newmpd:Int?
    var AESkey:String?
    var musicDirector:[String]?
    var latestEpisodeId:String?
    var lyricist:[String]?
    var publisher:String?
    var name:String?
    var subtitle:String?
    var resumeSubtitle:String?
    var listSubtitle:String?
    var year:Int?
    var artist:[String]?
    var genres:[String]?
    var artistObj:[ArtistObj]?
    var directors:[String]?
    var description:String?
    var descriptionForTVShow: String?
    var rating:String?
    var review:[String]?
    var image:String?
    var banner:String?
    var format:Int?
    var language:String?
    var totalDuration:Int?
    var recomTime:Int?
    var isDownloadable:Bool?
    var thumb:String?
    var srt:String?
    var dateUploaded:String?
    var dateTranscoded:String?
    var status:Int?
    var bitrate:String?
    var threshold:Int?
    var app:App?
    var categoryName:[String]?
    var categoryId:[Int]?
    var tinyUrl:String?
    var download:Bool?
    var primaryGenres:[String]?
    var recTags:String?
    var fpsKey:String?
    var fpsIv:String?
    var catData:[CategoryData]?
    var newSubtitle:String?
    var flavorCount:Int?
    var oldFolder1:Int?
    var oldFolder2:Int?
    var isMoved:Bool?
    var meta:Meta?
    var code:Int?
    var displayText:String?
    var more:[More]?
    var multipleAudio : String?
    var episodes:[Episode]?
    var inQueue:Bool?
    var filter:[Filter]?
    var maturityRating: String?
    
    var maturityAgeGrp: AgeGroup {
        if let value = self.maturityRating {
            return AgeGroup(rawValue: value) ?? .allAge
        }
        return .allAge
    }
    

    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        appkey <- map["appkey"]
        type <- map["type"]
        
        var tmpStore: Double?
        tmpStore <- map["contentId"]
        
        contentId <- map["contentId"]
        
        if contentId == nil, tmpStore != nil {
            contentId = "\(String(describing: Int(tmpStore!)))"
        }
        
        //contentId <- map["contentId"]
        showdate <- map["showdate"]
        isTrailerAvailable <- map["isTrailerAvailable"]
        trailerId <- map["trailerId"]
        releasedDate <- map["releasedDate"]
        createdDate <- map["createdDate"]
        version <- map["version"]
        isDRM <- map["isDRM"]
        videoId <- map["videoId"]
        folder1 <- map["folder1"]
        folder2 <- map["folder2"]
        imageId <- map["imageId"]
        videoExt <- map["videoExt"]
        imageExt <- map["imageExt"]
        flavorParamsId <- map["flavorParamsId"]
        tags <- map["tags"]
        singer <- map["singer"]
        categories <- map["categories"]
        category <- map["category"]
        label <- map["label"]
        views <- map["views"]
        validTo <- map["validTo"]
        validFrom <- map["validFrom"]
        isSTB <- map["isSTB"]
        productionHouse <- map["productionHouse"]
        approved <- map["approved"]
        isHD <- map["isHD"]
        isLegal <- map["isLegal"]
        updatedAt <- map["updatedAt"]
        censorCertificate <- map["censorCertificate"]
        
        var tempStore: Double?
        tempStore <- map["id"]
        
        id <- map["id"]
        
        if id == nil, tempStore != nil {
            id = "\(String(describing: Int(tempStore!)))"
        }
        
        intCensorCertificate <- map["intCensorCertificate"]
        costStructure <- map["costStructure"]
        vendor <- map["vendor"]
        albumname <- map["albumname"]
        awards <- map["awards"]
        writer <- map["writer"]
        isEncrypt <- map["isEncrypt"]
        newmpd <- map["newmpd"]
        AESkey <- map["AESkey"]
        musicDirector <- map["musicDirector"]
        latestEpisodeId <- map["latestEpisodeId"]
        lyricist <- map["lyricist"]
        publisher <- map["publisher"]
        name <- map["name"]
        subtitle <- map["subtitle"]
        resumeSubtitle <- map["resumeSubtitle"]
        listSubtitle <- map["listSubtitle"]
        year <- map["year"]
        artist <- map["artist"]
        genres <- map["genres"]
        artistObj <- map["artistObj"]
        directors <- map["directors"]
        description <- map["description"]
        descriptionForTVShow <- map["desc"]
        
        rating <- map["rating"]
        review <- map["review"]
        image <- map["image"]
        banner <- map["banner"]
        format <- map["format"]
        language <- map["language"]
        totalDuration <- map["totalDuration"]
        recomTime <- map["recomTime"]
        isDownloadable <- map["isDownloadable"]
        thumb <- map["thumb"]
        srt <- map["srt"]
        dateUploaded <- map["dateUploaded"]
        dateTranscoded <- map["dateTranscoded"]
        status <- map["status"]
        bitrate <- map["bitrate"]
        threshold <- map["threshold"]
        app <- map["app"]
        categoryName <- map["categoryName"]
        categoryId <- map["categoryId"]
        tinyUrl <- map["tinyUrl"]
        download <- map["download"]
        primaryGenres <- map["primaryGenres"]
        recTags <- map["recTags"]
        fpsKey <- map["fpsKey"]
        fpsIv <- map["fpsIv"]
        catData <- map["catData"]
        newSubtitle <- map["newSubtitle"]
        flavorCount <- map["flavorCount"]
        oldFolder1 <- map["oldFolder1"]
        oldFolder2 <- map["oldFolder2"]
        isMoved <- map["isMoved"]
        meta <- map["meta"]
        code <- map["code"]
        displayText <- map["displayText"]
        more <- map["more"]
        multipleAudio <- map["audios"]
        
        episodes <- map["episodes"]
        inQueue <- map["inQueue"]
        isSeason <- map["isSeason"]
        filter <- map["filter"]
        maturityRating <- map["maturityRating"]
        
        
    }
}

class ArtistObj:Mappable
{
    var first:String?
    var last:String?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        first <- map["first"]
        last <- map["last"]
    }
}

class CategoryData:Mappable
{
    var id:Int?
    var name:String?
    var order:Int?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        id <- map["id"]
        name <- map["name"]
        order <- map["order"]
    }
}

class Meta:Mappable
{
    var revision:Int?
    var created:String?
    var version:Int?
    var updated:String?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        revision <- map["revision"]
        created <- map["created"]
        version <- map["version"]
        updated <- map["version"]
    }
}

class More: Mappable
{
    var id:String?
    var name:String?
    var subtitle:String?
    var banner:String?
    var format:Int?
    var language:String?
    var app:App?
    var rating:Double?
    var description:String?
    var year:Int?
    var genres:[String]?
    var totalDuration:Int?
    var srt:String?
    var totalDurationString:String?
    var image:String?
    
    init() {
        
    }
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        var tempStore: Double?
        tempStore <- map["id"]
        
        id <- map["id"]
        
        if id == nil, tempStore != nil {
            id = "\(String(describing: Int(tempStore!)))"
        }
        
        name <- map["name"]
        subtitle <- map["subtitle"]
        banner <- map["banner"]
        format <- map["format"]
        language <- map["language"]
        app <- map["app"]
        rating <- map["rating"]
        description <- map["description"]
        year <- map["year"]
        genres <- map["genres"]
        
       
        totalDuration <- map["totalDuration"]
        srt <- map["srt"]
        totalDurationString <- map["totalDurationString"]
        image <- map["image"]
    }
}

class Episode:Mappable
{
    var id:String?
    var name:String?
    var image:String?
    var banner:String?
    var showdate:String?
    var subtitle:String?
    var duration:Int?
    var totalDuration:Int?
    var epochShowDate:String?
    var episodeNo:Int?
    var legal:Bool?
    var approved:Bool?
    
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        id <- map["id"]
        name <- map["name"]
        subtitle <- map["subtitle"]
        banner <- map["banner"]
        showdate <- map["showdate"]
        epochShowDate <- map["epochShowDate"]
        episodeNo <- map["episodeNo"]
        legal <- map["legal"]
        approved <- map["approved"]
        totalDuration <- map["totalDuration"]
        image <- map["image"]
        duration <- map["duration"]
    }
}

class Filter:Mappable
{
    var filter:String?
    var season:Int?
    var month:[String]?
    
    required init(map:Map) {
        
    }
    
    func mapping(map:Map)
    {
        filter <- map["filter"]
        season <- map["season"]
        month <- map["month"]
    }
}
*/

