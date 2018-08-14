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
    var enterPinViewModel: EnterPinViewModel?
    
    var enterParentalPinView: EnterParentalPinView?
    var setParentalPinView: SetParentalPinView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setBaseView(parentalControlType: .EnterParentalControl, for: "content")
    }
    
    convenience init (with parentalControlType: ParentalConrtrolViewType, for content: String?) {
        self.init()
        self.setBaseView(parentalControlType: parentalControlType, for: content)
    }
    
    private func setBaseView(parentalControlType: ParentalConrtrolViewType, for content: String?)  {
        if parentalControlType == .SetParentalControl {
            setParentalPinView = Utility.getXib("SetParentalPinView", type: SetParentalPinView.self, owner: self)
            self.view.addSubview(setParentalPinView!)
            setParentalViewModel = SetParentalViewModel()
            setParentalViewModel?.getPinForParentalControl(completion: {[unowned self] (pin) in
                self.setPinInView(pin)
            })
        }
        else {
            enterParentalPinView = Utility.getXib("EnterParentalPinView", type: EnterParentalPinView.self, owner: self)
            self.view.addSubview(enterParentalPinView!)
            enterPinViewModel = EnterPinViewModel(contentName: content ?? "")
        }
    }
    
    func setPinInView(_ pin: String) {
        setParentalPinView?.pinLabel.text = pin
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
