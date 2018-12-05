//
//  BaseViewController.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class BaseViewController<T: BaseViewModel>: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {
    var baseViewModel: T
    //var carousalView : InfinityScrollView?
    var dataItemsForTableview = [DataContainer]()
    var resumeWatchListDataAvailable = false
    var viewLoadingStatus: ViewLoadingStatus = .none {
        didSet {
            if viewLoadingStatus == .viewLoaded, ((oldValue == .viewNotLoadedDataFetched) || (oldValue == .viewNotLoadedDataFetchedWithError)) {
                let isSuccess = (oldValue == .viewNotLoadedDataFetched)
                tableReloadClosure(isSuccess)
            }
        }
    }
    
    @IBOutlet weak var baseTableView: UITableView!
    
    lazy var tableReloadClosure: (Bool) -> () = {[weak self] (isSuccess) in
        guard let self = self else {return}
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
        switch vcType {
        case .home:
            self.baseViewModel = CommonHomeViewModel(vcType) as! T
        case .disneyHome:
            self.baseViewModel = DisneyHomeViewModel(vcType) as! T
        default:
            self.baseViewModel = BaseViewModel(vcType) as! T
        }
        super.init(nibName: "BaseViewController", bundle: nil)
        self.tabBarItem = UITabBarItem(title: vcType.name, image: nil, tag: 0)
        self.view.backgroundColor = #colorLiteral(red: 0.1068576351, green: 0.1179018542, blue: 0.1013216153, alpha: 1)
        if vcType == .disneyHome || vcType == .disneyMovies || vcType == .disneyTVShow || vcType == .disneyKids {
            self.view.backgroundColor = #colorLiteral(red: 0.02352941176, green: 0.1294117647, blue: 0.2470588235, alpha: 1)
        }
        self.baseViewModel.delegate = self
        self.baseViewModel.fetchData(completion: tableReloadClosure)
//        self.tabBarItem = UITabBarItem(title: "Disney", image: nil, tag: 0)

    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("BaseVC Deinit -)")
        NotificationCenter.default.removeObserver(self, name: WatchlistUpdatedNotificationName, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViews()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callWebServiceWhenWatchlistUpdated),
            name: WatchlistUpdatedNotificationName,
            object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.delegate = self
//        if !JCLoginManager.sharedInstance.isUserLoggedIn(), resumeWatchListDataAvailable {
//            resumeWatchListDataAvailable = false
//            baseViewModel.reloadTableView()
//        }
        if baseViewModel.isToReloadTableViewAfterLoginStatusChange {
            self.baseViewModel.reloadTableView()
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
        callWebServiceForWatchlist()
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

    
    func callWebServiceForWatchlist() {
        if let viewModel = baseViewModel as? DisneyHomeViewModel {
            viewModel.getDataForWatchListForDisneyMovieAndTv(baseViewModel.vcType)
        }
    }
    @objc func callWebServiceWhenWatchlistUpdated() {
            RJILApiManager.getWatchListData(isDisney: true, type: baseViewModel.vcType) { (isSuccess, errorMsg) in
                guard isSuccess else {return}
                self.baseViewModel.reloadTableView()
            }
    }
}
extension BaseViewController {
    func showAlert() {
        
    }
}
extension BaseViewController: BaseTableViewCellDelegate {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        let selectedIndexPath: IndexPath? = (baseCell != nil) ? self.baseTableView.indexPath(for: baseCell!) : nil
        baseViewModel.itemCellTapped(item, selectedIndexPath: selectedIndexPath)
        return
        guard let tabBarVC = self.tabBarController as? JCTabBarController else {
            // For DisneyKids, Disney Movies, Disney TVShow
            let metadataVC = Utility.sharedInstance.prepareMetadata(item.id!, appType: item.appType, fromScreen: DISNEY_SCREEN, categoryName: "", categoryIndex: 0, tabBarIndex: 5, isDisney: true)
            self.present(metadataVC, animated: true, completion: nil)
            return
        }
        //tabBarVC.presentVC(item, dataType: .disney)
    }

}

extension BaseViewController: BaseViewModelDelegate {
    func presentMetadataOfIcarousel(_ itemId: Any) {
        if let item = itemId as? Item {
            self.didTapOnItemCell(nil, item)
        }
    }
    
    func presentVC(_ vc: UIViewController) {
        guard let tabBarVC = self.tabBarController as? JCTabBarController else {
            // For DisneyKids, Disney Movies, Disney TVShow
            self.present(vc, animated: true, completion: nil)
            return
        }
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
