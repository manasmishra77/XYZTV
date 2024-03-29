//
//  ParentalControlVC.swift
//  JioCinema
//
//  Created by Vinit Somani on 8/13/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

enum ParentalConrtrolViewType {
    case SetParentalControl
    case EnterParentalControl
}

class ParentalControlVC: UIViewController {

    var setParentalViewModel: SetParentalViewModel?
    var setParentalPinView: SetParentalPinView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        sendParentalControlTileEvent()
    }
    
    func sendParentalControlTileEvent() {
        // For Clever Tap Event
        let eventProperties = ["platform":"TVOS"]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Parental Control Tile", properties: eventProperties)
        
        // For Internal Analytics Event
        let parentalPinTileEvent = JCAnalyticsEvent.sharedInstance.getParentalControlTileEvent()
        JCAnalyticsEvent.sharedInstance.sendEventForInternalAnalytics(paramDict: parentalPinTileEvent)
    }
    
    fileprivate func configureView() {
        setParentalPinView = Utility.getXib("SetParentalPinView", type: SetParentalPinView.self, owner: self)
        self.view.addSubview(setParentalPinView!)
        self.setPinInView("")
        setParentalViewModel = SetParentalViewModel()
        Utility.sharedInstance.showIndicator()
        setParentalViewModel?.getPinForParentalControl(completion: {[weak self] (pin) in
            guard let self = self else {return}
            Utility.sharedInstance.hideIndicator()
            if let pin = pin {
                self.setPinInView(pin)
            } else {
                Utility.sharedInstance.showAlert(viewController: self, title: "Server Error", message: "")
            }
        })
    }
    
    func setPinInView(_ pin: String) {
        setParentalPinView?.configureParentalPinView(pin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
