//
//  JCClipsVC.swift
//  JioCinema
//
//  Created by Pallav Trivedi on 01/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCClipsVC: JCBaseVC,UITableViewDelegate,UITableViewDataSource
{
    
    var loadedPage = 0
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callWebServiceForClipsData(page: loadedPage)
        
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewFooterCell", bundle: nil), forCellReuseIdentifier: baseFooterTableViewCellIdentifier)
        self.baseTableView.delegate = self
        self.baseTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
  
        if JCDataStore.sharedDataStore.clipsData?.data == nil
        {
            callWebServiceForClipsData(page: loadedPage)
        }
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
        if (JCDataStore.sharedDataStore.clipsData?.data) != nil
        {
            if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
            {
                return (JCDataStore.sharedDataStore.clipsData?.data?.count)! - 1
            }
            else
            {
                return (JCDataStore.sharedDataStore.clipsData?.data?.count)!
            }
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        
        cell.itemFromViewController = VideoType.Clip

        if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
        {
            cell.tableCellCollectionView.tag = indexPath.row + 1

            cell.data = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row + 1].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row + 1].title
        }
        else
        {
            cell.tableCellCollectionView.tag = indexPath.row

            cell.data = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row].items
            cell.categoryTitleLabel.text = JCDataStore.sharedDataStore.clipsData?.data?[indexPath.row].title
        }
        
        DispatchQueue.main.async {
            cell.tableCellCollectionView.reloadData()
        }
        if(indexPath.row == (JCDataStore.sharedDataStore.clipsData?.data?.count)! - 2)
        {
            if(loadedPage < (JCDataStore.sharedDataStore.clipsData?.totalPages)! - 1)
            {
                callWebServiceForClipsData(page: loadedPage + 1)
                loadedPage += 1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
        {
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
            carouselView.carouselArray = (JCDataStore.sharedDataStore.clipsData?.data?[0].items)!
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
        if(JCDataStore.sharedDataStore.clipsData?.data?[0].isCarousal == true)
        {
            return CGFloat(heightOfCarouselSection)
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (JCDataStore.sharedDataStore.clipsData?.totalPages) == nil
        {
            return UIView.init()
        }
        else
        {
            if(loadedPage == (JCDataStore.sharedDataStore.clipsData?.totalPages)! - 1)
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
    
    
    func callWebServiceForClipsData(page:Int)
    {
        if !Utility.sharedInstance.isNetworkAvailable
        {
            Utility.sharedInstance.showDismissableAlert(title: networkErrorMessage, message: "")
            return
        }
        
        let url = clipsDataUrl.appending(String(page))
        let clipsDataRequest = RJILApiManager.defaultManager.prepareRequest(path: url, encoding: .BODY)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: clipsDataRequest) { (data, response, error) in
            if let responseError = error
            {
                //TODO: handle error
                print(responseError)
                return
            }
            if let responseData = data
            {
                weakSelf?.evaluateClipsData(dictionaryResponseData: responseData)
                return
            }
        }
    }
    
    func evaluateClipsData(dictionaryResponseData responseData:Data)
    {
        //Success
        
        if(loadedPage == 0)
        {
            JCDataStore.sharedDataStore.setData(withResponseData: responseData, category: .Clips)
            weak var weakSelf = self
            DispatchQueue.main.async {
                super.activityIndicator.isHidden = true
                weakSelf?.baseTableView.reloadData()
            }
        }
        else
        {
            JCDataStore.sharedDataStore.appendData(withResponseData: responseData, category: .Clips)
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.baseTableView.reloadData()
            }
        }
    }
    
    //ChangingTheAlpha
    var isAbleToChangeAlpha = false
    var focusShiftedFromTabBarToVC = true
    var uiviewCarousel: UIView? = nil

    //ChangingTheAlpha
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.menu
        {
            //ForChangingTheAlphaWhenMenuButtonPressed
            if (self.tabBarController?.selectedViewController as? JCClipsVC) != nil{
                if let headerViewOfTableSection = uiviewCarousel as? InfinityScrollView{
                    headerViewOfTableSection.middleButton.alpha = 1
                }
                
                if let cells = baseTableView.visibleCells as? [JCBaseTableViewCell]{
                    isAbleToChangeAlpha = true
                    for cell in cells{
                        if cell.tableCellCollectionView.alpha == CGFloat(1){
                            cell.tableCellCollectionView.tag = 3
                        }
                        cell.tableCellCollectionView.alpha = 1
                        
                    }
                }
            }
        }
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //ChangingAlphaIfScrollingToTabItemNormally
        if (context.previouslyFocusedView as? CarouselViewButton) != nil {
            if context.nextFocusedView?.tag != 101 {
                if let headerViewOfTableSection = uiviewCarousel as? InfinityScrollView{
                    headerViewOfTableSection.middleButton.alpha = 1
                }
            }
            
        }
        //ForChangingTheAlphaWhenMenuButtonPressed
        if isAbleToChangeAlpha{
            isAbleToChangeAlpha = false
            focusShiftedFromTabBarToVC = true
        }
        else if focusShiftedFromTabBarToVC{
            focusShiftedFromTabBarToVC = false
            if let cells = baseTableView.visibleCells as? [JCBaseTableViewCell]{
                isAbleToChangeAlpha = false
                for cell in cells{
                    if cell != cells.first{
                        cell.tableCellCollectionView.alpha = 0.5
                    }
                }
            }
        }
    }
    
    
}
