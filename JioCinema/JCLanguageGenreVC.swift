//
//  JCLanguageGenreVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 31/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCLanguageGenreVC: UIViewController {

    enum VideoType:Int
    {
        case Movie = 0
        case Music = 2
        case TVShow = 1
        case Clip = 6
        case Trailer = 3
        case Language = 9
        case Genre = 10
    }
    
    var loadedPage = 0
    var item:Item?
    var languageGenreDetailModel:LanguageGenreDetailModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if item?.app?.type == VideoType.Language.rawValue
        {
            callWebServiceForLanguageGenreData(isLanguage: true, pageNo: loadedPage)
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            callWebServiceForLanguageGenreData(isLanguage: false, pageNo: loadedPage)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callWebServiceForLanguageGenreData(isLanguage:Bool,pageNo:Int)
    {
        let url = langGenreDataUrl.appending("\(pageNo)")
        var params = [String:Any]()
        if isLanguage
        {
            var langArray = [String]()
            langArray.append((item!.name)!)
            params["lang"] = langArray
            params["genres"] = ["All Genres"]
            params["type"] = 0
            params["filter"] = 3
            params["key"] = "language"
            
        }
        else
        {
            var genreArray = [String]()
            genreArray.append((item?.genre)!)
            params["lang"] = ["All Languages"]
            params["genres"] = genreArray
            params["type"] = 0
            params["filter"] = 3
            params["key"] = "genre"
        }
        let languageGenreDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        weak var weakself = self
        
        RJILApiManager.defaultManager.post(request: languageGenreDataRequest) { (data, response, error) in
            if let responseError = error
            {
                print(responseError.localizedDescription)
                return
            }
            
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    weakself?.languageGenreDetailModel = LanguageGenreDetailModel(JSONString: responseString)
                    print("blah")
                }
            }
        }

    }

}
