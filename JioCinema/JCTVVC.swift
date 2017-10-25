//
//  JCTVVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCTVVC: JCBaseVC,UITableViewDelegate,UITableViewDataSource, UITabBarControllerDelegate
{

    var loadedPage = 0
    var isTVWatchlistAvailable = false
    var dataItemsForTableview = [DataContainer]()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForTVData(page: loadedPage)
        
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.tabBarController?.delegate = self
        if JCDataStore.sharedDataStore.tvData?.data == nil
        {
            callWebServiceForTVData(page: loadedPage)
        }
        
        if JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            self.callWebServiceForTVWatchlist()
        }
        else
        {
            isTVWatchlistAvailable = false
        }
        baseTableView.reloadData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
       // self.tabBarController?.delegate = nil
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        dataItemsForTableview.removeAll()
        if (JCDataStore.sharedDataStore.tvData?.data) != nil
        {
            if !JCLoginManager.sharedInstance.isUserLoggedIn()
            {
                isTVWatchlistAvailable = false
            }
            dataItemsForTableview = (JCDataStore.sharedDataStore.tvData?.data)!
            if let isCarousal = dataItemsForTableview[0].isCarousal {
                if isCarousal{
                    dataItemsForTableview.remove(at: 0)
                }
            }
            if isTVWatchlistAvailable{
                if let items = JCDataStore.sharedDataStore.tvWatchList?.data?.items {
                    if items.count > 0 {
                        dataItemsForTableview.insert((JCDataStore.sharedDataStore.tvWatchList?.data)!, at: 0)
                    }
                }
            }
            return dataItemsForTableview.count
            
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.tableCellCollectionView.tag = indexPath.row
        cell.itemFromViewController = VideoType.TVShow

        cell.data = dataItemsForTableview[indexPath.row].items
        cell.categoryTitleLabel.text = dataItemsForTableview[indexPath.row].title
        cell.tableCellCollectionView.reloadData()
        if(indexPath.row == (JCDataStore.sharedDataStore.tvData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.tvData?.totalPages)! - 1)
            {
                callWebServiceForTVData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(JCDataStore.sharedDataStore.tvData?.data?[0].isCarousal == true)
        {
            //For autorotate carousel
            let carouselViews = Bundle.main.loadNibNamed("kInfinityScrollView", owner: self, options: nil)
            let carouselView = carouselViews?.first as! InfinityScrollView
            carouselView.carouselArray = (JCDataStore.sharedDataStore.tvData?.data?[0].items)!
            carouselView.loadViews()
            uiviewCarousel = carouselView
            return carouselView
        }
        else
        {
            return UIView.init()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if(JCDataStore.sharedDataStore.tvData?.data?[0].isCarousal == true)
        {
            return CGFloat(heightOfCarouselSection)
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.tvData?.totalPages) == nil
        {
            return UIView.init()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.tvData?.totalPages)! - 1)
            {
                return UIView.init()
            }
            else
            {
                let footerCell = tableView.dequeueReusableCell(withIdentifier: baseFooterTableViewCellIdentifier) as! JCBaseTableViewFooterCell
                return footerCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 650
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func callWebServiceForTVData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = tvDataUrl.appending(String(page))
        let tvDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: tvDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateTVData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateTVData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0)
        {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .TV)
            weak var weakSelf = self
            DispatchQueue.main.async {
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }
        else
        {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .TV)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.baseTableView.reloadData()
            }
        }
    }

    func callWebServiceForTVWatchlist()
    {
        let url = tvWatchListUrl
        let uniqueID = JCAppUser.shared.unique
        var params: Dictionary<String, Any> = [:]
        params["uniqueId"] = uniqueID
        let loginRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: loginRequest) { (data, response, error) in
            
            if let responseError = error
            {
                print(responseError)
                return
            }
            
            if let responseData = data
            {
                DispatchQueue.main.async {
                    weakSelf?.evaluateTVWatchlistData(dictionaryResponseData: responseData)
                }
                return
            }
        }
    }
    
    func evaluateTVWatchlistData(dictionaryResponseData responseData:Data)
    {
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .TVWatchList)
        if (JCDataStore.sharedDataStore.tvWatchList?.data?.items?.count)! > 0 {
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.isTVWatchlistAvailable = true
                JCDataStore.sharedDataStore.tvWatchList?.data?.title = "Watch List"
                weakSelf?.baseTableView.reloadData()
            }
        }
        
    }
    
    //ChangingTheAlpha
    var uiviewCarousel: UIView? = nil
    var focusShiftedFromTabBarToVC = true
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //ChangingTheAlpha when focus shifted from tab bar item to view controller view
        if focusShiftedFromTabBarToVC{
            focusShiftedFromTabBarToVC = false
            if let cells = baseTableView.visibleCells as? [JCBaseTableViewCell]{
                for cell in cells{
                    if cell != cells.first {
                        cell.tableCellCollectionView.alpha = 0.5
                    }
                }
                if cells.count <= 2{
                    cells.first?.tableCellCollectionView.alpha = 0.5
                }
                
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //ChangingTheAlpha when tab bar item selected
        focusShiftedFromTabBarToVC = true
        if let headerViewOfTableSection = uiviewCarousel as? InfinityScrollView{
            headerViewOfTableSection.middleButton.alpha = 1
        }
        for each in (self.baseTableView.visibleCells as? [JCBaseTableViewCell])!{
            each.tableCellCollectionView.alpha = 1
        }
    }
    

}
