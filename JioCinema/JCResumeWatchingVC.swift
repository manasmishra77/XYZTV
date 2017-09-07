//
//  JCResumeWatchingVC.swift
//  JioCinema
//
//  Created by Tania Jasam on 8/21/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

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
        let playerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: playerVCStoryBoardId) as! JCPlayerVC
        playerVC.currentItemDescription = itemDescription
        playerVC.currentItemTitle = itemTitle
        playerVC.currentItemImage = itemImage
        playerVC.currentItemDuration = itemDuration
        playerVC.callWebServiceForPlaybackRights(id: playerId!)
        playerVC.modalPresentationStyle = .overFullScreen
        playerVC.modalTransitionStyle = .coverVertical
        playerVC.duration = Double(playableItemDuration)
        playerVC.isResumed = isVideoResumed
        
        self.present(playerVC, animated: false, completion: nil)
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
                DispatchQueue.main.async {
                    weakSelf?.dismiss(animated: false, completion: nil)
                }
            }
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
