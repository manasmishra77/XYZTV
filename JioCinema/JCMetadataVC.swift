
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
    
    var modelForPresentedVC: Item? // Used when a VC is presented on the TabVc
    var presentingVcTypeForArtist: VCTypeForArtist?
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
        if isMetaDataAvailable {
            showMetadata()
            let headerView = prepareHeaderView()
            metadataTableView.tableHeaderView = headerView
            metadataTableView.reloadData()
            changeAddWatchlistButtonStatus(itemId, itemAppType)
        } else {
            callWebServiceForMetadata(id: itemId, newAppType: itemAppType)
        }
        configureViews()
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
            headerCell.addToWatchListButton.focusedBGColor = ViewColor.disneyButtonColor
            headerCell.playButton.focusedBGColor = ViewColor.disneyButtonColor
            metadataTableView.backgroundColor = ViewColor.disneyBackground//UIColor(red: 6.0/255.0, green: 33.0/255.0, blue: 63.0/255.0, alpha: 1.0)
            headerCell.backgroudImage.image = UIImage.init(named: "DisneyMetadataBg")
            self.view.backgroundColor =  ViewColor.disneyBackground//UIColor(red: 6.0/255.0, green: 33.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }
    private func configureHeaderCell() {
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCSeasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: seasonCollectionViewCellIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCYearCell", bundle: nil), forCellWithReuseIdentifier: yearCellIdentifier)
        headerCell.monthsCollectionView.register(UINib.init(nibName:"JCMonthCell", bundle: nil), forCellWithReuseIdentifier: monthCellIdentifier)
        //headerCell.addToWatchListButton.isEnabled = false
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
                    metatableView.contentOffset = CGPoint(x: 0, y: 0)
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
        if presentingVcTypeForArtist != nil, isMetaDataAvailable, presentingVcTypeForArtist != .languageGenre {
            isDisney = true
        }
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
                    self.changeBorderColorOfCell(cell, toColor: ViewColor.disneyButtonColor)
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
            let font = UIFont(name: "JioType-Light", size: 32)!
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
            let font = UIFont(name: "JioType-Light", size: 32)!
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
        var json: [String: Any] = ["id": metadata?.contentId ?? itemId]
        var listId = ""
        if isDisney {
            if itemAppType == .TVShow {
                listId = "33"
            } else if itemAppType == .Movie {
                listId = "32"
            }
        } else {
            if itemAppType == .TVShow {
                listId = "13"
            } else if itemAppType == .Movie {
                listId = "12"
            }
        }
        
        if let audioLanguage: AudioLanguage = defaultAudioLanguage {
            let languageIndexDict: Dictionary<String, Any> = ["name": audioLanguage.name, "code": audioLanguage.code, "index": 0]
            json["languageIndex"] = languageIndexDict
        }
        params = ["uniqueId": JCAppUser.shared.unique, "listId": listId ,"json": json]
        
        if JCLoginManager.sharedInstance.isUserLoggedIn() {
            let url = isStatusAdd ? addToResumeWatchlistUrl : removeFromWatchListUrl
            
            callWebServiceToUpdateWatchlist(withUrl: url, watchlistStatus: isStatusAdd, andParameters: params)
        } else {
            presentLoginVC(fromAddToWatchList: true, fromItemCell: false)
        }
    }
    
    func callWebServiceToUpdateWatchlist(withUrl url: String, watchlistStatus: Bool, andParameters params: [String: Any]) {
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
            if let tabVC = navVc.viewControllers[0] as? SideNavigationVC {
                let isMovie = self.itemAppType == VideoType.Movie
                if isDisney {
                    if let vc = tabVC.sideNavigationView?.itemsList[4].viewControllerObject as? BaseViewController{
                        let basseVCType: BaseVCType = isMovie ? BaseVCType.disneyMovies : BaseVCType.disneyTVShow
                        vc.baseViewModel.getUpdatedWatchListFor(vcType: basseVCType)
                        if let presentedVC = vc.presentedViewController as? BaseViewController {
                            presentedVC.baseViewModel.changeWatchListUpdatedVariableSatus(true)
                        }
                    }
                    //                    if let vc = tabVC.viewControllers?[4] as? BaseViewController {
                    //                        let basseVCType: BaseVCType = isMovie ? BaseVCType.disneyMovies : BaseVCType.disneyTVShow
                    //                        vc.baseViewModel.getUpdatedWatchListFor(vcType: basseVCType)
                    //                        if let presentedVC = vc.presentedViewController as? BaseViewController {
                    //                            presentedVC.baseViewModel.changeWatchListUpdatedVariableSatus(true)
                    //                        }
                    //                    }
                } else {
                    if isMovie {
                        if let vc = tabVC.sideNavigationView?.itemsList[2].viewControllerObject as? BaseViewController {
                            vc.baseViewModel.getUpdatedWatchListFor(vcType: .movie)
                        }
                    } else {
                        if let vc = tabVC.sideNavigationView?.itemsList[3].viewControllerObject  as? BaseViewController {
                            vc.baseViewModel.getUpdatedWatchListFor(vcType: .tv)
                        }
                    }
                }
            }
        }
        
    }
    func appendMaturityRating() {
        headerCell.maturityRating.layer.borderWidth = 2
        headerCell.maturityRating.borderColor = .white
        headerCell.maturityRating.layer.cornerRadius = 5
        headerCell.maturityRating.textColor = .white
        if var maturityRating = metadata?.maturityRating {
            if  maturityRating.capitalized == "All"  {
                maturityRating = " 3+ "
            }
            else if maturityRating == "" {
                maturityRating = " NR "
            }
            headerCell.maturityRating.text = " \(maturityRating) "
        } else {
            headerCell.maturityRating.text = " NR "
        }

    }
    //prepare metadata view
    func prepareMetadataView() -> UIView {
        headerCell.frame.size.width = metadataContainerView.frame.size.width
        headerCell.frame.size.height = getHeaderContainerHeight()
        headerCell.titleLabel.text = metadata?.name
        headerCell.starringLabel.text = metadata?.artist?.joined(separator: ",")
        headerCell.subtitleLabel.text = metadata?.newSubtitle?.appending(" |")
        if metadata?.multipleAudio != nil {
            headerCell.subtitleLabel.text = metadata?.subtitle?.appending(" |")
        }
        appendMaturityRating()
        headerCell.directorLabel.text = metadata?.directors?.joined(separator: ",")
        if let audio = metadata?.multipleAudio {
            headerCell.multiAudioLanguge.text = audio
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
            self.headerCell.bannerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ItemPlaceHolder"), options: SDWebImageOptions.fromCacheOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in})
        }
        //self.applyGradient(self.headerCell.bannerImageView)
        myPreferredFocusView = headerCell.playButton
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        //Static labels height
        if metadata?.directors?.count == 0 || metadata?.directors == nil{
            headerCell.heightOFDirectorStatic.constant = 0
            headerCell.directorLabel.text = ""
        } else {
            headerCell.heightOFDirectorStatic.constant = 38
        }
        if metadata?.artist?.count == 0 || metadata?.artist == nil{
            headerCell.heightOfStarringStatic.constant = 0
            headerCell.starringLabel.text = ""
        } else {
            headerCell.heightOfStarringStatic.constant = 38
        }
        if metadata?.multipleAudio == "" || metadata?.multipleAudio == nil{
            headerCell.heightOfAudioStatic.constant = 0
            headerCell.multiAudioLanguge.text = ""
        } else {
            headerCell.heightOfAudioStatic.constant = 38
        }
        if itemAppType == .Movie, metadata != nil {
            return headerCell
        } else if itemAppType == VideoType.TVShow, metadata != nil {
            headerCell.titleLabel.text = metadata?.name
            if metadata?.multipleAudio != nil {
                headerCell.tvShowSubtitleLabel.text = metadata?.subtitle?.appending(" |")
            } else {
                headerCell.tvShowSubtitleLabel.text = "\(metadata?.newSubtitle?.capitalized ?? "") |"
            }
            headerCell.tvShowSubtitleLabel.isHidden = false
            headerCell.subtitleLabel.isHidden = true
            headerCell.directorLabel.isHidden = true
            headerCell.directorStaticLabel.isHidden = true
            //            headerCell.sseparationBetweenDirectorStaticAndDescView.constant -= headerCell.directorStaticLabel.frame.height + 8
            headerCell.frame.size.height -= headerCell.directorStaticLabel.frame.height + 8
            
            if (metadata?.isSeason) != nil {
                if (metadata?.isSeason)! {
                    headerCell.seasonsLabel.isHidden = false
                    headerCell.seasonCollectionView.isHidden = false
                    headerCell.monthsCollectionView.isHidden = true
                    headerCell.seasonsLabel.isHidden = true
//                    headerCell.sseparationBetweenSeasonLabelAndSeasonCollView.constant = 0
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
    
    private func getSearchController() -> SearchNavigationController{
        let searchViewController = Utility.sharedInstance.prepareSearchViewController(searchText: "")
        let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        searchContainerController.view.backgroundColor = UIColor.black
        return SearchNavigationController(rootViewController: searchContainerController)
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
        else if let tappedItem = item as? String {
            print("In Artist")
            //present search from here

            //Google Analytics for Artist Click
            let customParams: [String:String] = ["Client Id": UserDefaults.standard.string(forKey: "cid") ?? "" ]
            JCAnalyticsManager.sharedInstance.event(category: PLAYER_OPTIONS, action: "Artist Click", label: metadata?.name, customParameters: customParams)


//            if let superNav = (((self.presentingViewController as? UINavigationController)?.presentingViewController as? UINavigationController)?.viewControllers[0] as? SideNavigationVC)?.sideNavigationView?.itemsList[0].viewControllerObject


            if let searchNavController = self.presentingViewController as? SearchNavigationController {
                searchNavController.jCSearchVC?.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 4, metaData: metadata ?? false, baseVCModel: nil, vcTypeForMetadata: presentingVcTypeForArtist)
                self.dismiss(animated: false) {

                }
            }
            else {
                let searchNavController = self.getSearchController()
                searchNavController.jCSearchVC?.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 4, metaData: metadata ?? false, baseVCModel: nil, vcTypeForMetadata: presentingVcTypeForArtist)
                self.present(searchNavController, animated: false) {

                }
            }

            return

//            (self.presentingViewController as? SearchNavigationController)?.jCSearchVC?.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 4, metaData: metadata ?? false, baseVCModel: nil, vcTypeForMetadata: presentingVcTypeForArtist)
            //searchResultForkey(with: tappedItem)



//            (self.presentingViewController as? SearchNavigationController)?.jCSearchVC?.dismiss(animated: false) {
//
//            }



//            if let superNav = self.presentingViewController as? UINavigationController, let tabController = superNav.viewControllers[0] as? JCTabBarController {
//                if (presentingVcTypeForArtist == .disneyMovie) || (presentingVcTypeForArtist == .disneyTV) || (presentingVcTypeForArtist == .disneyKids) {
//                    if let searchVcNav = tabController.selectedViewController as? UINavigationController {
//                        if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController {
//                            if let searchVc = sc.searchController.searchResultsController as? JCSearchResultViewController {
//                                searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 4, metaData: metadata ?? false, baseVCModel: nil, vcTypeForMetadata: presentingVcTypeForArtist)
//                            }
//                        }
//                    }
//                    self.dismiss(animated: false, completion: nil)
//                    return
//                } else if presentingVcTypeForArtist == .languageGenre {
//                    if let searchVcNav = tabController.selectedViewController as? UINavigationController {
//                        if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController {
//                            if let searchVc = sc.searchController.searchResultsController as? JCSearchResultViewController {
//                                searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 0, metaData: metadata ?? false, languageModel: modelForPresentedVC, vcTypeForMetadata: .languageGenre)
//                            }
//                        }
//                    }
//                    self.dismiss(animated: false, completion: nil)
//                    return
//                }
//                if isDisney {
//                    var metaDataTabBarIndex = tabController.selectedIndex
//                    if let index = tabBarIndex {
//                        metaDataTabBarIndex = index
//                    }
//                    tabController.selectedIndex = 5
//                    if let searchVcNav = tabController.selectedViewController as? UINavigationController {
//                        if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController {
//                            if let searchVc = sc.searchController.searchResultsController as? JCSearchResultViewController {
//                                searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: metaDataTabBarIndex, metaData: metadata ?? false, vcTypeForMetadata: .disneyHome)
//                            }
//                        }
//                    }
//                } else {
//                    var metaDataTabBarIndex = tabController.selectedIndex
//                    if let index = tabBarIndex {
//                        metaDataTabBarIndex = index
//                    }
//                    tabController.selectedIndex = 5
//                    if let searchVcNav = tabController.selectedViewController as? UINavigationController {
//                        if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController {
//                            if let searchVc = sc.searchController.searchResultsController as? JCSearchResultViewController {
//                                searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: metaDataTabBarIndex, metaData: metadata ?? false, vcTypeForMetadata: nil)
//                            }
//                        }
//                    }
//                }
//                self.dismiss(animated: true, completion: nil)

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
//        let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: itemToBePlayed.id ?? "",latestId: nil , isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: metadata?.episodes ?? false, fromScreen: METADATA_SCREEN, fromCategory: MORELIKE, fromCategoryIndex: 0, fromLanguage: item?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor, isDisney: isDisney, audioLanguage: defaultAudioLanguage)
        let playerVC = Utility.sharedInstance.prepareCustomPlayerVC(item: itemToBePlayed.getItem, latestEpisodeId: nil)
        self.present(playerVC, animated: false, completion: nil)
//        Utility.sharedInstance.prepareAndPresentCustomPlayerVC(itemId: itemToBePlayed, toBepresentedOnScreen: self, audio: metadata?.multipleAudio, subtitles: metadata?.subtitles)
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
        if itemAppType == .Movie {
            var isMoreDataAvailable = false
            var recommendationArray: Any = false
            if let moreArray = metadata?.more, moreArray.count > 0{
                isMoreDataAvailable = true
                recommendationArray = moreArray
            }
            
//            let playerVC = Utility.sharedInstance.preparePlayerVC(itemId, itemImageString: (metadata?.banner) ?? "", itemTitle: (metadata?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (metadata?.description) ?? "", appType: .Movie, isPlayList: false, playListId: "",latestId: nil, isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: recommendationArray ,fromScreen: fromScreen ?? METADATA_SCREEN, fromCategory: categoryName ?? WATCH_NOW_BUTTON, fromCategoryIndex: categoryIndex ?? 0, fromLanguage: metadata?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor, isDisney: isDisney, audioLanguage: defaultAudioLanguage)
//            self.present(playerVC, animated: false, completion: nil)

//            let playerVC = PlayerViewController.init(item: self.item!, subtitles: self.metadata?.subtitles, audios: self.metadata?.multipleAudio)
//            if let moreArray = metadata?.more, moreArray.count > 0{
//                playerVC.viewforplayer?.moreLikeView?.moreArray = moreArray
//            }
            if let item = item{
                let playerVC = Utility.sharedInstance.prepareCustomPlayerVC(item: item,recommendationArray: recommendationArray)
                self.present(playerVC, animated: true, completion: nil)
            }
            
        } else if itemAppType == .TVShow {
            var isEpisodeAvailable = false
            var recommendationArray: Any = false
            if let episodes = metadata?.episodes, episodes.count > 0{
                isEpisodeAvailable = true
                recommendationArray = episodes
            }
            guard let itemToPlay = item else {
                return
            }
            let playerVC = Utility.sharedInstance.prepareCustomPlayerVC(item: itemToPlay, recommendationArray: recommendationArray, latestEpisodeId: (metadata?.latestEpisodeId) ?? "")
            self.present(playerVC, animated: false, completion: nil)
//            let playerVC = Utility.sharedInstance.preparePlayerVC((metadata?.latestEpisodeId) ?? "", itemImageString: (item?.banner) ?? "", itemTitle: (item?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: (metadata?.latestEpisodeId) ?? "",latestId: nil, isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: recommendationArray, fromScreen: fromScreen ?? METADATA_SCREEN, fromCategory: categoryName ?? WATCH_NOW_BUTTON, fromCategoryIndex: categoryIndex ?? 0, fromLanguage: metadata?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor, isDisney: isDisney, audioLanguage: defaultAudioLanguage)
//            self.present(playerVC, animated: false, completion: nil)
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if  presses.first?.type == .menu, shouldUseTabBarIndex, (tabBarIndex != nil) {
            if let superNav = self.presentingViewController as? UINavigationController{
                if let vcType = presentingVcTypeForArtist {
                    switch vcType {
                    case .languageGenre:
                        if let modelForPresentedVC = modelForPresentedVC {
                            let vc = self.presentLanguageGenreController(item: modelForPresentedVC)
                            self.dismiss(animated: false, completion: {
                                superNav.present(vc, animated: false, completion: nil)
                            })
                        }
                    default:
                        if let vc = presentDinseyController(vCTypeForArtist: vcType) {
                            self.dismiss(animated: false) {
                                superNav.present(vc, animated: false, completion: nil)
                            }
                        }
                    }
                }
            }
//            else if let superNav = self.presentingViewController?.presentingViewController as? UINavigationController, let tabc = superNav.viewControllers[0] as? SideNavigationVC {
////                tabc.selectedIndex = tabBarIndex ?? 0
//            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
        }
    }
    func presentLanguageGenreController(item: Item) -> JCLanguageGenreVC {
        toScreenName = LANGUAGE_SCREEN
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
        return languageGenreVC
    }
    func presentDinseyController(vCTypeForArtist: VCTypeForArtist) -> BaseViewController<BaseViewModel>? {
        // toScreenName = LANGUAGE_SCREEN
        switch vCTypeForArtist {
        case .disneyTV:
            let vc = BaseViewController<BaseViewModel>(.disneyTVShow)
            return vc
        case .disneyMovie:
            let vc = BaseViewController<BaseViewModel>(.disneyMovies)
            return vc
        case .disneyKids:
            let vc = BaseViewController<BaseViewModel>(.disneyKids)
            return vc
        default:
            break
        }
        return nil
    }
    
    
    //DescriptionContainerview size fixing
    func getSizeofDescriptionContainerView(_ text: String, widthOfView: CGFloat, font: UIFont, inset :UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)) -> CGFloat {
//        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        if text == ""{
            return 0
        } else {
        let heightOfTheString = text.heightForWithFont(font: font, width: widthOfView, insets: inset)
        return heightOfTheString
        }
    }
    
    //Trim description text
    func getShorterText(_ text: String) -> (Bool, NSAttributedString) {
        if text.count > 125 {
            let trimText = text.subString(start: 0, end: 100) + "... " + SHOW_MORE
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
        if isDisney {
            colorToChange = ViewColor.disneyButtonColor
        }
        let fontChangedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont(name: "JioType-Light", size: 32.0)!])
        fontChangedText.addAttribute(NSAttributedString.Key.foregroundColor, value:  UIColor(red: 1, green: 1, blue: 1, alpha: 1), range: NSRange(location: 0, length: text.count))
        if colorChange {
            fontChangedText.addAttribute(NSAttributedString.Key.foregroundColor, value:  colorToChange, range: NSRange(location: text.count - range, length: range))
            fontChangedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "JioType-Medium", size: 30.0)!, range: NSRange(location: text.count - range, length: range))
        }
        
        return fontChangedText
    }
    
    //Height of the table header container
    func getHeaderContainerHeight() -> CGFloat {
        var heightConstant : CGFloat = 0.0
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let newTitleHight = metadata?.name?.heightForWithFont(font: headerCell.titleLabel.font, width: (headerCell.titleLabel.frame.width), insets: inset) ?? 0
            heightConstant = newTitleHight
        
        let newAudioHight = metadata?.multipleAudio?.heightForWithFont(font: headerCell.multiAudioLanguge.font, width: headerCell.multiAudioLanguge.frame.width, insets: inset)
        heightConstant += newAudioHight ?? 0
        
        let newStaringHight = metadata?.artist?.joined(separator: ", ").heightForWithFont(font: headerCell.starringLabel.font, width: headerCell.starringLabel.frame.width, insets: inset)
            heightConstant += newStaringHight ?? 0
        
        let newDirectorHight = metadata?.directors?.joined(separator: ", ").heightForWithFont(font: headerCell.directorLabel.font, width: headerCell.directorLabel.frame.width, insets: inset)
            heightConstant += newDirectorHight ?? 0

        switch itemAppType {
        case .Movie:
            //To be changed to dynamic one
            return 555 + heightConstant + 96
        case .TVShow:
            //To be changed to dynamic one
            if metadata?.isSeason ?? false {
                let heightOfView = 808 + heightConstant //780 + 50 + heightConstant
                return CGFloat(heightOfView)
            }
            return 940 + heightConstant
        default:
            return 0
        }
    }
    
    //Changing collectionview border color(month, season collection view)
    func changeCollectionViewCellStyle(_ collectionView: UICollectionView, indexPath: IndexPath) {
        for each in collectionView.visibleCells {
            if each == collectionView.cellForItem(at: indexPath) {
                if isDisney {
                    self.changeBorderColorOfCell(each, toColor: ViewColor.disneyButtonColor)
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
        cell.layer.borderColor = toColor.cgColor
        cell.layer.cornerRadius = 3.0
    }
    
    //Get Month Enum
    func getMonthEnum(_ text: String) -> Month? {
        let intOfMonth = Int(text)
        let enumOfMonth = Month(rawValue: intOfMonth ?? 0)
        return enumOfMonth
    }
    
}


//Used when VC is presented on DisneyTVVC,disneyMovie, disneyKids, languageGenre
enum VCTypeForArtist {
    case languageGenre
    case disneyHome
    case home
    case disneyTV
    case disneyMovie
    case disneyKids
}
