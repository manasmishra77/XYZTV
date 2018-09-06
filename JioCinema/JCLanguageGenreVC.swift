//
//  JCLanguageGenreVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 31/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class JCLanguageGenreVC: UIViewController,JCLanguageGenreSelectionDelegate {
    
    enum FilterType
    {
        case VideoCategory
        case LanguageGenre
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    var loadedPage = 0
    var item:Item?
    var currentType = 0
    var currentParamString:String?
    var currentFilter:FilterType?
    var languageGenreDetailModel: LanguageGenreDetailModel?
    
    //If metadata available for metadatavc
    var metadataToBePlayedId: String?
    var metadataAppType: VideoType?
    var metadataFromScreen: String?
    var metadataCategoryName: String?
    var metadataCategoryIndex: Int?
    var metadataTabBarIndex: Int?
    var shouldUseTabBarIndex: Bool = false
    var isMetaDataAvailable: Bool = false
    var metaData: Any?

    @IBOutlet weak var noVideosAvailableLabel: UILabel!
    @IBOutlet weak var languageGenreCollectionView: UICollectionView!
    
    @IBOutlet weak var languageGenreButton: JCButton!
    @IBOutlet weak var videoCategoryButton: JCButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.languageGenreCollectionView.register(UINib.init(nibName: "JCItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier)
        
        if item?.app?.type == VideoType.Language.rawValue
        {
            currentParamString = "All Genres"
            callWebServiceForLanguageGenreData(isLanguage: true, pageNo: loadedPage,paramString: currentParamString ?? "", type: currentType)
            headerLabel.text = item?.language
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            currentParamString = "All Languages"
            callWebServiceForLanguageGenreData(isLanguage: false, pageNo: loadedPage,paramString: currentParamString ?? "", type: currentType)
            headerLabel.text = item?.genre
        }
        noVideosAvailableLabel.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        if isMetaDataAvailable {
            let metaDataVC = Utility.sharedInstance.prepareMetadata(metadataToBePlayedId ?? "", appType: metadataAppType ?? .None, fromScreen: metadataFromScreen ?? "", categoryName: metadataCategoryName ?? "", categoryIndex: metadataCategoryIndex ?? 0, tabBarIndex: metadataTabBarIndex ?? 0, shouldUseTabBarIndex: shouldUseTabBarIndex, isMetaDataAvailable: isMetaDataAvailable, metaData: metaData)
            isMetaDataAvailable = false
            self.present(metaDataVC, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("In LanguageGenre Screen Deinit")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callWebServiceForLanguageGenreData(isLanguage: Bool, pageNo: Int, paramString: String, type: Int) {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = langGenreDataUrl.appending("\(pageNo)")
        var params = [String:Any]()
        if isLanguage
        {
            var langArray = [String]()
            langArray.append((item?.name ?? ""))
            params["lang"] = langArray
            params["genres"] = [paramString]
            params["type"] = type
            params["filter"] = 0
            params["key"] = "language"
            
        }
        else
        {
            var genreArray = [String]()
            genreArray.append((item?.genre ?? ""))
            params["lang"] = [paramString]
            params["genres"] = genreArray
            params["type"] = type
            params["filter"] = 0
            params["key"] = "genre"
        }
        RJILApiManager.getReponse(path: url, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: LanguageGenreDetailModel.self) {[unowned self] (response) in
            DispatchQueue.main.async {
                self.videoCategoryButton.isEnabled = true
                self.languageGenreButton.isEnabled = true
            }
            guard response.isSuccess else {
                print(response.errorMsg ?? "")
                return
            }
            if self.loadedPage == 0
            {
                self.languageGenreDetailModel = response.model
                if self.languageGenreDetailModel?.data?.items?.count != 0 && self.languageGenreDetailModel?.data?.items?.count != nil{
                    DispatchQueue.main.async {
                        JCDataStore.sharedDataStore.languageGenreDetailModel = self.languageGenreDetailModel
                        
                        self.languageGenreButton.isEnabled = true
                        self.languageGenreCollectionView.isHidden = false
                        self.noVideosAvailableLabel.isHidden = true
                        self.prepareView()
                    }
                    
                }
                else{
                    DispatchQueue.main.async {
                        self.languageGenreButton.isEnabled = false
                        self.languageGenreCollectionView.isHidden = true
                        self.noVideosAvailableLabel.isHidden = false
                        self.prepareView()
                    }
                }
            }
            else
            {
                let tempData = response.model
                if let items = tempData?.data?.items{
                    for item in items
                    {
                        self.languageGenreDetailModel?.data?.items?.append(item)
                    }
                    DispatchQueue.main.async {
                       self.languageGenreCollectionView.reloadData()
                    }
                }
                
            }
            
        }/*
        RJILApiManager.defaultManager.post(request: languageGenreDataRequest) { (data, response, error) in
            DispatchQueue.main.async {
                weakself?.videoCategoryButton.isEnabled = true
                weakself?.languageGenreButton.isEnabled = true
            }
            if let responseError = error
            {
                print(responseError.localizedDescription)
                return
            }
            
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    if weakself?.loadedPage == 0
                    {
                        weakself?.languageGenreDetailModel = LanguageGenreDetailModel(JSONString: responseString)
                        if weakself?.languageGenreDetailModel?.data?.items?.count != 0 && weakself?.languageGenreDetailModel?.data?.items?.count != nil{
                            DispatchQueue.main.async {
                                JCDataStore.sharedDataStore.languageGenreDetailModel = weakself?.languageGenreDetailModel
                                
                                self.languageGenreButton.isEnabled = true
                                self.languageGenreCollectionView.isHidden = false
                                self.noVideosAvailableLabel.isHidden = true
                                weakself?.prepareView()
                            }
                            
                        }
                        else{
                            DispatchQueue.main.async {
                                self.languageGenreButton.isEnabled = false
                                self.languageGenreCollectionView.isHidden = true
                                self.noVideosAvailableLabel.isHidden = false
                                weakself?.prepareView()
                            }
                        }
                    }
                    else
                    {
                        let tempData = LanguageGenreDetailModel(JSONString: responseString)
                        if let items = tempData?.data?.items{
                            for item in items
                            {
                                weakself?.languageGenreDetailModel?.data?.items?.append(item)
                            }
                            DispatchQueue.main.async {
                                weakself?.languageGenreCollectionView.reloadData()
                            }
                        }

                    }
                }
            }
        }*/
    }
    
    func prepareView()
    {
        if item?.app?.type == VideoType.Language.rawValue
        {
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.normal)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.focused)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.selected)
            languageGenreButton.setTitle((currentParamString ?? "").appending("  ▼"), for: UIControlState.normal)
            languageGenreButton.setTitle((currentParamString ?? "").appending("  ▼"), for: UIControlState.focused)
            languageGenreButton.setTitle((currentParamString ?? "").appending("  ▼"), for: UIControlState.selected)
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.normal)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.focused)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.selected)
            languageGenreButton.setTitle((currentParamString ?? "").appending("  ▼"), for: UIControlState.normal)
            languageGenreButton.setTitle((currentParamString ?? "").appending("  ▼"), for: UIControlState.focused)
            languageGenreButton.setTitle((currentParamString ?? "").appending("  ▼"), for: UIControlState.selected)
        }
        languageGenreCollectionView.reloadData()
        languageGenreCollectionView.layoutIfNeeded()
        
    }
    
    @IBAction func didClickOnVideoCategoryButton(_ sender: Any)
    {
        currentFilter = FilterType.VideoCategory
        let languageGenreSelectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreSelectionStoryBoardId) as! JCLanguageGenreSelectionVC

        languageGenreSelectionVC.textForHeader = "Select Content"

        languageGenreSelectionVC.dataSource = item?.list
        languageGenreSelectionVC.languageSelectionDelegate = self
        self.present(languageGenreSelectionVC, animated: false, completion: nil)
    }
    
    @IBAction func didClickOnLanguageGenreButton(_ sender: Any)
    {
        currentFilter = FilterType.LanguageGenre
        let languageGenreSelectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreSelectionStoryBoardId) as! JCLanguageGenreSelectionVC
        if item?.app?.type == VideoType.Language.rawValue
        {

            languageGenreSelectionVC.textForHeader = "Select Genre"
            languageGenreSelectionVC.dataSource = languageGenreDetailModel?.data?.genres
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {

            languageGenreSelectionVC.textForHeader = "Select Language"

            languageGenreSelectionVC.dataSource = languageGenreDetailModel?.data?.languages
        }
        languageGenreSelectionVC.languageSelectionDelegate = self
        self.present(languageGenreSelectionVC, animated: false, completion: nil)
    }
    
    func selectedFilter(filter: Int)
    {
        self.videoCategoryButton.isEnabled = false
        self.languageGenreButton.isEnabled = false
        if item?.app?.type == VideoType.Language.rawValue
        {
            var currentTypeId:Int?
            if let currentFilter = currentFilter {
                switch currentFilter {
                case .VideoCategory:
                    currentType = filter
                    currentTypeId = item?.list?[filter].id ?? 0
                    currentParamString = "All Genres"
                    callWebServiceForLanguageGenreData(isLanguage: true, pageNo: 0, paramString: currentParamString ?? "", type: currentTypeId ?? -1)
                case .LanguageGenre:
                    currentTypeId = item?.list?[currentType].id ?? 0
                    currentParamString = languageGenreDetailModel?.data?.genres?[filter].name ?? ""
                    callWebServiceForLanguageGenreData(isLanguage: true, pageNo: 0, paramString: currentParamString ?? "", type: currentTypeId ?? -1)
                }
            } else {
                self.videoCategoryButton.isEnabled = true
                self.languageGenreButton.isEnabled = true
            }
            
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {

            var currentTypeId:Int?
            if let currentFilter = currentFilter {
                switch currentFilter {
                case .VideoCategory:
                    currentType = filter
                    currentTypeId = item?.list?[filter].id ?? 0
                    currentParamString = "All Languages"
                    callWebServiceForLanguageGenreData(isLanguage: false, pageNo: 0, paramString: currentParamString ?? "", type: currentTypeId ?? -1)
                case .LanguageGenre:
                    currentTypeId = item?.list?[currentType].id ?? 0
                    currentParamString = languageGenreDetailModel?.data?.languages?[filter].name ?? ""
                    callWebServiceForLanguageGenreData(isLanguage: false, pageNo: 0, paramString: currentParamString ?? "", type: currentTypeId ?? -1)
                }

            }
            
        }
        loadedPage = 0
    }
    
    
    func presentLoginVC()
    {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func prepareToPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int, fromScreen: String)
    {
        if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
            if appType == .Clip || appType == .Music || appType == .Trailer{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: fromScreen, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
            else if appType == .Episode{
                let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (itemToBePlayed.description) ?? "", appType: appType, isPlayList: (itemToBePlayed.isPlaylist) ?? false, playListId: (itemToBePlayed.playlistId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: false, fromScreen: fromScreen, fromCategory: categoryName, fromCategoryIndex: categoryIndex, fromLanguage: itemToBePlayed.language ?? "")
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- For after login function
    fileprivate var itemAfterLogin: Item? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
    
    
    func checkLoginAndPlay(_ itemToBePlayed: Item, categoryName: String, categoryIndex: Int) {
        //weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            let fromScreen = (item?.app?.type == VideoType.Language.rawValue) ? LANGUAGE_SCREEN : GENRE_SCREEN
            prepareToPlay(itemToBePlayed, categoryName: categoryName, categoryIndex: categoryIndex, fromScreen: fromScreen)
        }
        else
        {
            self.itemAfterLogin = itemToBePlayed
            self.categoryNameAfterLogin = categoryName
            self.categoryIndexAfterLogin = categoryIndex
            presentLoginVC()
        }
    }
    
}

extension JCLanguageGenreVC:UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let count = languageGenreDetailModel?.data?.items?.count {
            return count
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell

        if let imageUrl = languageGenreDetailModel?.data?.items?[indexPath.row].banner
        {

            cell.nameLabel.text = languageGenreDetailModel?.data?.items?[indexPath.row].name ?? ""
            if let baseImageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image {
                let url = URL(string: baseImageUrl + imageUrl)
                cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                    (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                });
            }

        }
        
        DispatchQueue.main.async {
        if(indexPath.row == (self.languageGenreDetailModel?.data?.items?.count ?? 0) - 1)
        {
            if(self.loadedPage < (self.languageGenreDetailModel?.pageCount ?? 0) - 1)
            {
                if self.item?.app?.type == VideoType.Language.rawValue {
                    self.callWebServiceForLanguageGenreData(isLanguage: true, pageNo: self.loadedPage+1,paramString: self.currentParamString ?? "", type: self.currentType)
                }
                else
                {
                    self.callWebServiceForLanguageGenreData(isLanguage: false, pageNo: self.loadedPage+1,paramString: self.currentParamString ?? "", type: self.currentType)
                }
                
                self.loadedPage += 1
            }
        }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryName = languageGenreDetailModel?.data?.items?[indexPath.row].name ?? ""
        let fromScreen = (item?.app?.type == VideoType.Language.rawValue) ? LANGUAGE_SCREEN : GENRE_SCREEN
        if let tappedItem = languageGenreDetailModel?.data?.items?[indexPath.row], let appTypeInt = tappedItem.app?.type, let videoType = VideoType(rawValue: appTypeInt) {
            switch videoType {
            case .Movie:
                print("At Movie")
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id ?? "", appType: videoType, fromScreen: fromScreen, categoryName: categoryName, categoryIndex: indexPath.row, tabBarIndex: 0, languageData: item)
                self.present(metadataVC, animated: true, completion: nil)
            case .TVShow:
                print("At TvShow")
                let metadataVC = Utility.sharedInstance.prepareMetadata(tappedItem.id ?? "", appType: videoType, fromScreen: fromScreen, categoryName: categoryName, categoryIndex: indexPath.row, tabBarIndex: 0, languageData: item)
                self.present(metadataVC, animated: true, completion: nil)
            case .Music, .Clip, .Episode, .Trailer:
                checkLoginAndPlay(tappedItem, categoryName: categoryName, categoryIndex: indexPath.row)
            default:
                print("Default")
            }
        }
    }
}
