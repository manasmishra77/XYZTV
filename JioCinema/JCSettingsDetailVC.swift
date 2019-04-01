//
//  JCSettingsDetailVC.swift
//  JioCinema
//
//  Created by Tania Jasam on 8/9/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit


class JCSettingsDetailVC: UIViewController {

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var settingsDetailTitleLabel: UILabel!
    @IBOutlet weak var settingsDetailTextView: UITextView!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var autoPlayView: UIView!
    @IBOutlet weak var autoPlayOrSubtitleLabel: UILabel!
    @IBOutlet weak var autoPlayDescLabel: UILabel!
    
    @IBOutlet weak var onButton: AutoplayButton!
    @IBOutlet weak var offButton: AutoplayButton!
    
    var titleText = ""
    var textViewDetail = ""
    var isFeedBackView = false
    var isDetailView = false
    var isForAutoPlay = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("In Setting Detail Screen Deinit")
    }
    private func configureView() {
        if isFeedBackView {
            feedBackView.isHidden = false
            detailView.isHidden = true
            autoPlayView.isHidden = true
        } else if isDetailView {
            feedBackView.isHidden = true
            detailView.isHidden = false
            autoPlayView.isHidden = true
            
        } else {
            feedBackView.isHidden = true
            detailView.isHidden = true
            autoPlayView.isHidden = false
            autoPlayView.backgroundColor = #colorLiteral(red: 0.08235294118, green: 0.09019607843, blue: 0.07843137255, alpha: 1)
            autoPlayOrSubtitleLabel.text = isForAutoPlay ? AutoPlayHeading : Subtitleheading
            autoPlayDescLabel.isHidden = !isForAutoPlay
        }
        onButton.layer.cornerRadius = 10.0
        offButton.layer.cornerRadius = 10.0
        settingsDetailTextView.isSelectable = true
        settingsDetailTextView.isUserInteractionEnabled = true
        settingsDetailTextView.panGestureRecognizer.allowedTouchTypes = [NSNumber.init(value: UITouch.TouchType.indirect.rawValue)]
        settingsDetailTitleLabel.text = titleText
        settingsDetailTextView.text = textViewDetail
    }
    
    @IBAction func didClickOnTurnOnButton(_ sender: Any) {
        if isForAutoPlay {
            IsAutoPlayOn = true
        } else {
            IsAutoSubtitleOn = true
        }
        self.dismiss(animated: false, completion: nil)

    }
 
    @IBAction func didClickOnTurnOffButton(_ sender: Any) {
        if isForAutoPlay {
            IsAutoPlayOn = false
        } else {
            IsAutoSubtitleOn = false
        }
        self.dismiss(animated: false, completion: nil)
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
