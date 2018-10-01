//
//  BaseViewController.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class BaseViewController<T: BaseViewModel>: UIViewController, UITableViewDataSource, UITableViewDelegate ,JCCarouselCellDelegate{
    var baseViewModel: T
    //var carousalView : InfinityScrollView?
    var isWatchlistAvailable = false
    var dataItemsForTableview = [DataContainer]()
    var viewLoadingStatus: ViewLoadingStatus = .none {
        didSet {
            if viewLoadingStatus == .viewLoaded, ((oldValue == .viewNotLoadedDataFetched) || (oldValue == .viewNotLoadedDataFetchedWithError)) {
                let isSuccess = (oldValue == .viewNotLoadedDataFetched)
                tableReloadClosure(isSuccess)
            }
        }
    }
    
    @IBOutlet weak var baseTableView: UITableView!
    
    lazy var tableReloadClosure: (Bool) -> () = {[unowned self] (isSuccess) in
        //Handle Reponse of APi Call
        print(self.baseViewModel.vcType)
        if self.viewLoadingStatus == .none {
            self.viewLoadingStatus = isSuccess ? .viewNotLoadedDataFetched : .viewNotLoadedDataFetchedWithError
        } else if self.viewLoadingStatus == .completed || self.viewLoadingStatus == .viewLoaded {
            self.viewLoadingStatus = .completed
            if isSuccess {
                DispatchQueue.main.async {
                    self.baseTableView.reloadData()
                }
            } else {
                self.showAlert()
            }
        }
    }
    
    init(_ vcType: BaseVCType) {
//        switch vcType {
//        case .home:
//            self.baseViewModel = HomeViewModel(vcType) as! T
//        default:
        self.baseViewModel = BaseViewModel(vcType) as! T
//        }
        super.init(nibName: "BaseViewController", bundle: nil)
        self.baseViewModel.delegate = self
        self.baseViewModel.fetchData(completion: tableReloadClosure)
        self.tabBarItem = UITabBarItem(title: vcType.rawValue.capitalized, image: nil, tag: 0)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("BaseVC Deinit -)")
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureViews()
        if !JCLoginManager.sharedInstance.isUserLoggedIn(), isWatchlistAvailable{
            isWatchlistAvailable = false
            dataItemsForTableview.remove(at: 0)
            baseTableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    private func configureViews() {
        baseTableView.delegate = self
        baseTableView.dataSource = self
        let cellNib = UINib(nibName: "BaseTableViewCell", bundle: nil)
        baseTableView.register(cellNib, forCellReuseIdentifier: "BaseTableViewCell")
        if viewLoadingStatus == .none || viewLoadingStatus == .viewNotLoadedDataFetchedWithError || viewLoadingStatus == .viewNotLoadedDataFetched  {
            viewLoadingStatus = .viewLoaded
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseViewModel.countOfTableView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as? BaseTableViewCell else {
            return UITableViewCell()
        }
        let cellData = baseViewModel.getTableCellItems(for: indexPath.row, completion: tableReloadClosure)
        print(baseViewModel.getTableCellItems(for: 0, completion: tableReloadClosure    ))
        cell.configureView(cellData, delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return baseViewModel.carouselView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 750
    }
    func changingDataSourceForBaseTableView() {
        //dataItemsForTableview.removeAll()
        if let disneyData = JCDataStore.sharedDataStore.disneyData?.data{
            if !JCLoginManager.sharedInstance.isUserLoggedIn() {
                isWatchlistAvailable = false
            }
            dataItemsForTableview = disneyData
            if dataItemsForTableview[0].isCarousal ?? false {
                dataItemsForTableview.remove(at: 0)
            }
            if isWatchlistAvailable {
                if let watchListData = JCDataStore.sharedDataStore.disneyMovieWatchList?.data?[0], (watchListData.items?.count ?? 0) > 0 {
                
                    dataItemsForTableview.insert(watchListData, at: 0)
                }
            }
        }
        
    }
}
extension BaseViewController {
    func showAlert() {
        
    }
}
extension BaseViewController: BaseTableViewCellDelegate {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        guard let tabBarVC = self.tabBarController as? JCTabBarController else {
            let metadataVC = Utility.sharedInstance.prepareMetadata(item.id!, appType: .Movie, fromScreen: DISNEY_SCREEN, tabBarIndex: 5, isDisney: true)
            self.present(metadataVC, animated: true, completion: nil)
            return
        }
        tabBarVC.presentVC(item)
    }

}

extension BaseViewController: BaseViewModelDelegate {
    func presentMetadataOfIcarousel(_ itemId: Any) {
        if let item = itemId as? Item {
        self.didTapOnItemCell(nil, item)
        }
    }
    
    func presentVC(_ vc: UIViewController) {
        guard let tabBarVC = self.tabBarController as? JCTabBarController else {return}
        tabBarVC.presentDisneySubVC(vc)
    }

}

enum ViewLoadingStatus {
    case viewLoaded
    case viewNotLoadedDataFetched
    case viewNotLoadedDataFetchedWithError
    case none
    case completed
}
