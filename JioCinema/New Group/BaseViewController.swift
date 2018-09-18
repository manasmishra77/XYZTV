//
//  BaseViewController.swift
//  JioCinema
//
//  Created by Manas Mishra on 18/08/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class BaseViewController<T: BaseViewModel>: UIViewController, UITableViewDataSource, UITableViewDelegate, JCCarouselCellDelegate {
    var baseViewModel: T
    var carousalView : InfinityScrollView?
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
        cell.configureView(cellData, delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.baseViewModel.vcType == .disneyHome{
            let carouselViewForDisney = Bundle.main.loadNibNamed("CarouselViewForDisney", owner: self, options: nil)?.first as! CarouselViewForDisney

            if carousalView == nil {
                if let items = JCDataStore.sharedDataStore.disneyData?.data?[0].items{
                    carousalView = Utility.getHeaderForTableView(for: self, with: items)
                    carousalView?.frame = CGRect(x: 0, y: 0, width: 1920, height: 650)
                }
            }
            carouselViewForDisney.viewForCarousel.addSubview(carousalView!)
            return carouselViewForDisney
        } else {
            if carousalView == nil {
                if let items = JCDataStore.sharedDataStore.disneyData?.data?[0].items {
                    carousalView = Utility.getHeaderForTableView(for: self, with: items)
                }
            }
            return carousalView
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 750
    }
}
extension BaseViewController {
    func showAlert() {
        
    }
}
extension BaseViewController: BaseTableViewCellDelegate {
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        guard let tabBarVC = self.tabBarController as? JCTabBarController else {return}
        tabBarVC.presentVC(item)
    }
}



enum ViewLoadingStatus {
    case viewLoaded
    case viewNotLoadedDataFetched
    case viewNotLoadedDataFetchedWithError
    case none
    case completed
}
