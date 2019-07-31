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
//    var carousalView : ViewForCarousel?
    var dataItemsForTableview = [DataContainer]()
    var resumeWatchListDataAvailable = false
    var isMetadataScreenToBePresentedFromResumeWatchCategory: Bool = false
    var viewLoadingStatus: ViewLoadingStatus = .none {
        didSet {
            if viewLoadingStatus == .viewLoaded, ((oldValue == .viewNotLoadedDataFetched) || (oldValue == .viewNotLoadedDataFetchedWithError)) {
                let isSuccess = (oldValue == .viewNotLoadedDataFetched)
                tableReloadClosure(isSuccess)
            }
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var customHeaderHolderView: UIView!
    @IBOutlet weak var baseTableView: UITableView!
    @IBOutlet weak var topConstraintOfTableView: NSLayoutConstraint!
    @IBOutlet weak var baseTableLeadingConstraint: NSLayoutConstraint!
    
    var customHeaderView: HeaderView?
    var timerToSetImage: Timer?
    
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
        super.init(nibName: BaseViewControllerNibIdentifier, bundle: nil)
        self.tabBarItem = UITabBarItem(title: vcType.name, image: nil, tag: 0)
        self.view.backgroundColor = ViewColor.commonBackground
        if vcType == .disneyHome || vcType == .disneyMovies || vcType == .disneyTVShow || vcType == .disneyKids {
            self.view.backgroundColor = ViewColor.disneyBackground
        }
        self.baseViewModel.delegate = self
        self.baseViewModel.fetchData(completion: tableReloadClosure)
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
    
    override func viewWillAppear(_ animated: Bool) {
        if isMetadataScreenToBePresentedFromResumeWatchCategory {
            isMetadataScreenToBePresentedFromResumeWatchCategory = false
            let coverView = UIView(frame: sideNavigationVC?.view.bounds ?? CGRect.zero)
            if self.baseViewModel.vcType.isDisney {
               coverView.backgroundColor = ViewColor.disneyBackground
            } else {
                coverView.backgroundColor = ViewColor.commonBackground
            }
            sideNavigationVC?.view.addSubview(coverView)
            sideNavigationVC?.view.bringSubviewToFront(coverView)
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                coverView.removeFromSuperview()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
            if self.baseViewModel.isToReloadTableViewAfterLoginStatusChange {
                self.baseViewModel.reloadTableView()
            }
    }
    
    private func configureViews() {
        baseTableView.delegate = self
        baseTableView.dataSource = self
        let cellNib = UINib(nibName: BaseTableCellNibIdentifier, bundle: nil)
        baseTableView.register(cellNib, forCellReuseIdentifier: BaseTableCellNibIdentifier)
        baseTableLeadingConstraint.constant = baseViewModel.leadingConstraintBaseTable()
        if viewLoadingStatus == .none || viewLoadingStatus == .viewNotLoadedDataFetchedWithError || viewLoadingStatus == .viewNotLoadedDataFetched  {
            viewLoadingStatus = .viewLoaded
        }
        if customHeaderView == nil {
            customHeaderView = UINib(nibName: "HeaderView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? HeaderView
            customHeaderView?.frame = customHeaderHolderView.bounds
            addGradientView()
            customHeaderHolderView.addSubview(customHeaderView!)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addGradientView() {
        let colorLayer = CAGradientLayer()
        colorLayer.frame = backgroundImageView.bounds
        colorLayer.colors = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor , UIColor.black.withAlphaComponent(0.3).cgColor]
        colorLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        colorLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        let colorLayer2 = CAGradientLayer()
        colorLayer2.frame = backgroundImageView.bounds
        colorLayer2.colors = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black.cgColor]
        colorLayer2.endPoint = CGPoint(x: 0.0, y: 1.0)
        colorLayer2.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.backgroundImageView.layer.insertSublayer(colorLayer, at:0)
        self.backgroundImageView.layer.insertSublayer(colorLayer2, at:1)
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        
        Utility.baseTableViewInBaseViewController(tableView, didUpdateFocusIn: context, with: coordinator)
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
        return baseViewModel.countOfTableView
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return baseViewModel.heightOfTableRow(indexPath)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BaseTableCellNibIdentifier, for: indexPath) as? BaseTableViewCell else {
            return UITableViewCell()
        }
        let cellData = baseViewModel.getTableCellItems(for: indexPath.row, completion: tableReloadClosure)
        if let urlString = baseViewModel.baseDataModel?.data?[0].items?[0].imageUrlOfTvStillImage{
            let url = URL(string: urlString)
            backgroundImageView.sd_setImage(with: url)
        }
        cell.configureView(cellData, delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
//            return baseViewModel.carouselView
        } else {
            return baseViewModel.buttonView()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return baseViewModel.heightOfTableHeader(section: section)
    }
    
    //new UI changes
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedItem is HeaderButtons {
            updateUiAndFocus(toFullScreen: true, context: context)
        } else {
            updateUiAndFocus(toFullScreen: false, context: context)
        }
    }
    
    
    func updateUiAndFocus(toFullScreen: Bool, context: UIFocusUpdateContext) {
        self.backgroundImageView.isHidden = !toFullScreen
        customHeaderView?.imageViewForHeader.isHidden = toFullScreen
        let alphaChange : CGFloat = toFullScreen ? 1.0 : 0.001
        self.customHeaderView?.playButton.alpha = alphaChange
        self.customHeaderView?.moreInfoButton.alpha = alphaChange
        self.customHeaderView?.titleLabel.alpha = alphaChange
        let topConstraint : CGFloat = toFullScreen ? 700 : 500
        UIView.animate(withDuration: 0.3) {
            self.topConstraintOfTableView.constant = topConstraint
            self.view.layoutIfNeeded()
        }
    }

    //ChangingTheAlpha
    var focusShiftedFromTabBarToVC = true
    
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        Utility.changingAlphaTabAbrToVC(carousalView: baseViewModel.carousal, tableView: baseTableView, toChange: &focusShiftedFromTabBarToVC)
//    }
//    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        Utility.changeAlphaWhenTabBarSelected(baseTableView, carousalView: baseViewModel.carousal, toChange: &focusShiftedFromTabBarToVC)
//    }
}
extension BaseViewController {
    func showAlert() {
        
    }
}
extension BaseViewController: BaseTableViewCellDelegate {
    func didTapOnCharacterItem(_ baseCell: BaseTableViewCell?, _ charItem: DisneyCharacterItems) {
        let selectedIndexPath: IndexPath? = (baseCell != nil) ? self.baseTableView.indexPath(for: baseCell!) : nil
        baseViewModel.charItemCellTapped(charItem, selectedIndexPath: selectedIndexPath)
    }
    
    func didTapOnItemCell(_ baseCell: BaseTableViewCell?, _ item: Item) {
        let selectedIndexPath: IndexPath? = (baseCell != nil) ? self.baseTableView.indexPath(for: baseCell!) : nil
        baseViewModel.itemCellTapped(item, selectedIndexPath: selectedIndexPath)
        
    }
    
    func updateHeaderImage(_ url: String) {
        self.timerToSetImage?.invalidate()
        self.timerToSetImage = nil
        self.timerToSetImage = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {[weak self] (timer) in
            guard let self = self else {return}
            let url = URL(string: url)
            
            UIView.transition(with: self.customHeaderView!.imageViewForHeader ,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.customHeaderView?.imageViewForHeader.sd_setImage(with: url) },
                              completion: nil)
        }
//        let url = URL(string: url)
//        customHeaderView?.imageViewForHeader.sd_setImage(with: url)
    }
    
}

extension BaseViewController: BaseViewModelDelegate {
    func presentMetadataOfIcarousel(_ itemId: Any) {
        if let item = itemId as? Item {
            self.didTapOnItemCell(nil, item)
        }
    }
    
    func presentVC(_ vc: UIViewController) {
            self.present(vc, animated: true, completion: nil)
//        guard let tabBarVC = self.tabBarController as? JCTabBarController else {
//            // For DisneyKids, Disney Movies, Disney TVShow
//            self.present(vc, animated: true, completion: nil)
//            return
//        }
//        tabBarVC.presentDisneySubVC(vc)
    }

}

enum ViewLoadingStatus {
    case viewLoaded
    case viewNotLoadedDataFetched
    case viewNotLoadedDataFetchedWithError
    case none
    case completed
}
