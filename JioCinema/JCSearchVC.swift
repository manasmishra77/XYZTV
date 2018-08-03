//
//  JCSearchVC.swift
//  JioCinema
//
//  Created by SushantAlone on 10/08/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSearchVC: JCBaseVC, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var searchViewController:UISearchController? = nil
    var searchModel:SearchDataModel?
    var searchResultArray = [SearchedCategoryItem]()
    
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
    
    
    /*
    //To be changed
    override func viewDidAppear(_ animated: Bool) {
        let searchViewController = UISearchController.init(searchResultsController: nil)
        searchViewController.searchResultsUpdater = self
        //searchViewController.view.backgroundColor = .black
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.searchBar.tintColor = UIColor.white
        //searchViewController.searchBar.barTintColor = UIColor.black
        searchViewController.searchBar.tintColor = UIColor.gray
        searchViewController.hidesNavigationBarDuringPresentation = false
        //searchViewController.obscuresBackgroundDuringPresentation = false
        //searchViewController.searchBar.delegate = self
        searchViewController.searchBar.searchBarStyle = .minimal
        //self.searchViewController = searchViewController
        self.view.addSubview(searchViewController.searchBar)
        //let searchContainerController = UISearchContainerViewController.init(searchController: searchViewController)
        //searchContainerController.view.backgroundColor = UIColor.black
       // self.present(searchContainerController, animated: false, completion: nil)
    */
   
    
    override func viewDidDisappear(_ animated: Bool)
    {
        searchResultArray.removeAll()
        searchViewController?.searchBar.text = ""
        baseTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchResultForkey(with: searchController.searchBar.text!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchViewController?.extendedLayoutIncludesOpaqueBars = false
        if (searchViewController?.searchBar.text?.characters.count)! > 0
        {
            searchResultForkey(with: (searchViewController?.searchBar.text)!)
        }
      
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count = \(searchResultArray.count)")
        return searchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        print("row is  = \(indexPath.row)")
//        print("array is  = \(searchResultArray)")
//        print("Object is  = \(String(describing: searchResultArray[indexPath.row]))")

        let cell = tableView.dequeueReusableCell(withIdentifier: baseTableViewCellReuseIdentifier, for: indexPath) as! JCBaseTableViewCell
        cell.itemFromViewController = VideoType.Search
        cell.categoryTitleLabel.text = searchResultArray[indexPath.row].categoryName
        cell.data = searchResultArray[indexPath.row].resultItems
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
        print("Text is \(searchText)")
        print("Text Count is \(searchText.characters.count)")
        if searchText.characters.count > 0
        {
            searchResultForkey(with: searchText)
        }
        else
        {
            DispatchQueue.main.async {
                self.searchResultArray.removeAll()
                self.baseTableView.reloadData()
            }
        }
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
                DispatchQueue.main.async {
                    self.searchResultArray.removeAll()
                    weakself?.baseTableView.reloadData()
                }
                return
            }
            
            if let responseData = data
            {
                if let responseString = String(data: responseData, encoding: .utf8)
                {
                    self.searchModel = SearchDataModel(JSONString: responseString)
                    let array = (self.searchModel?.searchData?.categoryItems)!
                    let analyticsData = ["stest" : key, "isvoice": false, "scount" : array.count] as [String : Any]
                    JCMediaAnalytics.manager.trackSearchEventfor(dataDict: analyticsData)
                    if array.count > 0
                    {
                        DispatchQueue.main.async {
                            self.searchResultArray = array
                            weakself?.baseTableView.reloadData()
                        }
                    }
                    else
                    {
                        
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
