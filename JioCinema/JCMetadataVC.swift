
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.metadataTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCSeasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: seasonCollectionViewCellIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCYearCell", bundle: nil), forCellWithReuseIdentifier: yearCellIdentifier)
        headerCell.monthsCollectionView.register(UINib.init(nibName:"JCMonthCell", bundle: nil), forCellWithReuseIdentifier: monthCellIdentifier)
        self.metadataTableView.tableFooterView = UIView()
        headerCell.addToWatchListButton.isEnabled = false
        headerCell.delegate = self
        loadingLabel.text = "Loading"
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
        let eventProperties = ["Screen Name": fromScreen, "Platform": "TVOS", "Metadata Page": metadataType] as [String : Any]
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
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
        
        cell.moreLikeData = nil
        cell.episodes = nil
        cell.data = nil
        cell.artistImages = nil
        cell.cellDelgate = self
        cell.tag = indexPath.row
        
        //Metadata for Movies
        if itemAppType == .Movie {
            if let moreArray = moreTableViewDatasource[indexPath.row] as? [More] {
                cell.categoryTitleLabel.text = metadata?.displayText
                cell.moreLikeData = moreArray
                cell.tableCellCollectionView.reloadData()
            }
            if let artistArray = moreTableViewDatasource[indexPath.row] as? [String] {
                cell.categoryTitleLabel.text = "Cast & Crew"
                let dict = getStarCastImagesUrl(artists: artistArray)
                cell.artistImages = dict
                cell.tableCellCollectionView.reloadData()
            }
        }
            
            // Metadata for TV
        else if itemAppType == .TVShow {
            if let episodeArray = moreTableViewDatasource[indexPath.row] as? [Episode] {
                cell.categoryTitleLabel.text = "Episodes"
                cell.episodes = episodeArray
                cell.tableCellCollectionView.reloadData()
            }
            if let artistArray = moreTableViewDatasource[indexPath.row] as? [String] {
                cell.categoryTitleLabel.text = "Cast & Crew"
                let dict = getStarCastImagesUrl(artists: artistArray)
                cell.artistImages = dict
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
        
        let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
            DispatchQueue.main.async {
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
        }
    }
    
    func callWebServiceForMoreLikeData(id: String) {
        if itemAppType == .TVShow {
            if metadata?.isSeason ?? false {
                fetchMoreDataForEpisode(seasonIndex: 0, isSeason: true, monthString: "", yearString: "")
            } else {
                if let _ = metadata?.filter?[selectedYearIndex].filter?.floatValue(), let yearString = metadata?.filter?[selectedYearIndex].filter, let monthString = metadata?.filter?[selectedYearIndex].month?[0] {
                    fetchMoreDataForEpisode(seasonIndex: 0, isSeason: false, monthString: monthString, yearString: yearString)
                }
                
            }
            return
        }
        
        let url = (itemAppType == VideoType.Movie) ? metadataUrl.appending(id) : metadataUrl.appending(id + "/0/0")
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
        }
    }
    
    
    
    
    func evaluateMoreLikeData(dictionaryResponseData responseData: Data) {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8) {
            let tempMetadata = MetadataModel(JSONString: responseString)
            print("\(tempMetadata?.episodes?.count) 1111")
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
    
    func evaluateMetaData(dictionaryResponseData responseData:Data) {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8) {
            let metaDataModel = MetadataModel(JSONString: responseString)
            self.metadata = metaDataModel
            self.metadata?.more = nil
            self.metadata?.episodes = nil
            print("\(metadata) + 123")
        }
    }
    
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
        //weak var weakSelf = self
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
    
    
    func getStarCastImagesUrl(artists: [String]) -> [String:String] {
        let modifiedArtists = artists.filter { (artistName) -> Bool in
            artistName != ""
        }
        var artistImages = [String:String]()
        for artist in modifiedArtists {
            let processedName = artist.replacingOccurrences(of: " ", with: "").lowercased()
            let encryptedData = convertStringToMD5Hash(artistName: processedName)
            let hexString = encryptedData.hexEncodedString()
            
            let index = hexString.index(hexString.startIndex, offsetBy: 8)
            
            let firstFolder =  hexString.substring(to: index)
            
            let start = hexString.index(hexString.startIndex, offsetBy: 8)
            let end = hexString.index(hexString.startIndex, offsetBy: 16)
            let range = start..<end
            let secondFolder = hexString.substring(with: range)
            
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
            if indexPath.row == 0 {
                self.changeBorderColorOfCell(cell, toColor:  UIColor(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1))
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
        if !Utility.sharedInstance.isNetworkAvailable
        {
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
            if let seasonNum = metadata?.filter?[seasonIndex].season {
                callWebServiceForSelectedFilter(filter: String(describing: seasonNum))
            }
            return
        }
        callWebServiceForSelectedFilter(filter: "\(yearString)/\(monthString)")
    }
    
    
    func callWebServiceForSelectedFilter(filter: String) {
        let url = metadataUrl.appending(metadata?.id ?? "").appending("/\(filter)")
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
                    weakSelf?.metadataTableView.reloadData()
                    weakSelf?.metadataTableView.layoutIfNeeded()
                    weakSelf?.setNeedsFocusUpdate()
                    weakSelf?.updateFocusIfNeeded()
                }
                return
            }
        }
    }
    
    func evaluateFilteredData(dictionaryResponseData responseData:Data) {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8) {
            let tempMetadata = MetadataModel(JSONString: responseString)
            self.metadata?.episodes = tempMetadata?.episodes
        }
    }
    
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
        var watchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?.items
        if appType == .Movie{
            watchListArray = JCDataStore.sharedDataStore.moviesWatchList?.data?.items
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
        if itemAppType == .TVShow {
            params = ["uniqueId": JCAppUser.shared.unique, "listId": "13" ,"json": ["id": metadata?.contentId ?? itemId]]
        } else if itemAppType == .Movie {
            params = ["uniqueId": JCAppUser.shared.unique,"listId": "12" ,"json": ["id": metadata?.contentId ?? itemId]]
        }
        
        if JCLoginManager.sharedInstance.isUserLoggedIn(){
            //let url = isStatusAdd ? removeFromWatchListUrl : addToResumeWatchlistUrl
            let url = isStatusAdd ? addToResumeWatchlistUrl : removeFromWatchListUrl
            callWebServiceToUpdateWatchlist(withUrl: url, watchlistStatus: isStatusAdd, andParameters: params)
        } else {
            presentLoginVC(fromAddToWatchList: true, fromItemCell: false)
        }
    }
    
    func callWebServiceToUpdateWatchlist(withUrl url:String, watchlistStatus: Bool, andParameters params: Dictionary<String, Any>) {
        self.headerCell.addToWatchListButton.isEnabled = false
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
        }
        
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
    
    //prepare metadata view
    func prepareMetadataView() -> UIView {
        headerCell.frame.size.width = metadataContainerView.frame.size.width
        headerCell.frame.size.height = getHeaderContainerHeight()
        headerCell.titleLabel.text = metadata?.name
        headerCell.subtitleLabel.text = metadata?.newSubtitle
        headerCell.directorLabel.text = metadata?.directors?.joined(separator: ",")
        
        var descText = "" //(metadata?.description ?? "") + " " + SHOW_LESS
        if itemAppType == .TVShow {
            descText = (metadata?.descriptionForTVShow ?? "") + " " + SHOW_LESS
        } else {
            descText = (metadata?.description ?? "") + " " + SHOW_LESS
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
        self.applyGradient(self.headerCell.bannerImageView)
        myPreferredFocusView = headerCell.playButton
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
        if itemAppType == .Movie, metadata != nil {
            return headerCell
        } else if itemAppType == VideoType.TVShow, metadata != nil {
            headerCell.titleLabel.text = metadata?.name
            headerCell.imdbImageLogo.isHidden = true
            headerCell.ratingLabel.isHidden = true
            headerCell.tvShowLabel.text = metadata?.newSubtitle?.capitalized
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
        if let tappedItem = item as? More {
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
                        if let searchVc = sc.searchController.searchResultsController as? JCSearchVC {
                            searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: metaDataTabBarIndex, metaData: metadata)
                        }
                    }
                }
                self.dismiss(animated: true, completion: nil)
            } else if let superNav = self.presentingViewController?.presentingViewController as? UINavigationController, let tabController = superNav.viewControllers[0] as? JCTabBarController {
                tabController.selectedIndex = 5
                if let searchVcNav = tabController.selectedViewController as? UINavigationController {
                    if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController {
                        if let searchVc = sc.searchController.searchResultsController as? JCSearchVC {
                            searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen ?? "", metaDataCategoryName: categoryName ?? "", metaDataCategoryIndex: categoryIndex ?? 0, metaDataTabBarIndex: 0, metaData: metadata, languageModel: languageModel)
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
        
        let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: itemToBePlayed.id ?? "", isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: metadata?.episodes, fromScreen: METADATA_SCREEN, fromCategory: MORELIKE, fromCategoryIndex: 0, fromLanguage: item?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor)
        self.present(playerVC, animated: true, completion: nil)
    }
    
    func convertingMoreToItem(_ moreItem: More, currentItem: Item) -> Item {
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
        
        return tempItem
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
            
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemId, itemImageString: (metadata?.banner) ?? "", itemTitle: (metadata?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (metadata?.description) ?? "", appType: .Movie, isPlayList: false, playListId: "", isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: recommendationArray ,fromScreen: fromScreen ?? METADATA_SCREEN, fromCategory: categoryName ?? WATCH_NOW_BUTTON, fromCategoryIndex: categoryIndex ?? 0, fromLanguage: metadata?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor)
            
            self.present(playerVC, animated: true, completion: nil)
        }
        else if itemAppType == .TVShow {
            var isEpisodeAvailable = false
            var recommendationArray: Any = false
            if let episodes = metadata?.episodes, episodes.count > 0{
                isEpisodeAvailable = true
                recommendationArray = episodes
            }
            let playerVC = Utility.sharedInstance.preparePlayerVC((metadata?.latestEpisodeId) ?? "", itemImageString: (item?.banner) ?? "", itemTitle: (item?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: (metadata?.latestEpisodeId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: recommendationArray, fromScreen: fromScreen ?? METADATA_SCREEN, fromCategory: categoryName ?? WATCH_NOW_BUTTON, fromCategoryIndex: categoryIndex ?? 0, fromLanguage: metadata?.language ?? "", director: directors, starCast: artists, vendor: metadata?.vendor)
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
            self.dismiss(animated: true, completion: nil)
        }
    }
    func presentLanguageGenreController(item: Item) -> JCLanguageGenreVC {
        toScreenName = LANGUAGE_SCREEN
        let languageGenreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: languageGenreStoryBoardId) as! JCLanguageGenreVC
        languageGenreVC.item = item
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
            let newerText = text.dropLast(SHOW_LESS.count)
            let fontChangedText = getAttributedString(String(newerText), colorChange: false, range: 0)
            return (false, fontChangedText)
        }
    }
    
    func getAttributedString (_ text: String, colorChange: Bool, range:Int) -> NSMutableAttributedString {
        let fontChangedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 28.0)!])
        fontChangedText.addAttribute(NSForegroundColorAttributeName, value:  UIColor(red: 1, green: 1, blue: 1, alpha: 1), range: NSRange(location: 0, length: text.count))
        if colorChange {
            fontChangedText.addAttribute(NSForegroundColorAttributeName, value:  UIColor(red: 0.9059922099, green: 0.1742313504, blue: 0.6031312346, alpha: 1), range: NSRange(location: text.count - range, length: range))
            fontChangedText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 22.0)!, range: NSRange(location: text.count - range, length: range))
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
                let heightOfView = 750
                return CGFloat(heightOfView)
            }
            return 880
        default:
            return 0
        }
    }
    
    //Changing collectionview border color(month, season collection view)
    func changeCollectionViewCellStyle(_ collectionView: UICollectionView, indexPath: IndexPath) {
        for each in collectionView.visibleCells {
            if each == collectionView.cellForItem(at: indexPath) {
                self.changeBorderColorOfCell(each, toColor:  UIColor(red: 0.9058823529, green: 0.1725490196, blue: 0.6039215686, alpha: 1))
            } else {
                self.changeBorderColorOfCell(each, toColor:  UIColor(red: 1, green: 1, blue: 1, alpha: 0))
            }
        }
    }
    
    func changeBorderColorOfCell(_ cell: UICollectionViewCell, toColor: UIColor) {
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = toColor.cgColor
        cell.layer.cornerRadius = 15.0
    }
    
    //Get Month Enum
    func getMonthEnum(_ text: String) -> Month? {
        let intOfMonth = Int(text)
        let enumOfMonth = Month(rawValue: intOfMonth ?? 0)
        return enumOfMonth
    }
    
    //MARK: Apply Gradient
    func applyGradient(_ view: UIView) {
        let initalColor = #colorLiteral(red: 0.1068576351, green: 0.1179018542, blue: 0.1013216153, alpha: 1).cgColor
        let finalColor = UIColor.clear.cgColor
        
         let colors = [initalColor, finalColor, finalColor, finalColor]
         
         let layer = CAGradientLayer()
         layer.colors = colors
         layer.frame = view.bounds
         layer.startPoint = CGPoint(x: 0, y: 0)
         layer.endPoint = CGPoint(x: 1, y: 0) //: CGPoint(x: 1, y: 0)
        
         view.layer.insertSublayer(layer, at: 0)
        
         let layer2 = CAGradientLayer()
         layer2.colors = colors
         layer2.frame = view.bounds
         layer2.startPoint = CGPoint(x: 0, y: 1)
         layer2.endPoint = CGPoint(x: 0, y: 0)
         view.layer.insertSublayer(layer2, at: 0)

    }
    
}
