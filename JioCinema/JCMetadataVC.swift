
//
//  JCMetadataVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class JCMetadataVC: UIViewController,UITableViewDelegate,UITableViewDataSource, MetadataHeaderCellDelegate, JCBaseTableViewCellDelegate
{
    
    var item:Item?
    var metadata: MetadataModel?
    var selectedYearIndex = 0
    var userComingAfterLogin: Bool = false
    let headerCell = Bundle.main.loadNibNamed("kMetadataHeaderView", owner: self, options: nil)?.last as! MetadataHeaderView
    var presentingScreen = ""
    
    //New metadata model
    var itemId = ""
    var itemAppType = VideoType.Movie
    var categoryName = ""
    var categoryIndex = 0
    var fromScreen = ""
    var tabBarIndex: Int? = nil
    var shouldUseTabBarIndex = false
    var isMetaDataAvailable = false
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var metaDataHeaderContainer: UIView!
    @IBOutlet weak var metaDataHeaderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var metadataTableHeight: NSLayoutConstraint!
    @IBOutlet weak var metadataTableView: UITableView!
    @IBOutlet weak var metadataContainerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loaderContainerView: UIView!
  //  @IBOutlet weak var backgroundImageView: UIImageView!
    var headerView:UIView?
    
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
        if isMetaDataAvailable{
            showMetadata()
            metadataTableView.reloadData()
            
        }else{
             callWebServiceForMetadata(id: itemId, newAppType: itemAppType)
        }
       
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {        
        //Clevertap Navigation Event
        let metadataType = itemAppType.rawValue
        let eventProperties = ["Screen Name": fromScreen, "Platform": "TVOS", "Metadata Page": metadataType] as [String : Any]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if metadata != nil, metadata?.app?.type == VideoType.Movie.rawValue
        {
            return 2
        }
        else if metadata?.episodes != nil , metadata?.app?.type == VideoType.TVShow.rawValue
        {
            return 2
        }
        else
        {
            return 0
        }
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
        
        //Metadata for Movies
        
        if itemAppType == VideoType.Movie
        {
            if indexPath.row == 0
            {
                cell.categoryTitleLabel.text = metadata?.displayText
                cell.moreLikeData = metadata?.more
                cell.tableCellCollectionView.reloadData()
            }
            else if indexPath.row == 1
            {
                cell.categoryTitleLabel.text = "Cast & Crew"
                let dict = getStarCastImagesUrl(artists: (metadata?.artist)!)
                cell.artistImages = dict
                cell.tableCellCollectionView.reloadData()
            }
        }
            
        // Metadata for TV
        else if itemAppType == VideoType.TVShow
        {
            if indexPath.row == 0
            {
                cell.categoryTitleLabel.text = "Latest Episodes"
                cell.episodes = metadata?.episodes
                cell.tableCellCollectionView.reloadData()
            }

            if indexPath.row == 1
            {
                if let artists = metadata?.artist
                {
                let dict = getStarCastImagesUrl(artists: artists)
                cell.categoryTitleLabel.text = (dict.count != 0) ? "Cast & Crew" : ""
                cell.artistImages = dict
                cell.tableCellCollectionView.reloadData()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.clear
    }
    
    func prepareHeaderView() -> UIView
    {
        //headerCell.item = item
        headerCell.seasonCollectionView.delegate = self
        headerCell.seasonCollectionView.dataSource = self
        headerCell.monthsCollectionView.delegate = self
        headerCell.monthsCollectionView.dataSource = self
        return self.prepareMetadataView()
    }
    
    func resetHeaderView() -> UIView
    {
        return headerCell.resetView()
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func callToReloadWatchListStatusWhenJustLoggedIn(){
        self.changeAddWatchlistButtonStatus(itemId, itemAppType)
        
    }
    
    func callWebServiceForMetadata(id: String, newAppType: VideoType)
    {
        self.itemId = id
        self.itemAppType = newAppType
        
        self.changeAddWatchlistButtonStatus(id, newAppType)
        
       
        let url = metadataUrl.appending(id.replacingOccurrences(of: "/0/0", with: ""))
        let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMetaData(dictionaryResponseData: responseData)
                DispatchQueue.main.async {
                    weakSelf?.showMetadata()
                }
                weakSelf?.callWebServiceForMoreLikeData(id: id)
                return
            }
        }
    }
    
 
    func callWebServiceForMoreLikeData(id:String)
    {
        let url = (itemAppType == VideoType.Movie) ? metadataUrl.appending(id) :metadataUrl.appending(id + "/0/0")
        let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMoreLikeData(dictionaryResponseData: responseData)
                //let data1 = self.metadata?.episodes
                DispatchQueue.main.async {
                    weakSelf?.metadataTableView.reloadData()
                }
            }
        }
    }
    /*
    func callWebserviceForWatchListStatus(id:String)
    {
        let urlId = (metadata?.app?.type)! == VideoType.Movie.rawValue ? id : (self.metadata?.latestEpisodeId)! + "/" + id
        let showId: String = (metadata?.app?.type)! == VideoType.Movie.rawValue ? "" : id
        let url = playbackRightsURL.appending(urlId)
        let params = ["id" : (metadata?.app?.type)! == VideoType.Movie.rawValue ? id : (self.metadata?.latestEpisodeId)!,"showId" : showId, "uniqueId" : JCAppUser.shared.unique, "deviceType" : "stb"]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
              
                return
            }
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    let playbackRightsData = PlaybackRightsModel(JSONString: responseString)
                    
                    DispatchQueue.main.async {
                        weakSelf?.metadata?.inQueue = playbackRightsData?.inqueue
                        if weakSelf?.metadata?.inQueue != nil{
                            if (weakSelf?.metadata?.inQueue)!{
                                weakSelf?.headerCell.watchlistLabel.text = REMOVE_FROM_WATCHLIST
                            }
                            else{
                                weakSelf?.headerCell.watchlistLabel.text = ADD_TO_WATCHLIST
                            }
                        }
                        else{
                            weakSelf?.headerCell.watchlistLabel.text = ADD_TO_WATCHLIST
                        }
                    }
                }
            }
        }
    }
 */
    
    func evaluateMoreLikeData(dictionaryResponseData responseData:Data)
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            let tempMetadata = MetadataModel(JSONString: responseString)
            print("\(tempMetadata?.episodes?.count) 1111")
            if itemAppType == VideoType.Movie
            {
                self.metadata?.more = tempMetadata?.more
            }
            else if itemAppType == VideoType.TVShow
            {
                self.metadata?.episodes = tempMetadata?.episodes
                self.metadata?.artist = tempMetadata?.artist
            }
            self.metadata?.displayText = tempMetadata?.displayText
        }
    }
    
    func evaluateMetaData(dictionaryResponseData responseData:Data)
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            self.metadata = MetadataModel(JSONString: responseString)
            print("\(metadata) + 123")
        }
    }
    
    func prepareMetadataScreen()
    {
        weak var weakSelf = self
        
            DispatchQueue.main.async {
                //weakSelf?.showMetadata()
                weakSelf?.metadataTableView.reloadData()
            }
    }
    
    func showMetadata()
    {
        loaderContainerView.isHidden = true
        metadataContainerView.isHidden = false
        if headerView != nil
        {
            headerView = resetHeaderView()
        }
        headerView = prepareHeaderView()
        metadataContainerView.addSubview(headerView!)
        if metadata?.type == VideoType.Movie.rawValue{
            //tableViewTopConstraint.constant = -175
        }
        
        headerCell.seasonCollectionView.reloadData()
        headerCell.monthsCollectionView.reloadData()
        if itemAppType == .Movie{
            metadataTableHeight.constant = metadataTableHeight.constant + 100
        }
    }

    func presentLoginVC()
    {
        let loginVC = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: true, presentingVC: self)
        self.present(loginVC, animated: true, completion: nil)
    }

    //For after login function
    fileprivate var itemAfterLogin: Episode? = nil
    fileprivate var categoryIndexAfterLogin: Int? = nil
    fileprivate var categoryNameAfterLogin: String? = nil
    
    func checkLoginAndPlay(_ itemToBePlayed: Episode, categoryName: String, categoryIndex: Int) {
        //weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            prepareToPlay(itemToBePlayed, categoryName: categoryName, categoryIndex: categoryIndex)
        }
        else
        {
            self.itemAfterLogin = itemToBePlayed
            self.categoryNameAfterLogin = categoryName
            self.categoryIndexAfterLogin = categoryIndex
            presentLoginVC()
        }
    }
    func playItemAfterLogin() {
        checkLoginAndPlay(itemAfterLogin!, categoryName: categoryNameAfterLogin!, categoryIndex: categoryIndexAfterLogin!)
        self.itemAfterLogin = nil
        self.categoryIndexAfterLogin = nil
        self.categoryNameAfterLogin = nil
    }
   
    
    func getStarCastImagesUrl(artists:[String]) -> [String:String]
    {
        var artistImages = [String:String]()
        for artist in artists
        {
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
    
    func convertStringToMD5Hash(artistName:String) -> Data
    {
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

extension JCMetadataVC:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if metadata?.app?.type == VideoType.TVShow.rawValue
        {
            if let season = metadata?.isSeason,season,collectionView == headerCell.seasonCollectionView     //seasons
            {
                return (metadata?.filter?.count) ?? 0
               
            }
            else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
            {
                return (metadata?.filter?.count) ?? 0
            }
            else if collectionView == headerCell.monthsCollectionView  //months, in case of episodes
            {
                if  (metadata?.filter?.count) ?? 0 > selectedYearIndex
               {
                    if let count = (metadata?.filter![selectedYearIndex].month?.count)
                    {
                        return count
                    }
                }
                else
                {
                    return 0
                }
            }
            else
            {
                return 0
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let season = metadata?.isSeason,season,collectionView == headerCell.seasonCollectionView     //seasons
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seasonCollectionViewCellIdentifier, for: indexPath) as! JCSeasonCollectionViewCell
            cell.seasonNumberLabel.text = String(describing: metadata?.filter?[indexPath.row].season)
            return cell
           
        }
        else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: yearCellIdentifier, for: indexPath) as! JCYearCell
            cell.yearLabel.text = metadata?.filter?[indexPath.row].filter ?? ""
            return cell
        }
        else if collectionView == headerCell.monthsCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCellIdentifier, for: indexPath) as! JCMonthCell
            var text = ""
            switch metadata?.filter?[selectedYearIndex].month?[indexPath.row] ?? ""
            {
            case "01":
                text = "Jan"
            case "02":
                text = "Feb"
            case "03":
                text = "Mar"
            case "04":
                text = "Apr"
            case "05":
                text = "May"
            case "06":
                text = "Jun"
            case "07":
                text = "Jul"
            case "08":
                text = "Aug"
            case "09":
                text = "Sep"
            case "10":
                text = "Oct"
            case "11":
                text = "Nov"
            case "12":
                text = "Dec"
            default:
                break
                
            }
            
            cell.monthLabel.text = text
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seasonCollectionViewCellIdentifier, for: indexPath) as! JCSeasonCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        if (metadata?.isSeason ?? false),collectionView == headerCell.seasonCollectionView     //seasons
        {
            let filter = String(describing: metadata?.filter?[indexPath.row].season)
            callWebServiceForSelectedFilter(filter: filter)
        }
        else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
        {
            selectedYearIndex = indexPath.row
            headerCell.monthsCollectionView.reloadData()
            let filter = String(describing: metadata?.filter?[selectedYearIndex].filter).appending("/\(String(describing: metadata?.filter?[selectedYearIndex].month?[0]))")
            callWebServiceForSelectedFilter(filter: filter)
        }
        else    //months
        {
            let filter = String(describing: metadata?.filter?[selectedYearIndex].filter).appending("/\(String(describing: metadata?.filter?[selectedYearIndex].month?[indexPath.row]))")
            callWebServiceForSelectedFilter(filter: filter)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if collectionView == headerCell.seasonCollectionView
        {
            return true
        }
        else
        {
            return true
        }
    }
    
    func callWebServiceForSelectedFilter(filter:String)
    {
        let url = metadataUrl.appending((metadata?.id)!).appending("/\(filter)")
        let metadataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .URL)
        weak var weakSelf = self
        RJILApiManager.defaultManager.get(request: metadataRequest) { (data, response, error) in
            
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMoreLikeData(dictionaryResponseData: responseData)
                let indexPath = IndexPath.init(row: 0, section: 0)
                DispatchQueue.main.async {
                    if weakSelf?.metadataTableView.numberOfRows(inSection: 0) == 0{
                        self.metadataTableView.reloadData()
                    }else{
                        weakSelf?.metadataTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                }
                
                return
            }
        }
    }
    
    func evaluateFilteredData(dictionaryResponseData responseData:Data)
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            let tempMetadata = MetadataModel(JSONString: responseString)
            self.metadata?.episodes = tempMetadata?.episodes
        }
    }
    
    
    //MARK:- Change watchlist button status locally
    func changeAddWatchlistButtonStatus(_ itemIdToBeChecked: String, _ appType: VideoType) {
        self.headerCell.addToWatchListButton.isEnabled = true
        if checkIfItemIsInWatchList(itemIdToBeChecked, appType){
            headerCell.watchlistLabel.text = REMOVE_FROM_WATCHLIST
        }
        else{
            headerCell.watchlistLabel.text = ADD_TO_WATCHLIST
        }
    }
    
    func checkIfItemIsInWatchList(_ itemIdToBeChecked: String, _ appType: VideoType) -> Bool {
        var watchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?.items
        if appType == .Movie{
            watchListArray = JCDataStore.sharedDataStore.moviesWatchList?.data?.items
        }
        let itemMatched = watchListArray?.filter{ $0.id == itemIdToBeChecked}.first
        if itemMatched != nil
        {
            return true
        }
        return false
    }
    
    //MARK:- Metadata header cell delegate methods
    func didClickOnWatchNowButton(_ headerView: MetadataHeaderView?) {
        if JCLoginManager.sharedInstance.isUserLoggedIn(){
            playVideo()
        }
        else{
            let loginVc = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: true, fromItemCell: false, presentingVC: self)
            self.present(loginVc, animated: false, completion: nil)
        }
    }
    
    func didClickOnAddOrRemoveWatchListButton(_ headerView: MetadataHeaderView, isStatusAdd: Bool) {
        var params = [String:Any]()
        if itemAppType == .TVShow
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"13" ,"json":["id":metadata?.contentId ?? itemId]]
        }
        else if itemAppType == .Movie
        {
            params = ["uniqueId":JCAppUser.shared.unique,"listId":"12" ,"json":["id": metadata?.contentId ?? itemId]]
        }
        
        if JCLoginManager.sharedInstance.isUserLoggedIn(){
            //let url = isStatusAdd ? removeFromWatchListUrl : addToResumeWatchlistUrl
            let url = isStatusAdd ? addToResumeWatchlistUrl : removeFromWatchListUrl
            callWebServiceToUpdateWatchlist(withUrl: url, andParameters: params)
        }
        else
        {
            presentLoginVC()
        }
    }

    func callWebServiceToUpdateWatchlist(withUrl url:String, andParameters params: Dictionary<String, Any>)
    {
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
    //ChangingTheDataSourceForWatchListItems
    func changingDataSourceForWatchList() {
        if let navVc = self.presentingViewController as? UINavigationController{
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
    func prepareMetadataView() ->UIView
    {
        headerCell.frame.size.width = metadataContainerView.frame.size.width
        headerCell.frame.size.height = metadataContainerView.frame.size.height
        headerCell.titleLabel.text = metadata?.name
        headerCell.subtitleLabel.text = metadata?.newSubtitle
        headerCell.directorLabel.text = metadata?.directors?.joined(separator: ",")
        if metadata?.directors?.count == 0 || metadata?.directors == nil{
            headerCell.directorStaticLabel.isHidden = true
        }
        if metadata?.artist?.count == 0 || metadata?.artist == nil{
            headerCell.starringStaticLabel.isHidden = true
        }
        if metadata?.artist != nil{
            headerCell.starringLabel.text = (metadata?.artist?.joined(separator: ",").count)! > 55 ? (metadata?.artist?.joined(separator: ",").subString(start: 0, end: 51))! + "...." : metadata?.artist?.joined(separator: ",")
        }
        let imageUrl = metadata?.banner ?? ""
        let url = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(imageUrl))!)
        DispatchQueue.main.async {
            self.headerCell.bannerImageView.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "ItemPlaceHolder"), options: SDWebImageOptions.cacheMemoryOnly, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in})
        }
        
        if itemAppType == .Movie, metadata != nil
        {
            headerCell.ratingLabel.text = metadata?.rating?.appending("/10 |")
            return headerCell
        }
        else if itemAppType == VideoType.TVShow, metadata != nil
        {
            headerCell.titleLabel.text = metadata?.name
            headerCell.imdbImageLogo.isHidden = true
            headerCell.ratingLabel.isHidden = true
            headerCell.subtitleLabel.isHidden = true
            headerCell.tvShowSubtitleLabel.isHidden = false
            headerCell.tvShowSubtitleLabel.text = metadata?.newSubtitle
            
            if (metadata?.isSeason) != nil
            {
                if (metadata?.isSeason)!
                {
                    headerCell.seasonsLabel.isHidden = false
                    headerCell.seasonCollectionView.isHidden = false
                    headerCell.monthsCollectionView.isHidden = true
                }
                else
                {
                    headerCell.seasonsLabel.isHidden = false
                    headerCell.seasonsLabel.text = "Previous Episodes"
                    headerCell.seasonCollectionView.isHidden = false
                    headerCell.monthsCollectionView.isHidden = false
                }
            }
            return headerCell
        }
        else
        {
            return UIView.init()
        }
    }
    
    //MARK:- JCBaseTableViewCellDelegate methods, More tableview cell delegate methods
    func didTapOnItemCell(_ baseCell: JCBaseTableViewCell?, _ item: Any?, _ indexFromArray: Int) {
        if let tappedItem = item as? More{
            let itemToBePlayed = self.convertingMoreToItem(tappedItem, currentItem: Item())
            if let itemId = itemToBePlayed.id{
                self.item = itemToBePlayed
                if let appTypeInt = itemToBePlayed.app?.type, let appType = VideoType(rawValue: appTypeInt){
                    self.callWebServiceForMetadata(id: itemId, newAppType: appType)
                }
            }
        }
        else if let tappedItem = item as? Episode{
            print("In episode")
            checkLoginAndPlay(tappedItem, categoryName: MORELIKE, categoryIndex: 0)
        }
        else if let tappedItem = item as? String{
            print("In Artist")
            //changingSearchNCRootVC()
            //present search from here
            let superNav = self.presentingViewController as? UINavigationController
            if let tabController = superNav?.viewControllers[0] as? JCTabBarController{
                let metaDataTabBarIndex = tabController.selectedIndex
                tabController.selectedIndex = 5
                if let searchVcNav = tabController.selectedViewController as? UINavigationController{
                    if let sc = searchVcNav.viewControllers[0] as? UISearchContainerViewController{
                        if let searchVc = sc.searchController.searchResultsController as? JCSearchVC{
                            searchVc.searchArtist(searchText: tappedItem, metaDataItemId: itemId, metaDataAppType: itemAppType, metaDataFromScreen: fromScreen, metaDataCategoryName: categoryName, metaDataCategoryIndex: categoryIndex, metaDataTabBarIndex: metaDataTabBarIndex, metaData: metadata)
                        }
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    func prepareToPlay(_ itemToBePlayed: Episode, categoryName: String, categoryIndex: Int)
    {
        var isEpisodeAvailable = false
        if let episeodes = metadata?.episodes, episeodes.count > 0{
            isEpisodeAvailable = true
        }
        
        let playerVC = Utility.sharedInstance.preparePlayerVC(itemToBePlayed.id ?? "", itemImageString: (itemToBePlayed.banner) ?? "", itemTitle: (itemToBePlayed.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: itemToBePlayed.id ?? "", isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: metadata?.episodes, fromScreen: METADATA_SCREEN, fromCategory: MORELIKE, fromCategoryIndex: 0, fromLanguage: item?.language ?? "")
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
        
//        tempItem.genre = currentItem.genre
//        tempItem.duration = currentItem.duration
//        tempItem.isPlaylist = currentItem.isPlaylist
//        tempItem.playlistId = currentItem.playlistId
//        tempItem.totalDuration = currentItem.totalDuration
//        tempItem.list = currentItem.list
        
        return tempItem
    }
    func playVideo() {
        if itemAppType == VideoType.Movie{
            var isMoreDataAvailable = false
            var recommendationArray: Any = false
            if let moreArray = metadata?.more, moreArray.count > 0{
                isMoreDataAvailable = true
                recommendationArray = moreArray
            }
            let playerVC = Utility.sharedInstance.preparePlayerVC(itemId, itemImageString: (metadata?.banner) ?? "", itemTitle: (metadata?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (metadata?.description) ?? "", appType: .Movie, isPlayList: false, playListId: "", isMoreDataAvailable: isMoreDataAvailable, isEpisodeAvailable: false, recommendationArray: recommendationArray ,fromScreen: METADATA_SCREEN, fromCategory: WATCH_NOW_BUTTON, fromCategoryIndex: 0, fromLanguage: metadata?.language ?? "")
            
            self.present(playerVC, animated: true, completion: nil)
        }
        else if itemAppType == VideoType.TVShow{
            var isEpisodeAvailable = false
            var recommendationArray: Any = false
            if let episodes = metadata?.episodes, episodes.count > 0{
                isEpisodeAvailable = true
                recommendationArray = episodes
            }
            let playerVC = Utility.sharedInstance.preparePlayerVC((metadata?.latestEpisodeId) ?? "", itemImageString: (item?.banner) ?? "", itemTitle: (item?.name) ?? "", itemDuration: 0.0, totalDuration: 50.0, itemDesc: (item?.description) ?? "", appType: .Episode, isPlayList: true, playListId: (metadata?.latestEpisodeId) ?? "", isMoreDataAvailable: false, isEpisodeAvailable: isEpisodeAvailable, recommendationArray: recommendationArray, fromScreen: METADATA_SCREEN, fromCategory: WATCH_NOW_BUTTON, fromCategoryIndex: 0, fromLanguage: metadata?.language ?? "")
            self.present(playerVC, animated: true, completion: nil)
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if  presses.first?.type == .menu, shouldUseTabBarIndex, (tabBarIndex != nil){
            let superNav = self.presentingViewController as? UINavigationController
            if let tabc = superNav?.viewControllers[0] as? JCTabBarController{
                tabc.selectedIndex = tabBarIndex!
            }
        }
    }
    
}


















