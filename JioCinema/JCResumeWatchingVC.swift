//
//  JCResumeWatchingVC.swift
//  JioCinema
//
//  Created by Tania Jasam on 8/21/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//
/*

import UIKit

class JCResumeWatchingVC: UIViewController
{
    
    @IBOutlet weak var resumeWatchingButton: UIButton!
    var playableItemDuration = 0
    var playerId:String?
    var itemTitle:String?
    var itemDescription:String?
    var itemImage:String?
    var itemDuration:String?
    var isVideoResumed = false
    var previousVC: UIViewController? = nil
    
    var item :Any?


    override func viewDidLoad()
    {
        super.viewDidLoad()
        let hour = playableItemDuration/3600
        let hoursRem = playableItemDuration % 3600
        let minutes = hoursRem/60
        let seconds = hoursRem % 60
        resumeWatchingButton.setTitle(String.init(format: "Resume Watching (%0.2d:%0.2d:%0.2d)", hour, minutes, seconds), for: .normal)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func didClickOnResumeWatching(_ sender: Any)
    {
        isVideoResumed = true
        self.playVideo()
    }
    
    
    @IBAction func didClickOnBeginningButton(_ sender: Any)
    {
        isVideoResumed = false
        self.playVideo()

    }

    
    @IBAction func didClickOnRemoveButton(_ sender: Any)
    {
        self.callWebServiceForRemovingResumedWatchlist()
    }
    
    func playVideo()
    {
       /* if playerVC_Global != nil {
            return
        }
        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        playerVC.currentItemDescription = itemDescription
        playerVC.currentItemTitle = itemTitle
        playerVC.currentItemImage = itemImage
        playerVC.currentItemDuration = itemDuration
       // playerVC.callWebServiceForPlaybackRights(id: playerId!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        playerVC.duration = Double(playableItemDuration)
        playerVC.isResumed = isVideoResumed
        
        playerVC.item = self.item
        self.dismiss(animated: false, completion: {
            print(self.previousVC)
            self.previousVC?.present(playerVC, animated: false, completion: nil)
            
        })*/
//        if isVideoResumed{
//            //self.present(playerVC, animated: false, completion: nil)
//            self.dismiss(animated: false, completion: {
//                self.previousVC?.present(playerVC, animated: false, completion: nil)
//
//            })
//        }
//        else{
//            self.dismiss(animated: false, completion: {
//                self.previousVC?.present(playerVC, animated: false, completion: nil)
//            })
//        }
        
    }
    
    func callWebServiceForRemovingResumedWatchlist()
    {
        let json = ["id":playerId]
        let params = ["uniqueId":JCAppUser.shared.unique,"listId":"10","json":json] as [String : Any]
        let url = removeFromResumeWatchlistUrl
        let removeRequest = RJILApiManager.defaultManager.prepareRequest(path: url, params: params, encoding: .JSON)
        weak var weakSelf = self
        RJILApiManager.defaultManager.post(request: removeRequest) { (data, response, error) in
            
            if let responseError = error
            {
                print(responseError)
                return
            }
            
            if let responseData = data, let parsedResponse:[String:Any] = RJILApiManager.parse(data: responseData)
            {
                let code = parsedResponse["code"]
                print("Removed from Resume Watchlist \(String(describing: code))")
                //Removing data from resume wathching screen
                JCDataStore.sharedDataStore.resumeWatchList?.data?.items = JCDataStore.sharedDataStore.resumeWatchList?.data?.items?.filter() { $0.id != self.playerId }
                
                DispatchQueue.main.async {
                    if let homeVC = JCAppReference.shared.tabBarCotroller?.viewControllers![0] as? JCHomeVC{
                        let index = IndexPath(row: 0, section: 0)
                        if let items = JCDataStore.sharedDataStore.resumeWatchList?.data?.items{
                            if items.count > 0{
                                homeVC.isResumeWatchDataAvailable = true
                                homeVC.baseTableView.reloadRows(at: [index], with: .fade)
                            }else{
                                homeVC.isResumeWatchDataAvailable = false
                            }
                        }else{
                            homeVC.isResumeWatchDataAvailable = true
                        }
                    }
                    weakSelf?.dismiss(animated: false, completion: nil)
                }
            }
        }

    }
   

}
*/
