//
//  JCSearchVC.swift
//  JioCinema
//
//  Created by SushantAlone on 10/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSearchVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource  ,UISearchBarDelegate, UISearchControllerDelegate {

    var searchViewController:UISearchController? = nil
    var searchModel:SearchDataModel?
    var searchResultArray:[SearchedCategoryItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewCell", bundle: nil), forCellReuseIdentifier: baseTableViewCellReuseIdentifier)
        self.baseTableView.register(UINib.init(nibName: "JCBaseTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: baseHeaderTableViewCellIdentifier)
        baseTableView.delegate = self
        baseTableView.dataSource = self
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        searchResultArray?.removeAll()
        searchResultArray = nil
        searchViewController?.searchBar.text = ""
        baseTableView.reloadData()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        view.setNeedsLayout()
//        view.layoutSubviews()
//        view.layoutIfNeeded()
//        
//    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultArray != nil ? (searchResultArray?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.categoryTitleLabel.text = searchResultArray?[indexPath.row].categoryName
        cell.data = searchResultArray?[indexPath.row].resultItems
        cell.tableCellCollectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340.0
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchResultForkey(with: searchText)
    }

    fileprivate func searchResultForkey(with key:String)
    {
        let url = preditiveSearchURL
        let params:[String:String]? = ["q":key]
        let searchRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .BODY)
        weak var weakself = self
        
        RJILApiManager.defaultManager.post(request: searchRequest) { (data, response, error) in
            if let responseError = error
            {
                self.searchResultArray?.removeAll()
                DispatchQueue.main.async {
                    weakself?.baseTableView.reloadData()
                }
                return
            }
            
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    self.searchModel = SearchDataModel(JSONString: responseString)
                    self.searchResultArray = self.searchModel?.searchData?.categoryItems
                    let searcharr = self.searchResultArray
                    DispatchQueue.main.async {
                        weakself?.baseTableView.reloadData()
                    }
                }
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        // Dispose of any resources that can be recreated.
}
