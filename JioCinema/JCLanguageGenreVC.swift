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
    var languageGenreDetailModel:LanguageGenreDetailModel?
    
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
            callWebServiceForLanguageGenreData(isLanguage: true, pageNo: loadedPage,paramString: currentParamString!, type: currentType)
            headerLabel.text = item?.language
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            currentParamString = "All Languages"
            callWebServiceForLanguageGenreData(isLanguage: false, pageNo: loadedPage,paramString: currentParamString!, type: currentType)
            headerLabel.text = item?.genre
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callWebServiceForLanguageGenreData(isLanguage:Bool,pageNo:Int,paramString:String,type:Int)
    {
        let url = langGenreDataUrl.appending("\(pageNo)")
        var params = [String:Any]()
        if isLanguage
        {
            var langArray = [String]()
            langArray.append((item!.name)!)
            params["lang"] = langArray
            params["genres"] = [paramString]
            params["type"] = type
            params["filter"] = 0
            params["key"] = "language"
            
        }
        else
        {
            var genreArray = [String]()
            genreArray.append((item?.genre)!)
            params["lang"] = [paramString]
            params["genres"] = genreArray
            params["type"] = type
            params["filter"] = 0
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
//                        DispatchQueue.main.async {
//                            weakself?.prepareView()
//                        }
                    }
                    else
                    {
                        let tempData = LanguageGenreDetailModel(JSONString: responseString)
                        
                        for item in (tempData?.data?.items)!
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
        
    }
    
    func prepareView()
    {
        if item?.app?.type == VideoType.Language.rawValue
        {
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.normal)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.focused)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.selected)
            languageGenreButton.setTitle(currentParamString!.appending("  ▼"), for: UIControlState.normal)
            languageGenreButton.setTitle(currentParamString!.appending("  ▼"), for: UIControlState.focused)
            languageGenreButton.setTitle(currentParamString!.appending("  ▼"), for: UIControlState.selected)
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.normal)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.focused)
            videoCategoryButton.setTitle(item?.list?[currentType].name?.appending("  ▼"), for: UIControlState.selected)
            languageGenreButton.setTitle(currentParamString!.appending("  ▼"), for: UIControlState.normal)
            languageGenreButton.setTitle(currentParamString!.appending("  ▼"), for: UIControlState.focused)
            languageGenreButton.setTitle(currentParamString!.appending("  ▼"), for: UIControlState.selected)
        }
        languageGenreCollectionView.reloadData()
        
    }
    
    @IBAction func didClickOnVideoCategoryButton(_ sender: Any)
    {
        currentFilter = FilterType.VideoCategory
        let languageGenreSelectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreSelectionStoryBoardId) as! JCLanguageGenreSelectionVC
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
            languageGenreSelectionVC.dataSource = languageGenreDetailModel?.data?.genres
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            languageGenreSelectionVC.dataSource = languageGenreDetailModel?.data?.languages
        }
        languageGenreSelectionVC.languageSelectionDelegate = self
        self.present(languageGenreSelectionVC, animated: false, completion: nil)
    }
    
    func selectedFilter(filter: Int)
    {
        if item?.app?.type == VideoType.Language.rawValue
        {
            switch currentFilter! {
            case .VideoCategory:
                currentType = filter
                currentParamString = "All Genres"
                callWebServiceForLanguageGenreData(isLanguage: true, pageNo: 0, paramString: currentParamString!, type: currentType)
            case .LanguageGenre:
                currentParamString = languageGenreDetailModel?.data?.genres?[filter].name
                callWebServiceForLanguageGenreData(isLanguage: true, pageNo: 0, paramString: currentParamString!, type: currentType)
            }
        }
        else if item?.app?.type == VideoType.Genre.rawValue
        {
            switch currentFilter! {
            case .VideoCategory:
                currentType = filter
                currentParamString = "All Genres"
                callWebServiceForLanguageGenreData(isLanguage: false, pageNo: 0, paramString: currentParamString!, type: currentType)
            case .LanguageGenre:
                currentParamString = languageGenreDetailModel?.data?.languages?[filter].name
                callWebServiceForLanguageGenreData(isLanguage: false, pageNo: 0, paramString: currentParamString!, type: currentType)
            }
        }
        loadedPage = 0
    }
    
}

extension JCLanguageGenreVC:UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if languageGenreDetailModel?.data?.items?.count != nil
        {
            return (languageGenreDetailModel?.data?.items?.count)!
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellIdentifier, for: indexPath) as! JCItemCell

        if let imageUrl = languageGenreDetailModel?.data?.items?[indexPath.row].banner!
        {
            cell.nameLabel.text = languageGenreDetailModel?.data?.items?[indexPath.row].name!
            let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
            DispatchQueue.main.async {
                cell.itemImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                    (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                })
            }
            
        }
        
        if(indexPath.row == (languageGenreDetailModel?.data?.items?.count)! - 1)
        {
            if(loadedPage < (languageGenreDetailModel?.pageCount)! - 1)
            {
                if item?.app?.type == VideoType.Language.rawValue {
                    callWebServiceForLanguageGenreData(isLanguage: true, pageNo: loadedPage+1,paramString: currentParamString!, type: currentType)
                }
                else
                {
                    callWebServiceForLanguageGenreData(isLanguage: false, pageNo: loadedPage+1,paramString: currentParamString!, type: currentType)
                }
                
                loadedPage += 1
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionIndex = collectionView.tag
        
        if item?.app?.type == VideoType.Language.rawValue {
            selectedItemFromViewController = VideoType.Language
        }
        else if item?.app?.type == VideoType.Genre.rawValue {
            selectedItemFromViewController = VideoType.Genre
        }
        
        if currentType == VideoType.Movie.rawValue || currentType == VideoType.TVShow.rawValue
        {
            showMetaData(forItemIndex: indexPath.row)
        }
        else
        {
            if JCLoginManager.sharedInstance.isUserLoggedIn()
            {
                showPlayerVC(forIndexPath: indexPath.row)
            }
            else
            {
                presentLoginVC()
            }
        }
        
    }
    
    func presentLoginVC()
    {
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: loginVCStoryBoardId)
        loginVC.modalPresentationStyle = .overFullScreen
        loginVC.modalTransitionStyle = .coverVertical
        loginVC.view.layer.speed = 0.7
        self.present(loginVC, animated: true, completion: nil)
    }
    
    fileprivate func showMetaData(forItemIndex itemIndex: Int)
    {
        let metadataVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: metadataVCStoryBoardId) as! JCMetadataVC
        metadataVC.item = languageGenreDetailModel?.data?.items?[itemIndex]
        metadataVC.modalPresentationStyle = .overFullScreen
        metadataVC.modalTransitionStyle = .coverVertical
        self.present(metadataVC, animated: false, completion: nil)
    }
    
    fileprivate func showPlayerVC(forIndexPath index:Int)
    {
        let model = languageGenreDetailModel?.data?.items?[index]
        
        let playerId = languageGenreDetailModel?.data?.items?[index].id
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        playerVC.currentItemDescription = languageGenreDetailModel?.data?.items?[index].description
        playerVC.currentItemTitle = languageGenreDetailModel?.data?.items?[index].name
        playerVC.currentItemImage = languageGenreDetailModel?.data?.items?[index].banner
        
        
        playerVC.item = model
        //playerVC.currentItemDuration = languageGenreDetailModel?.data?.items?[index].totalDuration
        playerVC.callWebServiceForPlaybackRights(id: playerId!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        
        self.present(playerVC, animated: false, completion: nil)
    }
}
