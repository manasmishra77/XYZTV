
//
//  JCMetadataVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

enum VideoType:Int
{
    case Search             = -2
    case Home               = -1
    case Movie              = 0
    case TVShow             = 1
    case Music              = 2
    case Trailer            = 3
    case Clip               = 6
    case Episode            = 7
    case ResumeWatching     = 8
    case Language           = 9
    case Genre              = 10
    case None               = -111
    
    var name: String {
        get { return String(describing: self) }
    }
}

class JCMetadataVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    var item:Item!
    var metadata:MetadataModel?
    var selectedYearIndex = 0
    let headerCell = Bundle.main.loadNibNamed("MetadataHeaderViewCell", owner: self, options: nil)?.last as! MetadataHeaderViewCell
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var metaDataHeaderContainer: UIView!
    @IBOutlet weak var metaDataHeaderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var metadataTableView: UITableView!
    @IBOutlet weak var metadataContainerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loaderContainerView: UIView!
  //  @IBOutlet weak var backgroundImageView: UIImageView!
    var headerView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: watchNowNotificationName, object: nil, queue: nil, using: didReceiveNotificationForWatchNow(notification:))
        NotificationCenter.default.addObserver(forName: metadataCellTapNotificationName, object: nil, queue: nil, using: didReceiveNotificationForMetadataCellTap(notification:))
        NotificationCenter.default.addObserver(forName: openSearchVCNotificationName, object: nil, queue: nil, using: didReceiveNotificationForArtistSearch(notification:))
        NotificationCenter.default.addObserver(self, selector: #selector(presentLoginVC), name: showLoginFromMetadataNotificationName, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(prepareToPlay), name: readyToPlayNotificationName, object: nil)
        self.metadataTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCSeasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: seasonCollectionViewCellIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCYearCell", bundle: nil), forCellWithReuseIdentifier: yearCellIdentifier)
        headerCell.monthsCollectionView.register(UINib.init(nibName:"JCMonthCell", bundle: nil), forCellWithReuseIdentifier: monthCellIdentifier)
        self.metadataTableView.tableFooterView = UIView()
        headerCell.addToWatchListButton.isEnabled = false
        
        if item!.name!.characters.count < 1 {
            loadingLabel.text = "Loading"
        }
        else
        {
        loadingLabel.text = "Loading"
        }
        
        callWebServiceForMetadata(id: (item?.id)!)
        //(item?.app?.type == VideoType.Movie.rawValue) ? callWebServiceForMetadata(id: ) : callWebServiceForMetadata(id: ((item?.id)!).appending("/0/0"))
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if !JCLoginManager.sharedInstance.isUserLoggedIn(){
        headerCell.addToWatchListButton.isEnabled = true
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //Removing search container from search navigation controller
        JCAppReference.shared.metaDataVc = self
        
        Utility.sharedInstance.handleScreenNavigation(screenName: "Metadata")
        
        //Clevertap Navigation Event
        let metadataType = item.app?.type == VideoType.Movie.rawValue ? VideoType.Movie.name : VideoType.TVShow.name
        let eventProperties = ["Screen Name":previousScreenName,"Platform":"TVOS","Metadata Page":metadataType]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        JCAppReference.shared.metaDataVc = nil
        //Removing search container from search navigation controller
        if JCAppReference.shared.isTempVCRootVCInSearchNC!{
            changingSearchNCRootVC()
        }
        
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
        cell.itemFromViewController = VideoType.init(rawValue:(item.app?.type)!)
        cell.categoryTitleLabel.tag = indexPath.row + 500000

        cell.moreLikeData = nil
        cell.episodes = nil
        cell.data = nil
        cell.artistImages = nil
        //Metadata for Movies
        
        if item?.app?.type == VideoType.Movie.rawValue
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
        else if item?.app?.type == VideoType.TVShow.rawValue
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
        headerCell.item = item
        headerCell.metadata = metadata
        headerCell.seasonCollectionView.delegate = self
        headerCell.seasonCollectionView.dataSource = self
        headerCell.monthsCollectionView.delegate = self
        headerCell.monthsCollectionView.dataSource = self
        return headerCell.prepareView()
    }
    
    func resetHeaderView() -> UIView
    {
        return headerCell.resetView()
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func callToReloadWatchListStatusWhenJustLoggedIn(){
        callWebserviceForWatchListStatus(id: item.id!)
    }
    
    func callWebServiceForMetadata(id:String)
    {
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
                weakSelf?.callWebServiceForMoreLikeData(id: (weakSelf?.item?.id)!)
                if JCLoginManager.sharedInstance.isUserLoggedIn()
                {
                    weakSelf?.callWebserviceForWatchListStatus(id: id)
                }
                return
            }
        }
    }
    
 
    func callWebServiceForMoreLikeData(id:String)
    {
        let url = item?.app?.type == VideoType.Movie.rawValue ? metadataUrl.appending(id) :metadataUrl.appending(id + "/0/0")
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
                        weakSelf?.headerCell.addToWatchListButton.isEnabled = true
                        weakSelf?.metadata?.inQueue = playbackRightsData?.inqueue
                        if weakSelf?.metadata?.inQueue != nil{
                            if (weakSelf?.metadata?.inQueue)!{
                                weakSelf?.headerCell.watchlistLabel.text = "Remove from watchlist"
                            }
                            else{
                                weakSelf?.headerCell.watchlistLabel.text = "Add to watchlist"
                            }
                        }
                        else{
                            weakSelf?.headerCell.watchlistLabel.text = "Add to watchlist"
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
    func evaluateMoreLikeData(dictionaryResponseData responseData:Data)
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            let tempMetadata = MetadataModel(JSONString: responseString)
            print("\(tempMetadata?.episodes?.count) 1111")
            if item?.app?.type == VideoType.Movie.rawValue
            {
                self.metadata?.more = tempMetadata?.more
            }
            else if item?.app?.type == VideoType.TVShow.rawValue
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
            tableViewTopConstraint.constant = -175
        }
        
        headerCell.seasonCollectionView.reloadData()
        headerCell.monthsCollectionView.reloadData()
        let headerHeight = screenHeight * (4/5)
        if #available(tvOS 11.0, *){
            headerView?.frame = CGRect(x: 0, y: -60, width: metadataTableView.frame.size.width, height: headerHeight)
            
        }else{
            headerView?.frame = CGRect(x: 0, y: 0, width: metadataTableView.frame.size.width, height: headerHeight)
            tableViewTopConstraint.constant = -65
            if metadata?.type == VideoType.Movie.rawValue{
                tableViewTopConstraint.constant = -100
            }
            
            tableViewBottomConstraint.constant = 0
        }
        metaDataHeaderHeight.constant = headerHeight
    }
    
    
    func didReceiveNotificationForWatchNow(notification:Notification)
    {
        //here perform the check for login. Accordingly present login or player
        weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            if let isForResumeScreen = notification.userInfo?["isForResumeScreen"] as? Bool{
                if isForResumeScreen{
                    self.playItemUsingResumeWatch(notification.userInfo?["item"] as! Item)
                }
            }
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            guard let player = notification.userInfo?["player"] as? JCPlayerVC
                else {
                    return
            }
            player.metadata = self.metadata
            self.present(player, animated: false, completion: nil)
        }
        else
        {
            JCLoginManager.sharedInstance.performNetworkCheck { (isOnJioNetwork) in
                if(isOnJioNetwork == false)
                {
                    print("Not on jio network")
                    DispatchQueue.main.async {
                        weakSelf?.presentLoginVC()
                    }    
                }
                else
                {
                    //proceed without checking any login
                    weakSelf?.prepareToPlay()
                    print("Is on jio network")
                }
            }
        }
    }
    
    func playItemUsingResumeWatch(_ resumeItem : Item) {
        let resumeWatchingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: resumeWatchingVCStoryBoardId) as! JCResumeWatchingVC
        currentPlayableItem = resumeItem
        resumeWatchingVC.playableItemDuration = Int(Float(resumeItem.duration!)!)
        resumeWatchingVC.playerId = resumeItem.id
        resumeWatchingVC.itemDescription = resumeItem.subtitle
        resumeWatchingVC.itemImage = resumeItem.banner
        resumeWatchingVC.itemTitle = resumeItem.name
        resumeWatchingVC.itemDuration = String(describing: resumeItem.totalDuration)
        resumeWatchingVC.previousVC = self
        
        resumeWatchingVC.item = currentPlayableItem
        
        self.present(resumeWatchingVC, animated: false, completion: nil)
    }
    
    func prepareToPlay()
    {
        print("play video from metadata vc")
        if playerVC_Global != nil {
            return
        }
        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        let id = (item?.app?.type == VideoType.Movie.rawValue) ? item?.id! : metadata?.latestEpisodeId!
        playerVC.currentItemImage = item?.banner
        playerVC.currentItemTitle = item?.name
        playerVC.currentItemDuration = String(describing: item?.totalDuration)
        playerVC.currentItemDescription = item?.description
        
        playerVC.item = item
        
        playerVC.callWebServiceForPlaybackRights(id: id!)
        
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        
        self.present(playerVC, animated: false, completion: nil)
        
    }
    
    func presentLoginVC()
    {
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: loginVCStoryBoardId)
        loginVC.modalPresentationStyle = .overFullScreen
        loginVC.modalTransitionStyle = .coverVertical
        loginVC.view.layer.speed = 0.7
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func didReceiveNotificationForMetadataCellTap(notification:Notification)
    {
        
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        guard let receivedItem = notification.userInfo?["item"] as? More
            else {
                return
        }
        
        let tempItem = Item()
        
        tempItem.id = receivedItem.id
        tempItem.name = receivedItem.name
        tempItem.showname = ""
        tempItem.subtitle = receivedItem.subtitle
        tempItem.image = receivedItem.image
        tempItem.tvImage = ""
        tempItem.description = receivedItem.description
        tempItem.banner = receivedItem.banner
        tempItem.format = receivedItem.format
        tempItem.language = receivedItem.language
        tempItem.vendor = ""
        tempItem.app = receivedItem.app
        tempItem.latestId = ""
        tempItem.layout = -1
        
        tempItem.genre = item.genre
        tempItem.duration = item.duration
        tempItem.isPlaylist = item.isPlaylist
        tempItem.playlistId = item.playlistId
        tempItem.totalDuration = item.totalDuration
        tempItem.list = item.list

        item = tempItem
        
        loadingLabel.text = "Loading"
        metadataContainerView.isHidden = true
        loaderContainerView.isHidden = false
        
        (item?.app?.type == VideoType.Movie.rawValue) ? callWebServiceForMetadata(id: (item?.id)!) : callWebServiceForMetadata(id: ((item?.id)!).appending("/0/0"))
        
        
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
                return (metadata?.filter?.count)!
               
            }
            else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
            {
                return (metadata?.filter?.count)!
            }
            else if collectionView == headerCell.monthsCollectionView  //months, in case of episodes
            {
                if  (metadata?.filter?.count)! > selectedYearIndex
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
            cell.seasonNumberLabel.text = String(describing: metadata!.filter![indexPath.row].season!)
            return cell
           
        }
        else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: yearCellIdentifier, for: indexPath) as! JCYearCell
            if let text = metadata!.filter![indexPath.row].filter
            {
                cell.yearLabel.text = text
            }
            else
            {
                cell.yearLabel.text = ""
            }
            return cell
        }
        else if collectionView == headerCell.monthsCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: monthCellIdentifier, for: indexPath) as! JCMonthCell
            var text = ""
            switch metadata!.filter![selectedYearIndex].month![indexPath.row]
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
        
        if (metadata?.isSeason!)!,collectionView == headerCell.seasonCollectionView     //seasons
        {
            let filter = String(metadata!.filter![indexPath.row].season!)
            callWebServiceForSelectedFilter(filter: filter)
        }
        else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
        {
            selectedYearIndex = indexPath.row
            headerCell.monthsCollectionView.reloadData()
            let filter = String(describing: metadata!.filter![selectedYearIndex].filter!).appending("/\(String(describing: metadata!.filter![selectedYearIndex].month![0]))")
            callWebServiceForSelectedFilter(filter: filter)
        }
        else    //months
        {
            let filter = String(describing: metadata!.filter![selectedYearIndex].filter!).appending("/\(String(describing: metadata!.filter![selectedYearIndex].month![indexPath.row]))")
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
                    weakSelf?.metadataTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
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

    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.menu
        {
         
            if let vc = UIApplication.topViewController(){
                if vc is JCMetadataVC{
                     NotificationCenter.default.post(name: playerDismissNotificationName, object: nil)
                    NotificationCenter.default.removeObserver(self)
                }
            }
         

        }
    }
    
    func didReceiveNotificationForArtistSearch(notification:Notification)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        guard let artistName = notification.userInfo?["artist"] as? String
            else {
                return
        }
        changingSearchNCRootVC()
        //present search from here
        
        let artistSearchVC = JCSearchVC.init(nibName: "JCBaseVC", bundle: nil)
        artistSearchVC.view.backgroundColor = .black
        
        let searchViewController = UISearchController(searchResultsController: artistSearchVC)
        searchViewController.view.backgroundColor = .black
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.searchBar.tintColor = UIColor.white
        searchViewController.searchBar.barTintColor = UIColor.black
        searchViewController.searchBar.tintColor = UIColor.gray
        searchViewController.hidesNavigationBarDuringPresentation = true
        searchViewController.obscuresBackgroundDuringPresentation = false
        searchViewController.searchBar.delegate = artistSearchVC
        searchViewController.searchBar.searchBarStyle = .minimal
        //searchViewController.searchBar.text = artistName
        JCAppReference.shared.searchText = artistName
        artistSearchVC.searchViewController = searchViewController
        
        
        self.present(searchViewController, animated: false, completion: nil)
    }
    
    //Removing seasarch container from search navigation controller
    func changingSearchNCRootVC(){
        if JCAppReference.shared.isTempVCRootVCInSearchNC == nil{
            return
        }
        if JCAppReference.shared.isTempVCRootVCInSearchNC!{
            JCAppReference.shared.isTempVCRootVCInSearchNC = false
            let searchVC = JCSearchVC(nibName: "JCBaseVC", bundle: nil)
            searchVC.view.backgroundColor = .black
            
            let searchViewController = UISearchController.init(searchResultsController: searchVC)
            searchViewController.view.backgroundColor = .black
            searchViewController.searchBar.placeholder = "Search"
            searchViewController.searchBar.tintColor = UIColor.white
            searchViewController.searchBar.barTintColor = UIColor.black
            searchViewController.searchBar.tintColor = UIColor.gray
            searchViewController.hidesNavigationBarDuringPresentation = true
            searchViewController.obscuresBackgroundDuringPresentation = false
            searchViewController.searchBar.delegate = searchVC
            searchViewController.searchBar.searchBarStyle = .minimal
            searchVC.searchViewController = searchViewController
            let searchContainerController = UISearchContainerViewController(searchController: searchViewController)
            searchContainerController.view.backgroundColor = UIColor.black
            if let navVcForSearchContainer = JCAppReference.shared.tabBarCotroller?.viewControllers![5] as? UINavigationController{
                navVcForSearchContainer.setViewControllers([searchContainerController], animated: false)
            }
            
        }
        else{
            JCAppReference.shared.isTempVCRootVCInSearchNC = true
            if let navVC = JCAppReference.shared.tabBarCotroller?.viewControllers![5] as? UINavigationController{
                navVC.setViewControllers([JCAppReference.shared.tempVC!], animated: false)
            }
        }
    }
    
    
    //MARK:- Change watchlist button status locally
    func changeAddWatchlistButtonStatus() {
        if checkIfItemIsInWatchList(item){
            headerCell.watchlistLabel.text = "Remove from watchlist"
        }
        else{
            headerCell.watchlistLabel.text = "Add to watchlist"
        }
        
    }
    
    func checkIfItemIsInWatchList(_ itemToBeChecked: Item) -> Bool {
        var watchListArray = JCDataStore.sharedDataStore.tvWatchList?.data?.items
        if itemToBeChecked.app?.type == VideoType.Movie.rawValue{
            watchListArray = JCDataStore.sharedDataStore.moviesWatchList?.data?.items
        }
        let itemMatched = watchListArray?.filter{ $0.id == itemToBeChecked.id}.first
        if itemMatched != nil
        {
            return true
        }
        return false
    }
    
    
}
