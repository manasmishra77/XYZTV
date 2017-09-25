//
//  JCHomeVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 12/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
class JCHomeVC: JCBaseVC,UITableViewDelegate,UITableViewDataSource
{
    var loadedPage = 0
    var isResumeWatchDataAvailable = false
    var isFirstLoaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        isFirstLoaded = true
        super.activityIndicator.isHidden = true
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(callResumeWatchWebServiceOnPlayerDismiss), name: playerDismissNotificationName, object: nil)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            callWebServiceForResumeWatchData()
        }
        else
        {
            baseTableView.reloadData()
        }
        
        
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
        if JCDataStore.sharedDataStore.homeData?.data != nil
        {
            if isResumeWatchDataAvailable, JCLoginManager.sharedInstance.isUserLoggedIn()
            {
                return (JCDataStore.sharedDataStore.mergedHomeData?.count)!
            }
            return (JCDataStore.sharedDataStore.mergedHomeData?.count)! - 1
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.tableCellCollectionView.tag = indexPath.row
        cell.itemFromViewController = VideoType.Home

        if !JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            isResumeWatchDataAvailable = false
        }
        
        if isResumeWatchDataAvailable,indexPath.row == 0, JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            cell.isResumeWatchCell = true
            cell.data = JCDataStore.sharedDataStore.resumeWatchList?.data?.items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.resumeWatchList?.title
            cell.tableCellCollectionView.reloadData()
        }
        else
        {
            cell.isResumeWatchCell = false
            cell.data = isResumeWatchDataAvailable ? JCDataStore.sharedDataStore.mergedHomeData?[indexPath.row].items : JCDataStore.sharedDataStore.mergedHomeData?[indexPath.row + 1].items
            cell.categoryTitleLabel.text = isResumeWatchDataAvailable ? JCDataStore.sharedDataStore.mergedHomeData?[indexPath.row].title : JCDataStore.sharedDataStore.mergedHomeData?[indexPath.row + 1].title
            cell.tableCellCollectionView.reloadData()
        }
        
        if(indexPath.row == (JCDataStore.sharedDataStore.mergedHomeData?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.homeData?.totalPages)! - 1)
            {
                callWebServiceForHomeData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*
        let headerCell = tableView.dequeueReusableCell(withIdentifier: baseHeaderTableViewCellIdentifier) as! JCBaseTableViewHeaderCell
        headerCell.carousalData = JCDataStore.sharedDataStore.homeData?.data?[0].items
        headerCell.itemFromViewController = VideoType.Music
        headerCell.headerCollectionView.tag = 0
        return headerCell
        */
 
        
        //For autorotate carousel
        let carouselViews = Bundle.main.loadNibNamed("kInfinityScrollView", owner: self, options: nil)
        let carouselView = carouselViews?.first as! InfinityScrollView
        carouselView.carouselArray = (JCDataStore.sharedDataStore.homeData?.data?[0].items)!
        carouselView.loadViews()
        return carouselView
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.homeData?.totalPages) != nil
        {
            if(loadedPage == (JCDataStore.sharedDataStore.homeData?.totalPages)! - 1)
            {
                return UIView.init()
            }
            else
            {
                let footerCell = tableView.dequeueReusableCell(withIdentifier: baseFooterTableViewCellIdentifier) as! JCBaseTableViewFooterCell
                return footerCell
            }
        }
        else
        {
            return UIView.init()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 650
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    {
        
        return false
    }
    
    
    func callWebServiceForHomeData(page:Int)
    {
        let url = homeDataUrl.appending(String(page))
        let homeDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: homeDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateHomeData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateHomeData(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Home)
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.baseTableView.reloadData()
        }
    }
    
    func callWebServiceForResumeWatchData()
    {
        let url = resumeWatchGetUrl
        let params = ["uniqueId":JCAppUser.shared.unique]
        let resumeWatchDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: resumeWatchDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateResumeWatchData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateResumeWatchData(dictionaryResponseData responseData:Data)
    {
        //Success
        JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .ResumeWatchList)
        weak var weakSelf = self
        if (JCDataStore.sharedDataStore.resumeWatchList?.data?.items?.count)! > 0
        {
            isResumeWatchDataAvailable = true
            
            DispatchQueue.main.async {
                let visibleCell = weakSelf?.baseTableView.visibleCells
                if (weakSelf?.isFirstLoaded)! {
                    weakSelf?.isFirstLoaded = false
                    weakSelf?.baseTableView.reloadData()
                   // weakSelf?.isFirstLoaded = false
                }
                else
                {
                    for visible in visibleCell!
                    {
                        let visibleIndex = weakSelf?.baseTableView.indexPath(for: visible)
                        if visibleIndex?.row == 0
                        {
                            let resumeCell = weakSelf?.baseTableView.cellForRow(at: visibleIndex!) as! JCBaseTableViewCell
                            if resumeCell.isResumeWatchCell {
                                resumeCell.data = JCDataStore.sharedDataStore.resumeWatchList?.data?.items
                                resumeCell.tableCellCollectionView.reloadData()
                            }
                            else
                            {
                                weakSelf?.baseTableView.reloadData()
                            }
                            
                            break
                        }
                    }
                }

            }
        }
        else{
            if (self.isFirstLoaded) {
                //weakSelf?.isFirstLoaded = false
                self.baseTableView.reloadData()
                self.isFirstLoaded = false
            }
        }
    }
    
    func callResumeWatchWebServiceOnPlayerDismiss()
    {
        callWebServiceForResumeWatchData()
    }
}


