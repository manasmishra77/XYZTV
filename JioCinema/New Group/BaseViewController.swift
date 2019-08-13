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
    weak var indicator: SpiralSpinner?
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
    
    @IBOutlet weak var baseTableViewHeight: NSLayoutConstraint!
    
    
    
    
    var lastFocusableItem: UIView?
    
    var customHeaderView: HeaderView?
    var timerToSetImage: Timer?
    var gradientColor : UIColor = ViewColor.commonBackground
    
    lazy var tableReloadClosure: (Bool) -> () = {[weak self] (isSuccess) in
        guard let self = self else {return}
        //Handle Reponse of APi Call
        if self.viewLoadingStatus == .none {
            self.viewLoadingStatus = isSuccess ? .viewNotLoadedDataFetched : .viewNotLoadedDataFetchedWithError
        } else if self.viewLoadingStatus == .completed || self.viewLoadingStatus == .viewLoaded {
            self.viewLoadingStatus = .completed
            if isSuccess {
                DispatchQueue.main.async {
                    self.loadMainViewBgDetails()
                    self.baseTableView.reloadData()
                    self.baseTableView.contentSize.height = self.baseTableView.contentSize.height + 100
                }
            } else {
                self.showAlert()
            }
        }
    }
    
    func loadMainViewBgDetails() {
        if let headerItem = baseViewModel.baseDataModel?.data?[0].items?[0]{
            let title = headerItem.name == "" ? headerItem.showname : headerItem.name
            setHeaderValues(item: lastFocusableItem, urlString: headerItem.imageUrlOfTvStillImage, title: title ?? "", description: headerItem.description ?? "", toFullScreen: true, mode: .scaleAspectFill)
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
    
    var sideNavigationVC: SideNavigationVC? {
        return AppManager.shared.sideNavigationVC
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
        if #available(tvOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onFocusFailed(_:)), name: NSNotification.Name(rawValue: UIFocusSystem.movementDidFailNotification.rawValue), object: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.baseViewModel.isToReloadTableViewAfterLoginStatusChange {
            self.baseViewModel.reloadTableView()
        }
    }
    
    private func configureViews() {
        //This is used when user comes to app using deeplinking
        if AppManager.shared.isComingFromDeepLinking, baseViewModel.vcType == .home {
            self.updateIndicatorState(toStart: true, present: AppManager.shared.sideNavigationVC?.view)
            self.processForDeepLinking()
        } else {
            self.configureTableView()
        }
    }
    
    private func processForDeepLinking() {
        if let deepLinkedItem = AppManager.shared.deepLinkingItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                self.baseViewModel.itemCellTapped(deepLinkedItem, selectedIndexPath: nil, isFromCarousal: true)
                AppManager.shared.setForDeepLinkingItem(isFromDL: false, item: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.configureTableView()
                }
            }
        } else {
            self.configureTableView()
        }
    }
    
    private func configureTableView() {
        self.updateIndicatorState(toStart: false)
        baseTableView.delegate = self
        baseTableView.dataSource = self
        let cellNib = UINib(nibName: BaseTableCellNibIdentifier, bundle: nil)
        baseTableView.register(cellNib, forCellReuseIdentifier: BaseTableCellNibIdentifier)
        baseTableLeadingConstraint.constant = baseViewModel.leadingConstraintBaseTable()
        if viewLoadingStatus == .none || viewLoadingStatus == .viewNotLoadedDataFetchedWithError || viewLoadingStatus == .viewNotLoadedDataFetched  {
            viewLoadingStatus = .viewLoaded
        }
        gradientColor = baseViewModel.vcType.isDisney ? ViewColor.disneyBackground : ViewColor.commonBackground
        if customHeaderView == nil {
            customHeaderView = UINib(nibName: "HeaderView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? HeaderView
            customHeaderView?.frame = customHeaderHolderView.bounds
            print(baseViewModel.vcType.isDisney)
            customHeaderView?.headerViewDelegate = self
            if baseViewModel.vcType == .music || baseViewModel.vcType == .clip {
                customHeaderView?.heightOfMoreIfoButton.constant = 0
            } else {
                customHeaderView?.heightOfMoreIfoButton.constant = 63
            }
            self.customHeaderView?.layoutIfNeeded()
            customHeaderView?.addGradientToHeader(color: gradientColor)
            customHeaderView?.imageViewForHeader.isHidden = true
            addGradientView()
            customHeaderHolderView.addSubview(customHeaderView!)
            
            lastFocusableItem = customHeaderView?.playButton
        }
    }
    
    private func updateIndicatorState(toStart: Bool, present onView: UIView? = nil) {
        let spinnerColor: UIColor = ThemeManager.shared.selectionColor
        let bgColor = ThemeManager.shared.backgroundColor
        if toStart {
            DispatchQueue.main.async {
                if self.indicator != nil {
                    return
                }
                let indicator = IndicatorManager.shared.addAndStartAnimatingANewIndicator(spinnerColor: spinnerColor, superView: onView ?? self.view, superViewSize: (onView ?? self.view).frame.size, spinnerSize: CGSize(width: 100, height: 100), spinnerWidth: 10, superViewUserInteractionEnabled: false, shouldUseCoverLayer: true, coverLayerOpacity: 1, coverLayerColor: bgColor)
                self.indicator = indicator
                onView?.bringSubviewToFront(indicator)
            }
        } else {
            DispatchQueue.main.async {
                IndicatorManager.shared.stopSpinningIndependent(spinnerView: self.indicator)
                self.indicator = nil
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addGradientView() {
        var startPoint = CGPoint(x: 1.0, y: 0.0)
        var endPoint = CGPoint(x: 0.0, y: 0.0)
        var colorsArray = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,gradientColor.withAlphaComponent(0.3).cgColor, gradientColor.withAlphaComponent(0.6).cgColor , gradientColor.cgColor]
        Utility.applyGradient(backgroundImageView, startPoint: startPoint, endPoint: endPoint, colorArray: colorsArray)
        
        
        startPoint = CGPoint(x: 0.0, y: 0.0)
        endPoint = CGPoint(x: 0.0, y: 1.0)
        colorsArray = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, gradientColor.withAlphaComponent(0.5).cgColor, gradientColor.cgColor]
        Utility.applyGradient(backgroundImageView, startPoint: startPoint, endPoint: endPoint, colorArray: colorsArray, atIndex: 1)
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        print("context == \(context)")
        if baseViewModel.vcType == .search {
            Utility.baseTableViewInBaseViewController(tableView, didUpdateFocusIn: context, with: coordinator)
        }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            DispatchQueue.main.async {
                if let cell = cell as? BaseTableViewCell {
                    cell.itemCollectionView?.contentOffset = CGPoint.init(x: 0, y: 0)
                }
            }
    }
    
    //new UI changes
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
            if (context.previouslyFocusedItem is HeaderButtons || context.previouslyFocusedItem is SideNavigationTableCell || context.previouslyFocusedItem is JCDisneyButton) && context.nextFocusedItem is ItemCollectionViewCell {
                updateUiAndFocus(toFullScreen: false, context: context)
            }

        if context.nextFocusedItem is SideNavigationTableCell && (context.previouslyFocusedView is ItemCollectionViewCell  || context.previouslyFocusedView is HeaderButtons || context.previouslyFocusedView is JCDisneyButton){
            baseTableView.alpha = 0.2
            customHeaderView?.playButton.alpha = 0.2
            customHeaderView?.moreInfoButton.alpha = 0.2
            customHeaderView?.titleLabel.alpha = 0.2
            customHeaderView?.descriptionLabel.alpha = 0.2
        } else {
            baseTableView.alpha = 1
            customHeaderView?.playButton.alpha = 1
            customHeaderView?.moreInfoButton.alpha = 1
            customHeaderView?.titleLabel.alpha = 1
            customHeaderView?.descriptionLabel.alpha = 1
        }
    }
    
    
    func updateUiAndFocus(toFullScreen: Bool, context: UIFocusUpdateContext) {
        self.backgroundImageView.isHidden = !toFullScreen
        customHeaderView?.imageViewForHeader.isHidden = toFullScreen
        self.customHeaderView?.playButton.isHidden = !toFullScreen
        self.customHeaderView?.moreInfoButton.isHidden = !toFullScreen
        let heightConstraint : CGFloat = toFullScreen ? rowHeightForLandscapeWithLabels * 1.1 : self.view.frame.height - rowHeightForLandscapeWithLabels * 1.25
        
        let topConstraintOfDesciption : CGFloat = toFullScreen ? 129 : 10
        UIView.animate(withDuration: 0.3) {
            self.baseTableViewHeight.constant = heightConstraint
            self.customHeaderView?.topConstraintOfDescription.constant = topConstraintOfDesciption
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func onFocusFailed(_ notification:Notification) {
        if let contextDict = notification.userInfo as? [String: UIFocusUpdateContext], let context = contextDict["UIFocusUpdateContextKey"] {
            if context.previouslyFocusedItem is ItemCollectionViewCell || context.previouslyFocusedItem is JCDisneyButton {
                if (context.focusHeading == .up) {
                    DispatchQueue.main.async {
                        
                        if let headerItem = self.baseViewModel.baseDataModel?.data?[0].items?[0] {
                            let title = headerItem.name == "" ? headerItem.showname : headerItem.name
                            self.setHeaderValues(item: self.customHeaderView?.playButton, urlString: nil, title: title ?? "", description: headerItem.description ?? "", toFullScreen: true, mode: .scaleAspectFill)
                        }
                        self.customHeaderView?.imageViewForHeader.isHidden = true
                        self.backgroundImageView.isHidden = false
                        self.customHeaderView?.playButton.isHidden = false
                        self.customHeaderView?.moreInfoButton.isHidden = false
                        UIView.animate(withDuration: 0.3) {
                            self.baseTableViewHeight.constant = rowHeightForLandscapeWithLabels * 1.1
                            self.customHeaderView?.topConstraintOfDescription.constant = 130
                            self.view.layoutIfNeeded()
                        }
                        self.updateFocusIfNeeded()
                        self.setNeedsFocusUpdate()
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         lastFocusableItem = nil
        if #available(tvOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UIFocusSystem.movementDidFailNotification.rawValue), object: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
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
    
    func setHeaderValues(item: UIView?, urlString: String?, title: String, description: String, toFullScreen: Bool, mode: UIImageView.ContentMode) {
        
        lastFocusableItem = item
        var url : URL?
        if let urlString = urlString {
            url = URL(string: urlString)
        }
        
        self.customHeaderView?.imageViewForHeader.contentMode = mode
        
        if toFullScreen {
            if url != nil {
                self.backgroundImageView.sd_setImage(with: url)
            }
            self.customHeaderView?.titleLabel.text = title
            self.customHeaderView?.descriptionLabel.text = description
        } else {
            self.timerToSetImage?.invalidate()
            self.timerToSetImage = nil
            self.customHeaderView?.titleLabel.text = title
            self.customHeaderView?.descriptionLabel.text = description
            self.timerToSetImage = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) {[weak self] (timer) in
                guard let self = self else {return}
            
                UIView.transition(with: self.customHeaderView!.imageViewForHeader ,
                                  duration:0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.customHeaderView?.imageViewForHeader.sd_setImage(with: url)
                },
                                  completion: nil)
            }
        }

    }
    
}

extension BaseViewController: HeaderViewDelegate {
    func playButtonTapped() {
        if let item = baseViewModel.baseDataModel?.data?[0].items?[0] {
            self.baseViewModel.itemCellTapped(item, selectedIndexPath: IndexPath(item: 0, section: 0), shouldDirectPlay: true)
        }
    }
    
    func moreInfoButtonTapped() {
        if let item = baseViewModel.baseDataModel?.data?[0].items?[0] {
             self.baseViewModel.itemCellTapped(item, selectedIndexPath: IndexPath(item: 0, section: 0))
        }
    }
}

extension BaseViewController: BaseViewModelDelegate {
    func presentMetadataOfIcarousel(_ itemId: Any) {
        if let item = itemId as? Item {
            self.didTapOnItemCell(nil, item)
        }
    }
    
    func presentVC(_ vc: UIViewController) {
        self.present(vc, animated: false, completion: nil)
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
