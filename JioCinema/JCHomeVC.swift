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
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        super.activityIndicator.isHidden = true
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
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
        if JCDataStore.sharedDataStore.homeData?.data != nil
        {
            return (JCDataStore.sharedDataStore.homeData?.data?.count)! - 1
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        if isResumeWatchDataAvailable,indexPath.row == 0
        {
            cell.data = JCDataStore.sharedDataStore.resumeWatchList?.data?.items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.resumeWatchList?.title
            cell.tableCellCollectionView.reloadData()
        }
        else
        {
            cell.data = isResumeWatchDataAvailable ? JCDataStore.sharedDataStore.homeData?.data?[indexPath.row].items : JCDataStore.sharedDataStore.homeData?.data?[indexPath.row + 1].items
            cell.categoryTitleLabel.text = isResumeWatchDataAvailable ? JCDataStore.sharedDataStore.homeData?.data?[indexPath.row].title : JCDataStore.sharedDataStore.homeData?.data?[indexPath.row + 1].title
                cell.tableCellCollectionView.reloadData()
            
        }
        
        if(indexPath.row == (JCDataStore.sharedDataStore.homeData?.data?.count)! - 2)
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
        let headerCell = tableView.dequeueReusableCell(withIdentifier: baseHeaderTableViewCellIdentifier) as! JCBaseTableViewHeaderCell
        headerCell.carousalData = JCDataStore.sharedDataStore.homeData?.data?[0].items
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 600
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
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
        isResumeWatchDataAvailable = true
        DispatchQueue.main.async {
            weakSelf?.baseTableView.reloadData()
        }
    }
}


