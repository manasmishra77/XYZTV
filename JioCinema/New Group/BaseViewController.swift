//
//  BaseViewController.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class BaseViewController<T: BaseViewModel>: UIViewController, UITableViewDataSource, UITableViewDelegate ,JCCarouselCellDelegate , UITabBarControllerDelegate{
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
        if vcType == .disneyHome {
            self.baseViewModel = DisneyHomeViewModel(vcType) as! T
        } else {
            self.baseViewModel = BaseViewModel(vcType) as! T
        }
        super.init(nibName: "BaseViewController", bundle: nil)
        if vcType == .disneyHome || vcType == .disneyMovies || vcType == .disneyTVShow || vcType == .disneyKids {
            self.view.backgroundColor = #colorLiteral(red: 0.02352941176, green: 0.1294117647, blue: 0.2470588235, alpha: 1)
        }
        self.baseViewModel.delegate = self
        self.baseViewModel.fetchData(completion: tableReloadClosure)
        self.tabBarItem = UITabBarItem(title: vcType.rawValue.capitalized, image: nil, tag: 0)
    
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("BaseVC Deinit -)")
        NotificationCenter.default.removeObserver(self, name: addtoWatchlistTappedNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: removefromWatchlistTappedNotificationName, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViews()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callWebServiceWhenItemAddedinWatchlist),
            name: addtoWatchlistTappedNotificationName,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callWebServiceWhenItemRemovedWatchlist),
            name: removefromWatchlistTappedNotificationName,
            object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.delegate = self
    }
    private func configureViews() {
        baseTableView.delegate = self
        baseTableView.dataSource = self
        let cellNib = UINib(nibName: "BaseTableViewCell", bundle: nil)
        baseTableView.register(cellNib, forCellReuseIdentifier: "BaseTableViewCell")
        if viewLoadingStatus == .none || viewLoadingStatus == .viewNotLoadedDataFetchedWithError || viewLoadingStatus == .viewNotLoadedDataFetched  {
            viewLoadingStatus = .viewLoaded
        }
        callWebServiceForWatchlist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseViewModel.reloadTableView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Utility.baseTableViewInBaseViewController(tableView, didUpdateFocusIn: context, with: coordinator)
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseViewModel.countOfTableView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return baseViewModel.heightOfTableRow(indexPath.row)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as? BaseTableViewCell else {
            return UITableViewCell()
        }
        let cellData = baseViewModel.getTableCellItems(for: indexPath.row, completion: tableReloadClosure)
        cell.configureView(cellData, delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return baseViewModel.carouselView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return baseViewModel.heightOfTableHeader()
    }
    
    //ChangingTheAlpha
    var focusShiftedFromTabBarToVC = true
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Utility.changingAlphaTabAbrToVC(carousalView: baseViewModel.carousal, tableView: baseTableView, toChange: &focusShiftedFromTabBarToVC)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Utility.changeAlphaWhenTabBarSelected(baseTableView, carousalView: baseViewModel.carousal, toChange: &focusShiftedFromTabBarToVC)
    }

    
    func callWebServiceForWatchlist(){
        baseViewModel.getDataForWatchList(baseViewModel.vcType)
    }
    func changingDataSourceForBaseTableView() {
        //dataItemsForTableview.removeAll()
        if let disneyData = JCDataStore.sharedDataStore.disneyData?.data {
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
    @objc func callWebServiceWhenItemAddedinWatchlist(){
        baseViewModel.getDataForWatchList(baseViewModel.vcType)
    }
    @objc func callWebServiceWhenItemRemovedWatchlist(){
        baseViewModel.getDataForWatchList(baseViewModel.vcType)
    }
}
extension BaseViewController {
    func showAlert() {
        
    }
}
extension BaseViewController: BaseTableViewCellDelegate {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        guard let tabBarVC = self.tabBarController as? JCTabBarController else {
           //Error handling
            let metadataVC = Utility.sharedInstance.prepareMetadata(item.id!, appType: item.appType, fromScreen: DISNEY_SCREEN, tabBarIndex: 5, isDisney: true)
            self.present(metadataVC, animated: true, completion: nil)
            return
        }
        tabBarVC.presentVC(item, dataType: .disney)
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
