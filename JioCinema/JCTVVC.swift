//
//  JCTVVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCTVVC: JCBaseVC,UITableViewDelegate,UITableViewDataSource
{

    var loadedPage = 0
    var isTVWatchlistAvailable = false
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForTVData(page: loadedPage)
        
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if JCDataStore.sharedDataStore.tvWatchList == nil, JCLoginManager.sharedInstance.isUserLoggedIn()
        {
            self.callWebServiceForTVWatchlist()
        }
        baseTableView.reloadData()
        
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
        if (JCDataStore.sharedDataStore.tvData?.data) != nil
        {
            if(JCDataStore.sharedDataStore.tvData?.data?[0].isCarousal == true)
            {
                return (JCDataStore.sharedDataStore.tvData?.data?.count)! - 1
            }
            else if JCDataStore.sharedDataStore.tvWatchList != nil
            {
                return (JCDataStore.sharedDataStore.tvData?.data?.count)! + 1
            }
            else
            {
                return (JCDataStore.sharedDataStore.tvData?.data?.count)!
            }
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        if(JCDataStore.sharedDataStore.tvData?.data?[0].isCarousal == true)
        {
            cell.data = JCDataStore.sharedDataStore.tvData?.data?[indexPath.row + 1].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.tvData?.data?[indexPath.row + 1].title
            
        }
        else if JCDataStore.sharedDataStore.tvWatchList != nil, indexPath.row == 0
        {
            if JCDataStore.sharedDataStore.tvWatchList?.data?.items?.count != 0
            {
            cell.data = JCDataStore.sharedDataStore.tvWatchList?.data?.items
            cell.categoryTitleLabel.text = "WatchList"
                cell.tableCellCollectionView.reloadData()
            isTVWatchlistAvailable = true
            }
        }
        else
        {
            let dataRow = indexPath.row - 1
            cell.data = (isTVWatchlistAvailable) ? JCDataStore.sharedDataStore.tvData?.data?[dataRow].items : JCDataStore.sharedDataStore.tvData?.data?[indexPath.row].items
            cell.categoryTitleLabel.text = (isTVWatchlistAvailable) ? JCDataStore.sharedDataStore.tvData?.data?[dataRow].title : JCDataStore.sharedDataStore.tvData?.data?[indexPath.row].title
            cell.tableCellCollectionView.reloadData()
        }
        
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
            let headerCell = tableView.dequeueReusableCell(withIdentifier: baseHeaderTableViewCellIdentifier) as! JCBaseTableViewHeaderCell
            headerCell.carousalData = JCDataStore.sharedDataStore.tvData?.data?[0].items
            return headerCell
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
        return 600
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func callWebServiceForTVData(page:Int)
    {
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
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.baseTableView.reloadData()
        }
    }
}
