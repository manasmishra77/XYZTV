//
//  JCSettingsDetailVC.swift
//  JioCinema
//
//  Created by Tania Jasam on 8/9/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


class JCSettingsDetailVC: UIViewController
{

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var settingsDetailTitleLabel: UILabel!
    @IBOutlet weak var settingsDetailTextView: UITextView!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var autoPlayView: UIView!
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    
    var titleText = ""
    var textViewDetail = ""
    var isFeedBackView = false
    var isDetailView = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if isFeedBackView
        {
            feedBackView.isHidden = false
            detailView.isHidden = true
            autoPlayView.isHidden = true
        }
        else if isDetailView
        {
            feedBackView.isHidden = true
            detailView.isHidden = false
            autoPlayView.isHidden = true

        }
        else
        {
            feedBackView.isHidden = true
            detailView.isHidden = true
            autoPlayView.isHidden = false
        }
        onButton.layer.cornerRadius = 10.0
        offButton.layer.cornerRadius = 10.0
        settingsDetailTextView.isSelectable = true
        settingsDetailTextView.isUserInteractionEnabled = true
        settingsDetailTextView.panGestureRecognizer.allowedTouchTypes = [NSNumber.init(value: UITouchType.indirect.rawValue)]
        settingsDetailTitleLabel.text = titleText
        settingsDetailTextView.text = textViewDetail
        // Do any additional setup after loading the view.
    }
    
   
    
    @IBAction func didClickOnTurnOnButton(_ sender: Any)
    {
        UserDefaults.standard.setValue(true, forKeyPath: isAutoPlayOnKey)
        self.dismiss(animated: false, completion: nil)

    }
 
    @IBAction func didClickOnTurnOffButton(_ sender: Any)
    {
        UserDefaults.standard.setValue(false, forKeyPath: isAutoPlayOnKey)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
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
