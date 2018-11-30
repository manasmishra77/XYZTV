
//
//  JCMetadataVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class JCMetadataVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MetadataHeaderCellDelegate, JCBaseTableViewCellDelegate {
    
    var item: Item?
    var metadata: MetadataModel?
    fileprivate var selectedYearIndex = 0
    fileprivate let headerCell = Bundle.main.loadNibNamed("kMetadataHeaderView", owner: self, options: nil)?.last as! MetadataHeaderView
    
    //New metadata model
    var itemId = ""
    var itemAppType = VideoType.Movie
    var categoryName: String?
    var categoryIndex: Int?
    var fromScreen: String?
    var tabBarIndex: Int? = nil
    var shouldUseTabBarIndex = false
    var isMetaDataAvailable = false
    var isUserComingFromPlayerScreen = false
    var defaultAudioLanguage: AudioLanguage?
    
    var languageModel: Item?
    fileprivate var toScreenName: String? = nil
    fileprivate var screenAppearTiming = Date()
    fileprivate var actualHeightOfTheDescContainerView: CGFloat?
    fileprivate var cellSelected = false
    fileprivate var selectedRowCell: Int?
    fileprivate var isMonthSelected = false
    fileprivate var myPreferredFocusView: UIView?
    
    @IBOutlet weak var metadataTableView: UITableView!
    @IBOutlet weak var metadataContainerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loaderContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var headerView: UIView?
    
    var isDisney = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        if isMetaDataAvailable {
            showMetadata()
            let headerView = prepareHeaderView()
            metadataTableView.tableHeaderView = headerView
            metadataTableView.reloadData()
            changeAddWatchlistButtonStatus(itemId, itemAppType)
        } else {
            callWebServiceForMetadata(id: itemId, newAppType: itemAppType)
        }
        // Do any additional setup after loading the view.
       
    }
    
    deinit {
        print("In Metadata Screen Deinit")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if isUserComingFromPlayerScreen {
            isUserComingFromPlayerScreen = false
            self.loaderContainerView.isHidden = false
            self.metadataContainerView.isHidden = true
            self.activityIndicator.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Clevertap Navigation Event
        let metadataType = itemAppType.rawValue
        metadataTableView.delegate = self
        metadataTableView.dataSource = self
        metadataTableView.reloadData()
        print("2222222222222...............")
        let eventProperties = ["Screen Name": fromScreen ?? "", "Platform": "TVOS", "Metadata Page": metadataType] as [String : Any]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        
        //Google Analytics for MetaData Screen
        let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
        JCAnalyticsManager.sharedInstance.event(category: METADATA_SCREEN, action: "Click", label: metadata?.name ?? "", customParameters: customParams)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        if let toScreen = toScreenName {
            Utility.sharedInstance.handleScreenNavigation(screenName: METADATA_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
            toScreenName = nil
        } else {
            let toScreen = self.tabBarController?.selectedViewController?.tabBarItem.title ?? ""
            Utility.sharedInstance.handleScreenNavigation(screenName: METADATA_SCREEN, toScreen: toScreen, duration: Int(Date().timeIntervalSince(screenAppearTiming)))
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let preferredView = myPreferredFocusView {
            return [preferredView]
        }
        return []
    }
    
    private func configureViews() {
        if isDisney {
            configueeDisneyView()
        } else {
            headerCell.configureViews()
        }
         self.metadataTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.metadataTableView.tableFooterView = UIView()
        self.loadingLabel.text = "Loading"
        configureHeaderCell()
    }
    private func configueeDisneyView() {
            headerCell.configureViews(true)
            //headerCell.backgroundColor = UIColor(red: 6.0/255.0, green: 33.0/255.0, blue: 63.0/255.0, alpha: 1.0)
            headerCell.addToWatchListButton.focusedBGColor = UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0)
            headerCell.playButton.focusedBGColor = UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0)
            metadataTableView.backgroundColor = UIColor(red: 6.0/255.0, green: 33.0/255.0, blue: 63.0/255.0, alpha: 1.0)
            self.view.backgroundColor =  UIColor(red: 6.0/255.0, green: 33.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }
    private func configureHeaderCell() {
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCSeasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: seasonCollectionViewCellIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCYearCell", bundle: nil), forCellWithReuseIdentifier: yearCellIdentifier)
        headerCell.monthsCollectionView.register(UINib.init(nibName:"JCMonthCell", bundle: nil), forCellWithReuseIdentifier: monthCellIdentifier)
        headerCell.addToWatchListButton.isEnabled = false
        headerCell.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if itemAppType == .Movie {
            if let moreArray =  metadata?.more, moreArray.count > 0 {
                if indexPath.row == 0 {
                    return rowHeightForPotrait
                } else {
                    return 350
                }
            }
            
        } else if itemAppType == .TVShow {
            if let episodeArray =  metadata?.episodes, episodeArray.count > 0 {
                if indexPath.row == 0 {
                    return rowHeightForLandscape
                } else {
                    return 350
                }
            }
        }
        return 0
    }
    
    
    var moreTableViewDatasource = [Any]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moreTableViewDatasource.removeAll()
        if self.itemAppType == .TVShow {
            if let episodeArray =  metadata?.episodes, episodeArray.count > 0 {
                moreTableViewDatasource.append(episodeArray)
            }
        } else {
            if let moreArray =  metadata?.more, moreArray.count > 0 {
                moreTableViewDatasource.append(moreArray)
            }
        }
        
        if let artistArray = metadata?.artist, artistArray.count > 0 {
            moreTableViewDatasource.append(artistArray)
        }
        return moreTableViewDatasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        cell.tableCellCollectionView.backgroundColor = UIColor.clear
        cell.itemFromViewController = itemAppType
        cell.isDisney = self.isDisney
        cell.moreLikeData = nil
        cell.episodes = nil
        cell.data = nil
        cell.artistImages = nil
        cell.cellDelgate = self
        cell.tag = indexPath.row
        
        cell.backgroundColor = .clear
        
        //Metadata for Movies
        if itemAppType == .Movie {
            if let moreArray = moreTableViewDatasource[indexPath.row] as? [Item] {
                cell.categoryTitleLabel.text = metadata?.displayText
                cell.itemArrayType = .more
                cell.itemsArray = moreArray
                //cell.moreLikeData = moreArray
                cell.tableCellCollectionView.reloadData()
            }
            if let artistArray = moreTableViewDatasource[indexPath.row] as? [String] {
                cell.categoryTitleLabel.text = "Cast & Crew"
                let dict = getStarCastImagesUrl(artists: artistArray)
                cell.itemArrayType = .artistImages
                cell.itemsArray = convertingArtistDictToArray(dict)
                cell.tableCellCollectionView.reloadData()
            }
        }
            
            // Metadata for TV
        else if itemAppType == .TVShow {
            if let episodeArray = moreTableViewDatasource[indexPath.row] as? [Episode] {
                cell.categoryTitleLabel.text = "Episodes"
                //cell.episodes = episodeArray
                cell.itemArrayType = .episode
                cell.itemsArray = episodeArray
                cell.tableCellCollectionView.reloadData()
            }
            if let artistArray = moreTableViewDatasource[indexPath.row] as? [String] {
                cell.categoryTitleLabel.text = "Cast & Crew"
                let dict = getStarCastImagesUrl(artists: artistArray)
                cell.itemArrayType = .artistImages
                cell.itemsArray = convertingArtistDictToArray(dict)
                cell.tableCellCollectionView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.clear
    }
    
    func prepareHeaderView() -> UIView {
        headerCell.seasonCollectionView.delegate = self
        headerCell.seasonCollectionView.dataSource = self
        headerCell.monthsCollectionView.delegate = self
        headerCell.monthsCollectionView.dataSource = self
        return self.prepareMetadataView()
    }
    
    func convertingArtistDictToArray(_ dict: [String: String]) -> [(String, String)] {
        var arr: [(String, String)] = []
        for (eachKey, eachValue) in dict {
            let element = (eachKey, eachValue)
            arr.append(element)
        }
        return arr
    }
    
    func resetHeaderView() -> UIView {
        return headerCell.resetView()
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func callToReloadWatchListStatusWhenJustLoggedIn(){
        self.changeAddWatchlistButtonStatus(itemId, itemAppType)
        
    }
    
    func callWebServiceForMetadata(id: String, newAppType: VideoType) {
        guard Utility.sharedInstance.isNetworkAvailable else {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        self.itemId = id
        self.itemAppType = newAppType
        self.changeAddWatchlistButtonStatus(id, newAppType)
        let url = metadataUrl.appending(id.replacingOccurrences(of: "/0/0", with: ""))
        RJILApiManager.getReponse(path: url, params: nil, postType: .GET, paramEncoding: .URL, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: MetadataModel.self) {[weak self] (response) in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                guard id != "" else {
                    self.handleAlertForMetaDataDataFailure()
                    return
                }
                self.isUserComingFromPlayerScreen = false
                self.loaderContainerView.isHidden = true
                self.metadataContainerView.isHidden = false
                self.activityIndicator.stopAnimating()
            }
            guard response.isSuccess else {
                DispatchQueue.main.async {
                    self.showMetadata()
                    self.handleAlertForMetaDataDataFailure()
                }
                return
            }
            self.metadata = response.model
            self.metadata?.more = nil
            self.metadata?.episodes = nil
            DispatchQueue.main.async {
                self.showMetadata()
                let headerView = self.prepareHeaderView()
                self.metadataTableView.tableHeaderView = headerView
            }
            self.callWebServiceForMoreLikeData(id: id)
        }
        /*
         let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
         weak var weakSelf = self
         RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
         DispatchQueue.main.async {
         guard id != "" else {
         weakSelf?.handleAlertForMetaDataDataFailure()
         return
         }
         weakSelf?.isUserComingFromPlayerScreen = false
         weakSelf?.loaderContainerView.isHidden = true
         weakSelf?.metadataContainerView.isHidden = false
         weakSelf?.activityIndicator.stopAnimating()
         }
         
         if let responseError = error
         {
         //TODO: handle error
         print(responseError)
         DispatchQueue.main.async {
         weakSelf?.showMetadata()
         //Utility.sharedInstance.showDismissableAlert(title: "Try Again!!", message: "")
         weakSelf?.handleAlertForMetaDataDataFailure()
         }
         return
         }
         if let responseData = data {
         
         weakSelf?.evaluateMetaData(dictionaryResponseData: responseData)
         DispatchQueue.main.async {
         weakSelf?.showMetadata()
         let headerView = weakSelf?.prepareHeaderView()
         weakSelf?.metadataTableView.tableHeaderView = headerView
         }
         weakSelf?.callWebServiceForMoreLikeData(id: id)
         return
         }
         }*/
    }
    
    func callWebServiceForMoreLikeData(id: String) {
        if itemAppType == .TVShow {
            if metadata?.isSeason ?? false {
                if let seasonNum = metadata?.filter?[0].season {
                    fetchMoreDataForEpisode(seasonIndex: seasonNum, isSeason: true, monthString: "", yearString: "")
                }
            } else {
                if let _ = metadata?.filter?[selectedYearIndex].filter?.floatValue(), let yearString = metadata?.filter?[selectedYearIndex].filter, let monthString = metadata?.filter?[selectedYearIndex].month?[0] {
                    fetchMoreDataForEpisode(seasonIndex: 0, isSeason: false, monthString: monthString, yearString: yearString)
                }
                
            }
            return
        }
        
        let url = (itemAppType == VideoType.Movie) ? metadataUrl.appending(id) : metadataUrl.appending(id + "/0/0")
        RJILApiManager.getReponse(path: url, postType: .GET, reponseModelType: MetadataModel.self) {[weak self] (response) in
            guard let self = self else {
                return
            }
            guard response.isSuccess else {
                return
            }
            let tempMetadata = response.model
            if self.itemAppType == VideoType.Movie {
                self.metadata?.more = tempMetadata?.more
            } else if self.itemAppType == VideoType.TVShow {
                if let episodes = tempMetadata?.episodes {
                    self.metadata?.episodes = episodes
                }
                self.metadata?.artist = tempMetadata?.artist
            }
            self.metadata?.displayText = tempMetadata?.displayText
            DispatchQueue.main.async {
                if let metatableView = self.metadataTableView {
                    metatableView.reloadData()
                    metatableView.layoutIfNeeded()
                }
                self.prepareMetdataArtistLabel()
                self.myPreferredFocusView = self.headerCell.playButton
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            
        }
        /*
         let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
         weak var weakSelf = self
         RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
         
         if let responseError = error {
         //TODO: handle error
         print(responseError)
         return
         }
         if let responseData = data {
         weakSelf?.evaluateMoreLikeData(dictionaryResponseData: responseData)
         DispatchQueue.main.async {
         if let metatableView = weakSelf?.metadataTableView {
         metatableView.reloadData()
         metatableView.layoutIfNeeded()
         }
         weakSelf?.prepareMetdataArtistLabel()
         weakSelf?.myPreferredFocusView = weakSelf?.headerCell.playButton
         weakSelf?.setNeedsFocusUpdate()
         weakSelf?.updateFocusIfNeeded()
         }
         }
         }*/
    }
    
    
    
    /*
     func evaluateMoreLikeData(dictionaryResponseData responseData: Data) {
     //Success
     if let responseString = String(data: responseData, encoding: .utf8) {
     let tempMetadata = MetadataModel(JSONString: responseString)
     print("\(String(describing: tempMetadata?.episodes?.count)) 1111")
     if itemAppType == VideoType.Movie {
     self.metadata?.more = tempMetadata?.more
     } else if itemAppType == VideoType.TVShow {
     if let episodes = tempMetadata?.episodes {
     let changedEpisodes = gettingEpisodesWithRequiredSequence(episodes)
     self.metadata?.episodes = changedEpisodes
     }
     self.metadata?.artist = tempMetadata?.artist
     }
     self.metadata?.displayText = tempMetadata?.displayText
     }
     }
     
     private func gettingEpisodesWithRequiredSequence(_ episodes: [Episode]) -> [Episode] {
     return episodes
     }
     
     func evaluateMetaData(dictionaryResponseData responseData: Data) {
     //Success
     if let responseString = String(data: responseData, encoding: .utf8) {
     let metaDataModel = MetadataModel(JSONString: responseString)
     self.metadata = metaDataModel
     self.metadata?.more = nil
     self.metadata?.episodes = nil
     print("\(String(describing: metadata)) + 123")
     }
     }*/
    
    func showMetadata() {
        loaderContainerView.isHidden = true
        metadataContainerView.isHidden = false
    }
    
    func presentLoginVC(fromAddToWatchList: Bool = false, fromItemCell: Bool = false, fromPlayNowButton: Bool = false) {
        toScreenName = LOGIN_SCREEN
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: fromAddToWatchList, fromPlayNowBotton: fromPlayNowButton, fromItemCell: fromItemCell, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //For after login function
    fileprivate var itemAfterLogin: Episode? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    func checkLoginAndPlay(_ itemToBePlayed: Episode, categoryName: String, categoryIndex: Int) {
        if(JCLoginManager.sharedInstance.isUserLoggedIn()) {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            prepareToPlay(itemToBePlayed, categoryName: categoryName, categoryIndex: categoryIndex)
        } else {
            self.itemAfterLogin = itemToBePlayed
            self.categoryNameAfterLogin = categoryName
            self.categoryIndexAfterLogin = categoryIndex
            presentLoginVC(fromAddToWatchList: false, fromItemCell: true)
        }
    }
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
    
    
    func getStarCastImagesUrl(artists: [String]) -> [String: String] {
        let modifiedArtists = artists.filter { (artistName) -> Bool in
            artistName != ""
        }
        var artistImages = [String: String]()
        for artist in modifiedArtists {
            let processedName = artist.replacingOccurrences(of: " ", with: "").lowercased()
            let encryptedData = convertStringToMD5Hash(artistName: processedName)
            let hexString = encryptedData.hexEncodedString()
            
            let index = hexString.index(hexString.startIndex, offsetBy: 8)
            
            //let firstFolder =  hexString.substring(to: index)
            let firstFolder =  hexString[..<index]
            
            let start = hexString.index(hexString.startIndex, offsetBy: 8)
            let end = hexString.index(hexString.startIndex, offsetBy: 16)
            let range = start..<end
            //let secondFolder = hexString.substring(with: range)
            let secondFolder = hexString[range]
            
            let firstFolderParsed = (Int(firstFolder, radix: 16))!%99
            let secondFolderParsed = (Int(secondFolder, radix: 16))!%99
            let imageUrl = "http://jioimages.cdn.jio.com/content/entry/data/\(firstFolderParsed)/\(secondFolderParsed)/\(hexString)_o_low.jpg"
            artistImages[artist] = imageUrl
            
        }
        return artistImages
    }
    
    func convertStringToMD5Hash(artistName:String) -> Data {
        let messageData = artistName.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension JCMetadataVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if metadata?.app?.type == VideoType.TVShow.rawValue {
            if let season = metadata?.isSeason, season, collectionView == headerCell.seasonCollectionView     //seasons
            {
                return (metadata?.filter?.count) ?? 0
                
            }
            else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
            {
                return (metadata?.filter?.count) ?? 0
            }
            else if collectionView == headerCell.monthsCollectionView  //months, in case of episodes
            {
                if  (metadata?.filter?.count) ?? 0 > selectedYearIndex {
                    if let count = (metadata?.filter?[selectedYearIndex].month?.count) {
                        return count
                    }
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let season = metadata?.isSeason, season, collectionView == headerCell.seasonCollectionView     //seasons
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seasonCollectionViewCellIdentifier, for: indexPath) as! JCSeasonCollectionViewCell
            cell.seasonNumberLabel.text = "Season " + String(describing: metadata?.filter?[indexPath.row].season ?? 0)
            cell.isDisney = self.isDisney
            if indexPath.row == 0 {
                if isDisney {
                    self.changeBorderColorOfCell(cell, toColor: UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0))
                } else {
                self.changeBorderColorOfCell(cell, toColor:  UIColor(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1))
                }
            }
            
            return cell
        }
        else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: yearCellIdentifier, for: indexPath) as! JCYearCell
            cell.yearLabel.text = metadata?.filter?[indexPath.row].filter ?? ""
            if indexPath.row == 0 {
                self.changeBorderColorOfCell(cell, toColor:  UIColor(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1))
            }
            return cell
        }
        else if collectionView == headerCell.monthsCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCellIdentifier, for: indexPath) as! JCMonthCell
            let intValueOfMonth = metadata?.filter?[selectedYearIndex].month?[indexPath.row] ?? "0"
            if let enumOfMonth = self.getMonthEnum(intValueOfMonth) {
                cell.monthLabel.text = enumOfMonth.name
            }
            if indexPath.row == 0 {
                self.changeBorderColorOfCell(cell, toColor:  UIColor(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1))
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seasonCollectionViewCellIdentifier, for: indexPath) as! JCSeasonCollectionViewCell
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        //cellSelected = true
        //selectedRowCell = indexPath.row
        
        if (metadata?.isSeason ?? false), collectionView == headerCell.seasonCollectionView     //seasons
        {
            if let seasonNum = metadata?.filter?[indexPath.row].season {
                self.myPreferredFocusView = collectionView.cellForItem(at: indexPath)
                self.changeCollectionViewCellStyle(collectionView, indexPath: indexPath)
                fetchMoreDataForEpisode(seasonIndex: seasonNum, isSeason: true, monthString: "", yearString: "")
            }
        } else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
        {
            selectedYearIndex = indexPath.row
            self.myPreferredFocusView = collectionView.cellForItem(at: indexPath)
            self.changeCollectionViewCellStyle(collectionView, indexPath: indexPath)
            
            if let _ = metadata?.filter?[selectedYearIndex].filter?.floatValue(), let yearString = metadata?.filter?[selectedYearIndex].filter, let monthString = metadata?.filter?[selectedYearIndex].month?[0] {
                self.headerCell.monthsCollectionView.reloadData()
                self.headerCell.monthsCollectionView.layoutIfNeeded()
                self.changeCollectionViewCellStyle(self.headerCell.monthsCollectionView, indexPath: IndexPath(row: 0, section: 0))
                fetchMoreDataForEpisode(seasonIndex: 0, isSeason: false, monthString: monthString, yearString: yearString)
            }
            
        } else    //months
        {
            if let _ = metadata?.filter?[selectedYearIndex].filter?.floatValue(), let yearString = metadata?.filter?[selectedYearIndex].filter, let monthString = metadata?.filter?[selectedYearIndex].month?[indexPath.row]{
                self.myPreferredFocusView = collectionView.cellForItem(at: indexPath)
                self.changeCollectionViewCellStyle(collectionView, indexPath: indexPath)
                fetchMoreDataForEpisode(seasonIndex: 0, isSeason: false, monthString: monthString, yearString: yearString)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == headerCell.seasonCollectionView {
            if metadata?.isSeason ?? false {
                return CGSize(width: 190, height: 50)
            } else {
                return CGSize(width: 100, height: 40)
            }
        } else {
            return CGSize(width: 80, height: 40)
        }
        
    }
    
    
    fileprivate func fetchMoreDataForEpisode(seasonIndex: Int, isSeason: Bool, monthString: String, yearString: String) {
        if isSeason {
            callWebServiceForSelectedFilter(filter: String(describing: seasonIndex))
            return
        }
        callWebServiceForSelectedFilter(filter: "\(yearString)/\(monthString)")
    }
    
    
    func callWebServiceForSelectedFilter(filter: String) {
        let url = metadataUrl.appending(metadata?.id ?? "").appending("/\(filter)")
        RJILApiManager.getReponse(path: url, postType: .GET, reponseModelType: MetadataModel.self) {[weak self] (response) in
            guard let self = self else {
                return
            }
            guard response.isSuccess else {
                return
            }
            let tempMetadata = response.model
            if self.itemAppType == VideoType.Movie {
                self.metadata?.more = tempMetadata?.more
            } else if self.itemAppType == VideoType.TVShow {
                if let episodes = tempMetadata?.episodes {
                    self.metadata?.episodes = episodes
                }
                self.metadata?.artist = tempMetadata?.artist
            }
            self.metadata?.displayText = tempMetadata?.displayText
            DispatchQueue.main.async {
                if let metatableView = self.metadataTableView {
                    metatableView.reloadData()
                    metatableView.layoutIfNeeded()
                }
                self.prepareMetdataArtistLabel()
                self.myPreferredFocusView = self.headerCell.playButton
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            
        }
        /*
         let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
         
         weak var weakSelf = self
         RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
         
         if let responseError = error {
         //TODO: handle error
         print(responseError)
         return
         }
         if let responseData = data {
         weakSelf?.evaluateMoreLikeData(dictionaryResponseData: responseData)
         DispatchQueue.main.async {
         weakSelf?.prepareMetdataArtistLabel()
         weakSelf?.metadataTableView.reloadData()
         weakSelf?.metadataTableView.layoutIfNeeded()
         weakSelf?.setNeedsFocusUpdate()
         weakSelf?.updateFocusIfNeeded()
         }
         return
         }
         }*/
    }
    
    /*
     func evaluateFilteredData(dictionaryResponseData responseData:Data) {
     //Success
     if let responseString = String(data: responseData, encoding: .utf8) {
     let tempMetadata = MetadataModel(JSONString: responseString)
     self.metadata?.episodes = tempMetadata?.episodes
     }
     }*/
    
    func handleAlertForMetaDataDataFailure() {
        let action = Utility.AlertAction(title: "Dismiss", style: .default)
        let alertVC = Utility.getCustomizedAlertController(with: "Server Error!", message: "", actions: [action]) { (alertAction) in
            if alertAction.title == action.title {
                self.dismiss(animated: false, completion: nil)
            }
        }
        present(alertVC, animated: false, completion: nil)
    }
    
    
    //MARK:- Change watchlist button status locally
    func changeAddWatchlistButtonStatus(_ itemIdToBeChecked: String, _ appType: VideoType) {
        self.headerCell.addToWatchListButton.isEnabled = true
        if checkIfItemIsInWatchList(itemIdToBeChecked, appType) {
            headerCell.watchlistLabel.text = REMOVE_FROM_WATCHLIST
        } else {
            headerCell.watchlistLabel.text = ADD_TO_WATCHLIST
        }
    }
    
    func checkIfItemIsInWatchList(_ itemIdToBeChecked: String, _ appType: VideoType) -> Bool {
        var watchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?[0].items
        if isDisney {
            watchListArray = JCDataStore.sharedDataStore.disneyTVWatchList?.data?[0].items
            if appType == .Movie {
                watchListArray = JCDataStore.sharedDataStore.disneyMovieWatchList?.data?[0].items
            }
        } else {
            watchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?[0].items
            if appType == .Movie{
                watchListArray = JCDataStore.sharedDataStore.moviesWatchList?.data?[0].items
            }
        }
        let itemMatched = watchListArray?.filter{ $0.id == itemIdToBeChecked}.first
        if itemMatched != nil {
            return true
        }
        return false
    }
    
    //MARK:- Metadata header cell delegate methods
    func didClickOnWatchNowButton(_ headerView: MetadataHeaderView?) {
        self.didClickOnShowMoreDescriptionButton(headerCell, toShowMore: false)
        if JCLoginManager.sharedInstance.isUserLoggedIn() {
            playVideo()
        } else {
            presentLoginVC(fromAddToWatchList: false, fromItemCell: false, fromPlayNowButton: true)
        }
    }
    func didClickOnShowMoreDescriptionButton(_ headerView: MetadataHeaderView, toShowMore: Bool) {
        if toShowMore {
            headerCell.showMoreDescriptionLabel.text = SHOW_LESS
            var descText = "" //(metadata?.description ?? "") + " " + SHOW_LESS
            if itemAppType == .TVShow {
                descText = (metadata?.descriptionForTVShow ?? "") + " " + SHOW_LESS
            } else {
                descText = (metadata?.description ?? "") + " " + SHOW_LESS
            }
            let widthofView = headerCell.descriptionContainerview.frame.size.width
            let font = UIFont(name: "Helvetica", size: 28)!
            let newHeight = (getSizeofDescriptionContainerView(descText, widthOfView: widthofView, font: font))
            headerCell.frame.size.height += newHeight - (itemAppType == .Movie ? 80 : 80)
            headerCell.descriptionContainerViewHeight.constant = newHeight
            
            headerCell.descriptionLabel.attributedText = getAttributedString(descText, colorChange: true, range: SHOW_LESS.count)
            headerCell.descriptionLabel.numberOfLines = 0
            metadataTableView.tableHeaderView = headerCell
        } else {
            guard headerCell.showMoreDescriptionLabel.text == SHOW_LESS else {
                return
            }
            var descText = "" //(metadata?.description ?? "") + " " + SHOW_LESS
            if itemAppType == .TVShow {
                descText = (metadata?.descriptionForTVShow ?? "") + " " + SHOW_LESS
            } else {
                descText = (metadata?.description ?? "") + " " + SHOW_LESS
            }
            let textTopple = getShorterText(descText)
            let widthofView = headerCell.descriptionContainerview.frame.size.width
            let font = UIFont(name: "Helvetica", size: 28)!
            let newHeight = getSizeofDescriptionContainerView(headerCell.descriptionLabel.text ?? "", widthOfView: widthofView, font: font)
            headerCell.frame.size.height -= newHeight - (itemAppType == .Movie ? 80 : 80)
            headerCell.showMoreDescriptionLabel.text = SHOW_MORE
            headerCell.descriptionContainerViewHeight.constant = actualHeightOfTheDescContainerView ?? 0
            headerCell.descriptionLabel.numberOfLines = 0
            headerCell.descriptionLabel.attributedText = textTopple.1
            metadataTableView.tableHeaderView = headerCell
        }
    }
    
    func didClickOnAddOrRemoveWatchListButton(_ headerView: MetadataHeaderView, isStatusAdd: Bool) {
        var params = [String: Any]()
        if isDisney {
            if itemAppType == .TVShow {
                params = ["uniqueId": JCAppUser.shared.unique, "listId": "33" ,"json": ["id": metadata?.contentId ?? itemId]]
            } else if itemAppType == .Movie {
                params = ["uniqueId": JCAppUser.shared.unique,"listId": "32" ,"json": ["id": metadata?.contentId ?? itemId]]
            }
        } else {
            if itemAppType == .TVShow {
                params = ["uniqueId": JCAppUser.shared.unique, "listId": "13" ,"json": ["id": metadata?.contentId ?? itemId]]
            } else if itemAppType == .Movie {
                params = ["uniqueId": JCAppUser.shared.unique,"listId": "12" ,"json": ["id": metadata?.contentId ?? itemId]]
            }
        }
        if JCLoginManager.sharedInstance.isUserLoggedIn() {
            let url = isStatusAdd ? addToWatchListUrl : removeFromWatchListUrl

            callWebServiceToUpdateWatchlist(withUrl: url, watchlistStatus: isStatusAdd, andParameters: params)
        } else {
            presentLoginVC(fromAddToWatchList: true, fromItemCell: false)
        }
    }
    
    func callWebServiceToUpdateWatchlist(withUrl url: String, watchlistStatus: Bool, andParameters params: [String: Any]) {
        print(self.item)
        self.headerCell.addToWatchListButton.isEnabled = false
        RJILApiManager.getReponse(path: url, params: params, postType: .POST, paramEncoding: .JSON, shouldShowIndicator: false, isLoginRequired: false, reponseModelType: NoModel.self) {[weak self] (response) in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.headerCell.addToWatchListButton.isEnabled = true
            }
            guard response.isSuccess else {
                self.sendGoogleAnalyticsForWatchlist(with: watchlistStatus, andErrorMesage: response.errorMsg ?? "")
                return
            }
            
            self.sendGoogleAnalyticsForWatchlist(with: watchlistStatus, andErrorMesage: "")
            DispatchQueue.main.async {
                if self.headerCell.watchlistLabel.text == ADD_TO_WATCHLIST {
                    self.headerCell.watchlistLabel.text = REMOVE_FROM_WATCHLIST
                } else {
                    self.headerCell.watchlistLabel.text = ADD_TO_WATCHLIST
                }
            }
            //ChangingTheDataSourceForWatchListItems
            if self.isDisney {
                NotificationCenter.default.post(name: WatchlistUpdatedNotificationName, object: nil)
            }
            self.changingDataSourceForWatchList()
        }
        /*
         let updateWatchlistRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
         RJILApiManager.defaultManager.post(request: updateWatchlistRequest) { (data, response, error) in
         DispatchQueue.main.async {
         self.headerCell.addToWatchListButton.isEnabled = true
         }
         if let responseError = error as NSError?
         {
         //TODO: handle error
         print(responseError)
         
         self.sendGoogleAnalyticsForWatchlist(with: watchlistStatus, andErrorMesage: responseError.localizedDescription)
         //Refresh sso token call fails
         if responseError.code == 143{
         print("Refresh sso token call fails")
         DispatchQueue.main.async {
         //JCLoginManager.sharedInstance.logoutUser()
         //self.presentLoginVC()
         }
         }
         return
         }
         
         if let responseData = data,let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
         {
         let code = parsedResponse["code"] as? Int
         if(code == 200)
         {
         self.sendGoogleAnalyticsForWatchlist(with: watchlistStatus, andErrorMesage: "")
         DispatchQueue.main.async {
         if self.headerCell.watchlistLabel.text == ADD_TO_WATCHLIST{
         self.headerCell.watchlistLabel.text = REMOVE_FROM_WATCHLIST
         }else{
         self.headerCell.watchlistLabel.text = ADD_TO_WATCHLIST
         }
         }
         //ChangingTheDataSourceForWatchListItems
         self.changingDataSourceForWatchList()
         }
         return
         }
         }*/
        
    }
    
    func sendGoogleAnalyticsForWatchlist(with watchlistStatus: Bool, andErrorMesage errorMsg: String)
    {
        let customParams: [String:Any] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ,"Video Id": metadata?.videoId ?? "", "Type": metadata?.app?.type ?? 0, "Language": metadata?.language ?? "", "Bitrate" : metadata?.bitrate ?? "", "General Data": errorMsg]
        if watchlistStatus {
            JCAnalyticsManager.sharedInstance.event(category: PLAYER_OPTIONS, action: ADD_TO_WATCHLIST, label: metadata?.name, customParameters: customParams as? Dictionary<String, String>)
        }
        else{
            JCAnalyticsManager.sharedInstance.event(category: PLAYER_OPTIONS, action: REMOVE_FROM_WATCHLIST, label: metadata?.name, customParameters: customParams as? Dictionary<String, String>)
        }
    }
    //ChangingTheDataSourceForWatchListItems
    func changingDataSourceForWatchList() {
        if let navVc = (self.presentingViewController?.presentingViewController ?? self.presentingViewController) as? UINavigationController {
            if let tabVC = navVc.viewControllers[0] as? UITabBarController{
                if isDisney {
                        if let vc = tabVC.viewControllers![4] as? BaseViewController {
//                            if self.itemAppType == VideoType.TVShow{
                            vc.callWebServiceForWatchlist()
//                            }
//                            else {
//                             vc.callWebServiceForWatchlist()
//                        }
                    }
                } else {
                    if self.itemAppType == VideoType.TVShow{
                        if let vc = tabVC.viewControllers![2] as? JCTVVC{
                            vc.callWebServiceForTVWatchlist()
                        }
                    }
                    if self.itemAppType == VideoType.Movie{
                        if let vc = tabVC.viewControllers![1] as? JCMoviesVC{
                            vc.callWebServiceForMoviesWatchlist()
                        }
                    }
                }
            }
        }
        
    }
    func returnMaturityRating() -> String {
        if var maturityRating = metadata?.maturityRating {
            if  maturityRating.capitalized == "All"  {
                maturityRating = "3+"
            }
            else if maturityRating == "" {
                maturityRating = "NR"
            }
            return " | Maturity Rating: \(maturityRating)"
        } else {
            return " | Maturity Rating: NR"
        }
    }
    //prepare metadata view
    func prepareMetadataView() -> UIView {
        headerCell.frame.size.width = metadataContainerView.frame.size.width
        headerCell.frame.size.height = getHeaderContainerHeight()
        headerCell.titleLabel.text = metadata?.name
        headerCell.subtitleLabel.text = metadata?.newSubtitle?.appending(returnMaturityRating())
        headerCell.directorLabel.text = metadata?.directors?.joined(separator: ",")
        if let audio = metadata?.multipleAudio {
        headerCell.multiAudioLanguge.text = "Audio : \(audio)"
        }
        var descText = "" //(metadata?.description ?? "") + " " + SHOW_LESS
        if itemAppType == .TVShow {
            descText = (metadata?.descriptionForTVShow ?? "")// + " " + SHOW_LESS
        } else {
            descText = (metadata?.description ?? "")// + " " + SHOW_LESS
        }
        let trimTextTopple = getShorterText(descText)
        if trimTextTopple.0 {
            headerCell.descriptionLabel.attributedText = trimTextTopple.1
            headerCell.showMoreDescription.isEnabled = true
        } else {
            headerCell.descriptionLabel.attributedText = trimTextTopple.1
            headerCell.showMoreDescription.isEnabled = false
        }
        actualHeightOfTheDescContainerView = headerCell.descriptionContainerViewHeight.constant
        
        let imageUrl = (JCDataStore.sharedDataStore.configData?.configDataUrls?.image ?? "") + (metadata?.banner ?? "")
        let url = URL(string: imageUrl)
        DispatchQueue.main.async {
            self.headerCell.bannerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in})
        }
        //self.applyGradient(self.headerCell.bannerImageView)
        myPreferredFocusView = headerCell.playButton
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
        if itemAppType == .Movie, metadata != nil {
            return headerCell
        } else if itemAppType == VideoType.TVShow, metadata != nil {
            headerCell.titleLabel.text = metadata?.name
            headerCell.imdbImageLogo.isHidden = true
            headerCell.ratingLabel.isHidden = true
            headerCell.tvShowLabel.text = "\(metadata?.newSubtitle?.capitalized ?? "") \((returnMaturityRating()))"
            headerCell.tvShowLabel.isHidden = false
            headerCell.subtitleLabel.isHidden = true
            headerCell.directorLabel.isHidden = true
            headerCell.directorStaticLabel.isHidden = true
            headerCell.sseparationBetweenDirectorStaticAndDescView.constant -= headerCell.directorStaticLabel.frame.height + 8
            headerCell.frame.size.height -= headerCell.directorStaticLabel.frame.height + 8
            
            if (metadata?.isSeason) != nil {
                if (metadata?.isSeason)! {
                    headerCell.seasonsLabel.isHidden = false
                    headerCell.seasonCollectionView.isHidden = false
                    headerCell.monthsCollectionView.isHidden = true
                    headerCell.seasonsLabel.isHidden = true
                    headerCell.sseparationBetweenSeasonLabelAndSeasonCollView.constant = 0
                    headerCell.heightOfSeasonStaticLabel.constant = 0
                } else {
                    headerCell.seasonsLabel.isHidden = false
                    headerCell.seasonsLabel.text = "More Episodes"
                    headerCell.seasonCollectionView.isHidden = false
                    headerCell.monthsCollectionView.isHidden = false
                }
            }
            return headerCell
        } else {
            return UIView()
        }
    }
    
    func prepareMetdataArtistLabel() {
        headerCell.starringLabel.text =  metadata?.artist?.joined(separator: ", ")
    }
    
    //MARK:- JCBaseTableViewCellDelegate methods, More tableview cell delegate methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        if let tappedItem = item as? Item {
            let itemToBePlayed = self.convertingMoreToItem(tappedItem, currentItem: Item())
            if let itemId = itemToBePlayed.id {
                self.item = itemToBePlayed
                if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt) {
                    self.didClickOnShowMoreDescriptionButton(self.headerCell, toShowMore: false)
                    self.callWebServiceForMetadata(id: itemId, newAppType: appType)
                }
            }
        }
        else if let tappedItem = item as? Episode {
            print("In episode")
            checkLoginAndPlay(tappedItem, categoryName: MORELIKE, categoryIndex: 0)
        }
        else if let tappedItem = item as? String{
            print("In Artist")
            //present search from here
            
            //Google Analytics for Artist Click
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: PLAYER_OPTIONS, action: "Artist Click", label: metadata?.name, customParameters: customParams)
            
            if let superNav = self.presentingViewController as? UINavigationController, let tabController = superNav.viewControllers[0] as? JCTabBarController{
                let metaDataTabBarIndex = tabController.selectedIndex
                tabController.selectedIndex = 5
                if let searchVcNav = tabController.selectedViewController as? UINavigationController{
                    if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController{
                        if let searchVc = sc.searchController.searchResultsController as? JCSearchResultViewController {
                            searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: metaDataTabBarIndex, metaData: metadata ?? false)
                        }
                    }
                }
                self.dismiss(animated: true, completion: nil)
            } else if let superNav = self.presentingViewController?.presentingViewController as? UINavigationController, let tabController = superNav.viewControllers[0] as? JCTabBarController {
                tabController.selectedIndex = 5
                if let searchVcNav = tabController.selectedViewController as? UINavigationController {
                    if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController {
                        if let searchVc = sc.searchController.searchResultsController as? JCSearchResultViewController {
                            searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 0, metaData: metadata ?? false, languageModel: languageModel)
                        }
                    }
                }
                if let langVC = superNav.presentedViewController as? JCLanguageGenreVC {
                    self.dismiss(animated: false, completion: {
                        langVC.dismiss(animated: false, completion: nil)
                    })
                }
            }
        }
    }
    
    func prepareToPlay(_ itemToBePlayed: Episode, categoryName: String, categoryIndex: Int) {
        var isEpisodeAvailable = false
        if let episeodes = metadata?.episodes, episeodes.count > 0{
            isEpisodeAvailable = true
        }
        var directors = ""
        if let directorArray = metadata?.directors {
            directors = directorArray.reduce("", +)
        }
        var artists = ""
        if let artistArray = metadata?.artist {
            artists = artistArray.reduce("", +)
        }
        
        let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: itemToBePlayed.id ?? "", isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: metadata?.episodes ?? false, fromScreen: METADATA_SCREEN, fromCategory: MORELIKE, fromCategoryIndex: 0, fromLanguage: item?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor, isDisney: isDisney, audioLanguage: defaultAudioLanguage)

        self.present(playerVC, animated: true, completion: nil)
    }
    
    func convertingMoreToItem(_ moreItem: Item, currentItem: Item) -> Item {
        return moreItem
        /*
         let tempItem = Item()
         tempItem.id = moreItem.id
         tempItem.name = moreItem.name
         tempItem.showname = ""
         tempItem.subtitle = moreItem.subtitle
         tempItem.image = moreItem.image
         tempItem.tvImage = ""
         tempItem.description = moreItem.description
         tempItem.banner = moreItem.banner
         tempItem.format = moreItem.format
         tempItem.language = moreItem.language
         tempItem.vendor = ""
         tempItem.app = moreItem.app
         tempItem.latestId = ""
         tempItem.layout = -1
         
         return tempItem*/
    }
    func playVideo() {
        if !Utility.sharedInstance.isNetworkAvailable {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        toScreenName = PLAYER_SCREEN
        let artists = metadata?.artist?.reduce("", { (res, str) in
            res + "," + str
        })
        let directors = metadata?.directors?.reduce("", { (res, str) in
            res + "," + str
        })
        if itemAppType == .Movie{
            var isMoreDataAvailable = false
            var recommendationArray: Any = false
            if let moreArray = metadata?.more, moreArray.count > 0{
                isMoreDataAvailable = true
                recommendationArray = moreArray
            }
            
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemId, itemImageString: (metadata?.banner) ?? "", itemTitle: (metadata?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (metadata?.description) ?? "", appType: .Movie, isPlayList: false, playListId: "", isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: recommendationArray ,fromScreen: fromScreen ?? METADATA_SCREEN, fromCategory: categoryName ?? WATCH_NOW_BUTTON, fromCategoryIndex: categoryIndex ?? 0, fromLanguage: metadata?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor, isDisney: isDisney, audioLanguage: defaultAudioLanguage)

            
            self.present(playerVC, animated: true, completion: nil)
        }
        else if itemAppType == .TVShow {
            var isEpisodeAvailable = false
            var recommendationArray: Any = false
            if let episodes = metadata?.episodes, episodes.count > 0{
                isEpisodeAvailable = true
                recommendationArray = episodes
            }
            let playerVC = Utility.sharedInstance.preparePlayerVC((metadata?.latestEpisodeId) ?? "", itemImageString: (item?.banner) ?? "", itemTitle: (item?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: (metadata?.latestEpisodeId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: recommendationArray, fromScreen: fromScreen ?? METADATA_SCREEN, fromCategory: categoryName ?? WATCH_NOW_BUTTON, fromCategoryIndex: categoryIndex ?? 0, fromLanguage: metadata?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor, audioLanguage: defaultAudioLanguage)
            self.present(playerVC, animated: true, completion: nil)
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if  presses.first?.type == .menu, shouldUseTabBarIndex, (tabBarIndex != nil) {
            if let superNav = self.presentingViewController as? UINavigationController, let tabc = superNav.viewControllers[0] as? JCTabBarController {
                tabc.selectedIndex = tabBarIndex!
                if let languageModel = languageModel {
                    let vc = self.presentLanguageGenreController(item: languageModel)
                    self.dismiss(animated: false, completion: {
                        superNav.present(vc, animated: false, completion: nil)
                    })
                }
            } else if let superNav = self.presentingViewController?.presentingViewController as? UINavigationController, let tabc = superNav.viewControllers[0] as? JCTabBarController {
                tabc.selectedIndex = 0
                //self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            //            self.dismiss(animated: true, completion: nil)
        }
    }
    func presentLanguageGenreController(item: Item) -> JCLanguageGenreVC {
        toScreenName = LANGUAGE_SCREEN
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
//        languageGenreVC.defaultLanguage = item.defaultAudioLanguage
        return languageGenreVC
    }
    
    //DescriptionContainerview size fixing
    func getSizeofDescriptionContainerView(_ text: String, widthOfView: CGFloat, font: UIFont) -> CGFloat {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        let heightOfTheString = text.heightForWithFont(font: font, width: widthOfView, insets: inset)
        return heightOfTheString
    }
    
    //Trim description text
    func getShorterText(_ text: String) -> (Bool, NSAttributedString) {
        if text.count > 95 {
            let trimText = text.subString(start: 0, end: 94) + "... " + SHOW_MORE
            if trimText.count <= text.count {
                let fontChangedText = getAttributedString(trimText, colorChange: true, range: 10)
                return (true, fontChangedText)
            } else {
                let fontChangedText = getAttributedString(text, colorChange: false, range: 0)
                return (false, fontChangedText)
            }
        } else {
            let newerText = text//.dropLast(SHOW_LESS.count)
            let fontChangedText = getAttributedString(String(newerText), colorChange: false, range: 0)
            return (false, fontChangedText)
        }
    }
    
    func getAttributedString (_ text: String, colorChange: Bool, range:Int) -> NSMutableAttributedString {
        var colorToChange = UIColor(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1)
        if isDisney{
            colorToChange = UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        }
        let fontChangedText = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 28.0)!])
        fontChangedText.addAttribute(NSAttributedStringKey.foregroundColor, value:  UIColor(red: 1, green: 1, blue: 1, alpha: 1), range: NSRange(location: 0, length: text.count))
        if colorChange {
            fontChangedText.addAttribute(NSAttributedStringKey.foregroundColor, value:  colorToChange, range: NSRange(location: text.count - range, length: range))
            fontChangedText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "HelveticaNeue-Bold", size: 22.0)!, range: NSRange(location: text.count - range, length: range))
        }

        return fontChangedText
    }
    
    //Height of the table header container
    func getHeaderContainerHeight() -> CGFloat {
        switch itemAppType {
        case .Movie:
            //To be changed to dynamic one
            return 689
        case .TVShow:
            //To be changed to dynamic one
            if metadata?.isSeason ?? false {
                let heightOfView = 780
                return CGFloat(heightOfView)
            }
            return 900
        default:
            return 0
        }
    }
    
    //Changing collectionview border color(month, season collection view)
    func changeCollectionViewCellStyle(_ collectionView: UICollectionView, indexPath: IndexPath) {
        for each in collectionView.visibleCells {
            if each == collectionView.cellForItem(at: indexPath) {
                if isDisney {
                  self.changeBorderColorOfCell(each, toColor: UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0))
                } else {
                self.changeBorderColorOfCell(each, toColor:  UIColor(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1))
                }
            } else {
                self.changeBorderColorOfCell(each, toColor:  UIColor(red: 1, green: 1, blue: 1, alpha: 0))
            }
        }
    }
    
    func changeBorderColorOfCell(_ cell: UICollectionViewCell, toColor: UIColor) {
        cell.layer.borderWidth = 2.0
//        if isDisney {
//            cell.layer.borderColor = UIColor(red: 15.0/255.0, green: 112.0/255.0, blue: 215.0/255.0, alpha: 1.0).cgColor
//        } else {
            cell.layer.borderColor = toColor.cgColor
//        }
        cell.layer.cornerRadius = 15.0
    }
    
    //Get Month Enum
    func getMonthEnum(_ text: String) -> Month? {
        let intOfMonth = Int(text)
        let enumOfMonth = Month(rawValue: intOfMonth ?? 0)
        return enumOfMonth
    }

}
