//
//  JCSettingsVC.swift
//  JioCinema
//
//  Created by Tania Jasam on 8/9/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit

class JCSettingsVC: UIViewController {
    
    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JCAppUser.shared = JCLoginManager.sharedInstance.getUserFromDefaults()
        headerLabel.isHidden = true
        settingsTableView.register(UINib(nibName: "JCSettingsTableViewCell", bundle: nil), forCellReuseIdentifier: SettingCellIdentifier)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        settingsTableView.reloadData()
        
        //Clevertap Navigation Event
        let eventProperties = ["Screen Name": "Settings", "Platform": "TVOS","Metadata Page": ""]
        JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Navigation", properties: eventProperties)
    }
    override func viewDidDisappear(_ animated: Bool) {

    }
   
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        print("In Setting Screen Deinit")
    }
    
    
}

extension JCSettingsVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: SettingCellIdentifier, for: indexPath) as! JCSettingsTableViewCell
        cell.textLabel?.textColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        cell.cellAccessoryImage.isHidden = false
        cell.settingsDetailLabel.isHidden = true
        cell.isUserInteractionEnabled = true
        cell.setCellTag(forCell: indexPath.row)
        if cell.isFocused {
            cell.baseView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        } else {
            cell.baseView.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        }

        
        switch indexPath.row {
        case 0:
            if JCLoginManager.sharedInstance.isUserLoggedIn() {
                cell.textLabel?.text = "Logout"
                cell.settingsDetailLabel.isHidden = false
                cell.settingsDetailLabel.text = JCAppUser.shared.commonName
            } else {                
                cell.textLabel?.text = "Sign In"
            }
            
        case 1:
            cell.textLabel?.text = AutoPlayHeading
            cell.settingsDetailLabel.isHidden = false
            
            if IsAutoPlayOn {
                cell.settingsDetailLabel.text = "ON"
            } else {
                cell.settingsDetailLabel.text = "OFF"
            }
        case 2:
            cell.textLabel?.text = Subtitleheading
            cell.settingsDetailLabel.isHidden = false
            
            if IsAutoSubtitleOn {
                 cell.settingsDetailLabel.text = "ON"
            } else {
                cell.settingsDetailLabel.text = "OFF"
            }
            
        case 3:
            cell.textLabel?.text = "FAQs"
            
        case 4:
            cell.textLabel?.text = "Feedback"
            
        case 5:
            cell.textLabel?.text = "Privacy Policy"
            
        case 6:
            cell.textLabel?.text = "Terms & Conditions"
            
        case 7:
            cell.cellAccessoryImage.isHidden = true
            cell.textLabel?.text = "Version"
            cell.settingsDetailLabel.isHidden = false
            cell.settingsDetailLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            cell.isUserInteractionEnabled = false
            
        default:
            break
        }
        return cell
    }
    
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        headerLabel.isHidden = false
        
        if let nextFocussedCell = context.nextFocusedView as? JCSettingsTableViewCell {
            nextFocussedCell.baseView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            nextFocussedCell.textLabel?.textColor = #colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1)
            nextFocussedCell.settingsDetailLabel.textColor = #colorLiteral(red: 0.8509803922, green: 0, blue: 0.5529411765, alpha: 1)
            nextFocussedCell.cellAccessoryImage.image = #imageLiteral(resourceName: "ArrowPink.png")
            
            switch nextFocussedCell.cellIndexpath {
            case 0:
                headerLabel.isHidden = false
                if JCLoginManager.sharedInstance.isUserLoggedIn() {
                    self.settingsImageView.image = #imageLiteral(resourceName: "Logout.png")
                } else {
                    self.settingsImageView.image = #imageLiteral(resourceName: "MyAccount.png")
                }
                
            case 1:
                self.settingsImageView.image = #imageLiteral(resourceName: "Autoplay.png")
                
            case 2:
                self.settingsImageView.image = #imageLiteral(resourceName: "FAQ.png")
                
            case 3:
                self.settingsImageView.image = #imageLiteral(resourceName: "Feedback.png")
                
            case 4:
                self.settingsImageView.image = #imageLiteral(resourceName: "PrivacyPolicy.png")
                
            case 5:
                self.settingsImageView.image = #imageLiteral(resourceName: "Terms.png")
                
            case 6:
                self.settingsImageView.image = #imageLiteral(resourceName: "Version.png")
                
            default:
                break
            }
        } else {
            headerLabel.isHidden = true
            self.settingsImageView.image = #imageLiteral(resourceName: "Settings.png")
        }
        
        if let prevFocussedCell = context.previouslyFocusedView as? JCSettingsTableViewCell {
            prevFocussedCell.cellAccessoryImage.image = #imageLiteral(resourceName: "ArrowGrey.png")
            prevFocussedCell.baseView.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
            prevFocussedCell.textLabel?.textColor = #colorLiteral(red: 0.6500751972, green: 0.650090754, blue: 0.6500824094, alpha: 1)
            prevFocussedCell.settingsDetailLabel.textColor = #colorLiteral(red: 0.6500751972, green: 0.650090754, blue: 0.6500824094, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsDetailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: settingsDetailVCStoryBoardId) as! JCSettingsDetailVC
        switch indexPath.row {
        case 0:
            if JCLoginManager.sharedInstance.isUserLoggedIn() {
                JCLoginManager.sharedInstance.logoutUser()
                let eventProperties = ["Platform": "TVOS", "userid": Utility.sharedInstance.encodeStringWithBase64(aString: JCAppUser.shared.uid)]
                JCAnalyticsManager.sharedInstance.sendEventToCleverTap(eventName: "Logged Out", properties: eventProperties)
                settingsTableView.reloadData()
                JCLoginManager.sharedInstance.isLoginFromSettingsScreen = false
            } else {
                let loginVc = Utility.sharedInstance.prepareLoginVC(fromAddToWatchList: false, fromPlayNowBotton: false, fromItemCell: false, presentingVC: self)
                self.present(loginVc, animated: true, completion: nil)
            }
            return
        case 1:
            settingsDetailVC.isForAutoPlay = true
            settingsDetailVC.isDetailView = false
            settingsDetailVC.isFeedBackView = false
            
        case 2:
            settingsDetailVC.isDetailView = false
            settingsDetailVC.isFeedBackView = false
            
        case 3:
            settingsDetailVC.isFeedBackView = false
            settingsDetailVC.isDetailView = true
            settingsDetailVC.titleText = "FAQs"
            settingsDetailVC.textViewDetail = FAQText
            
        case 4:
            settingsDetailVC.isDetailView  = false
            settingsDetailVC.isFeedBackView = true
            
        case 5:
            settingsDetailVC.isDetailView = true
            settingsDetailVC.isFeedBackView = false
            settingsDetailVC.titleText = "PRIVACY POLICY"
            settingsDetailVC.textViewDetail = PrivacyPolicyText
            
        case 6:
            settingsDetailVC.isDetailView = true
            settingsDetailVC.isFeedBackView = false
            settingsDetailVC.titleText = "TERMS & CONDITIONS"
            settingsDetailVC.textViewDetail = TermsAndConditionText
            
        default:
            break
        }
        self.present(settingsDetailVC, animated: false, completion: nil)
    }
    
}

