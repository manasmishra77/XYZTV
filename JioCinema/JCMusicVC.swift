//
//  JCMusicVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 29/07/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCMusicVC: JCBaseVC,UITableViewDelegate,UITableViewDataSource
{

    var loadedPage = 0
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForMusicData(page: loadedPage)
        
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
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
        if (JCDataStore.sharedDataStore.musicData?.data) != nil
        {
            if(JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal == true)
            {
                return (JCDataStore.sharedDataStore.musicData?.data?.count)! - 1
            }
            else
            {
                return (JCDataStore.sharedDataStore.musicData?.data?.count)!
            }
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.itemFromViewController = VideoType.Music

        
        if(JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal == true)
        {
            cell.tableCellCollectionView.tag = indexPath.row + 1
            cell.data = JCDataStore.sharedDataStore.musicData?.data?[indexPath.row + 1].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.musicData?.data?[indexPath.row + 1].title
        }
        else
        {
            cell.tableCellCollectionView.tag = indexPath.row
            cell.data = JCDataStore.sharedDataStore.musicData?.data?[indexPath.row].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.musicData?.data?[indexPath.row].title
        }
        
        DispatchQueue.main.async {
            cell.tableCellCollectionView.reloadData()
        }
        if(indexPath.row == (JCDataStore.sharedDataStore.musicData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.musicData?.totalPages)! - 1)
            {
                callWebServiceForMusicData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal == true)
        {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: baseHeaderTableViewCellIdentifier) as! JCBaseTableViewHeaderCell
            headerCell.carousalData = JCDataStore.sharedDataStore.musicData?.data?[0].items
            return headerCell
        }
        else
        {
            return UIView.init()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if(JCDataStore.sharedDataStore.musicData?.data?[0].isCarousal == true)
        {
            return CGFloat(heightOfCarouselSection)
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.musicData?.totalPages) == nil
        {
            return UIView.init()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.musicData?.totalPages)! - 1)
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
    
    
    func callWebServiceForMusicData(page:Int)
    {
        let url = musicDataUrl.appending(String(page))
        let musicDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: musicDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateMusicData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateMusicData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0)
        {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Music)
            weak var weakSelf = self
            DispatchQueue.main.async {
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }
        else
        {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Music)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.baseTableView.reloadData()
            }
        }
    }
}
