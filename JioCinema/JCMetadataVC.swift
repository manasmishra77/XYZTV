//
//  JCMetadataVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMetadataVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    
    
    enum VideoType:Int
    {
        case Movie = 0
        case Music = 2
        case TVShow = 1
        case Clip = 6
    }
    
    var item:Item?
    var metadata:MetadataModel?
    var selectedYearIndex = 0
    let headerCell = Bundle.main.loadNibNamed("MetadataHeaderViewCell", owner: self, options: nil)?.last as! MetadataHeaderViewCell
    
    @IBOutlet weak var metadataTableView: UITableView!
    @IBOutlet weak var metadataContainerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loaderContainerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var headerView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: watchNowNotificationName, object: nil, queue: nil, using: didReceiveNotificationForWatchNow(notification:))
        NotificationCenter.default.addObserver(forName: metadataCellTapNotificationName, object: nil, queue: nil, using: didReceiveNotificationForMetadataCellTap(notification:))
        NotificationCenter.default.addObserver(self, selector: #selector(presentLoginVC), name: showLoginFromMetadataNotificationName, object: nil)
        self.metadataTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCSeasonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: seasonCollectionViewCellIdentifier)
        headerCell.seasonCollectionView.register(UINib.init(nibName:"JCYearCell", bundle: nil), forCellWithReuseIdentifier: yearCellIdentifier)
        headerCell.monthsCollectionView.register(UINib.init(nibName:"JCMonthCell", bundle: nil), forCellWithReuseIdentifier: monthCellIdentifier)
        self.metadataTableView.tableFooterView = UIView.init()
        
        loadingLabel.text = "Loading metadata for \(String(describing: item!.name!))"
        
        (item?.app?.type == VideoType.Movie.rawValue) ? callWebServiceForMetadata(id: (item?.id)!) : callWebServiceForMetadata(id: ((item?.id)!).appending("/0/0"))
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if metadata != nil, metadata?.app?.type == VideoType.Movie.rawValue
        {
            return 2
        }
        else if metadata?.episodes != nil , metadata?.app?.type == VideoType.TVShow.rawValue
        {
            return 3
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        cell.tableCellCollectionView.backgroundColor = UIColor.clear
        
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
                cell.moreLikeData = metadata?.more
                cell.categoryTitleLabel.text = (metadata?.more?.count != 0) ? "More Like \(String(describing: item!.name!))" : ""
                cell.tableCellCollectionView.reloadData()
            }
            if indexPath.row == 2
            {
                let dict = getStarCastImagesUrl(artists: (metadata?.artist)!)
                cell.categoryTitleLabel.text = (dict.count != 0) ? "Cast & Crew" : ""
                cell.artistImages = dict
                cell.tableCellCollectionView.reloadData()
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
                if JCLoginManager.sharedInstance.isUserLoggedIn()
                {
                    weakSelf?.callWebserviceForWatchListStatus(id: id)
                }
                else
                {
                    weakSelf?.callWebServiceForMoreLikeData(id: id)
                }
                
                return
            }
        }
    }
    
    
    func callWebServiceForMoreLikeData(id:String)
    {
        let url = item?.app?.type == VideoType.Movie.rawValue ? metadataUrl.appending(id.replacingOccurrences(of: "/0/0", with: "")) :metadataUrl.appending(id)
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
                DispatchQueue.main.async {
                    weakSelf?.prepareMetadataScreen()
                }
                
                return
            }
        }
        
    }
    
    func callWebserviceForWatchListStatus(id:String)
    {
        let url = playbackRightsURL.appending(id.replacingOccurrences(of: "/0/0", with: ""))
        let params = ["id":id,"showId":"","uniqueId":JCAppUser.shared.unique,"deviceType":"stb"]
        let playbackRightsRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: playbackRightsRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                if(id.contains("/0/0"))
                {
                    weakSelf?.callWebServiceForMoreLikeData(id: id)
                }
                else
                {
                    DispatchQueue.main.async {
                        weakSelf?.prepareMetadataScreen()
                    }
                }
                return
            }
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    let playbackRightsData = PlaybackRightsModel(JSONString: responseString)
                    weakSelf?.metadata?.inQueue = playbackRightsData?.inqueue
                    if(id.contains("/0/0"))
                    {
                        weakSelf?.callWebServiceForMoreLikeData(id: id)
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            weakSelf?.prepareMetadataScreen()
                        }
                    }
                }
                return
            }
        }
    }
    
    func evaluateMoreLikeData(dictionaryResponseData responseData:Data)
    {
        //Success
        if let responseString = String(data: responseData, encoding: .utf8)
        {
            let tempMetadata = MetadataModel(JSONString: responseString)
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
        }
    }
    
    func prepareMetadataScreen()
    {
        weak var weakSelf = self
        if let image = RJILImageDownloader.shared.loadCachedImage(url: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending((item?.banner)!))!)
        {
            backgroundImageView.image = image
            showMetadata()
            metadataTableView.reloadData()
        }
        else
        {
            self.downloadImageFrom(urlString: (item?.banner)!, completion: { (loaded) in
                weakSelf?.showMetadata()
            })
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
        headerCell.seasonCollectionView.reloadData()
        headerCell.monthsCollectionView.reloadData()
        headerView?.frame = CGRect(x: 0, y: 0, width: metadataTableView.frame.size.width, height: 680)
        self.view.addSubview(headerView!)
        headerView?.isHidden = false
    }
    
    fileprivate func downloadImageFrom(urlString:String,completion:@escaping NetworkCheckCompletionBlock)
    {
        let imageUrl = JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(urlString)
        RJILImageDownloader.shared.downloadImage(urlString: imageUrl!, shouldCache: true){
            
            image in
            
            if let img = image {
                
                DispatchQueue.main.async {
                    
                    self.backgroundImageView.image = img
                    completion(true)
                }
            }
        }
    }
    
    func didReceiveNotificationForWatchNow(notification:Notification)
    {
        //here perform the check for login. Accordingly present login or player
        weak var weakSelf = self
        if(JCLoginManager.sharedInstance.isUserLoggedIn())
        {
            JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
            guard let player = notification.userInfo?["player"] as? JCPlayerVC
                else {
                    return
            }
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
    
    func prepareToPlay()
    {
        print("play video")
        
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        let id = (item?.app?.type == VideoType.Movie.rawValue) ? item?.id! : metadata?.latestEpisodeId!
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
        guard let receivedItem = notification.userInfo?["item"] as? More
            else {
                return
        }
        item?.id = receivedItem.id
        item?.name = receivedItem.name
        item?.showname = ""
        item?.subtitle = receivedItem.subtitle
        item?.image = receivedItem.image
        item?.tvImage = ""
        item?.description = receivedItem.description
        item?.banner = receivedItem.banner
        item?.format = receivedItem.format
        item?.language = receivedItem.language
        item?.vendor = ""
        item?.app = receivedItem.app
        item?.latestId = ""
        item?.layout = -1
        
        loadingLabel.text = "Loading metadata for \(String(describing: item!.name!))"
        metadataContainerView.isHidden = true
        headerView?.isHidden = true
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
            let imageUrl = "http://images.hdi.cdn.ril.com/vr1/Starcast/\(firstFolderParsed)/\(secondFolderParsed)/\(hexString)_low.jpg"
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

extension JCMetadataVC:UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if metadata?.app?.type == VideoType.TVShow.rawValue
        {
            if (metadata?.isSeason!)!,collectionView == headerCell.seasonCollectionView     //seasons
            {
                return (metadata?.filter?.count)!
            }
            else if collectionView == headerCell.seasonCollectionView       //years, in case of episodes
            {
                return (metadata?.filter?.count)!
            }
            else if collectionView == headerCell.monthsCollectionView   //months, in case of episodes
            {
                if let count = (metadata?.filter![selectedYearIndex].month?.count)
                {
                    return count
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
        if (metadata?.isSeason!)!,collectionView == headerCell.seasonCollectionView     //seasons
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
}
