//
//  InfinityScrollView.swift
//  JioCinema
//
//  Created by Manas Mishra on 20/09/17.
//  Copyright © 2017 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
import SDWebImage

protocol JCChangeFocusForCarouselDelegate : class
{
    func setFocusEnvironments()
}

class InfinityScrollView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var extraLeftButton: UIButton!
    @IBOutlet weak var extraRightButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    var current = 1
    var newImageLoaded = true
    var myPreferredFocuseView: UIView? = nil
    weak var changeFocusForCarouselDelegate : JCChangeFocusForCarouselDelegate?
    var carouselArray = [Item]()
    //var carouselArray: [UIImage] = [UIImage(named: "T1")!, UIImage(named: "T2")!, UIImage(named: "T3")!, UIImage(named: "T4")!, UIImage(named: "T5")!]
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var extraLeftView: UIView!
    @IBOutlet weak var extraRightView: UIView!
    @IBOutlet weak var leftView: UIView!
    override func awakeFromNib() {
    }
    
    func loadViews() {
        
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(InfinityScrollView.autoRotate), userInfo: nil, repeats: true)
        //Setting the frames of the views
        middleView.frame.size.width = self.frame.size.width * 1600 / 1920
        extraLeftView.frame.origin.x = leftView.frame.origin.x - 50 - middleView.frame.size.width
        extraRightView.frame.origin.x = rightView.frame.origin.x + middleView.frame.size.width + 50

        //Setting Alpha of buttons
        self.middleButton.alpha = 1.0
        self.leftButton.alpha = self.middleButton.alpha - 0.5
        self.rightButton.alpha = self.leftButton.alpha
        self.extraLeftButton.alpha = self.leftButton.alpha
        self.extraRightButton.alpha = self.leftButton.alpha
        
        
        extraLeftButton.isUserInteractionEnabled = false
        leftButton.isUserInteractionEnabled = false
        middleButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = false
        extraRightButton.isUserInteractionEnabled = false
        //carouselArray = (JCDataStore.sharedDataStore.homeData?.data?[0].items)!

        let newImage = nextImage(current: 0)
        //LeftButton
        let leftButtonImageUrlString = self.carouselArray[newImage.previous!].tvImage
        let leftButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(leftButtonImageUrlString!))!)
        self.leftButton.sd_setBackgroundImage(with: leftButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
        //MiddleButton
        let middleButtonImageUrlString = self.carouselArray[newImage.current!].tvImage
        let middleButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(middleButtonImageUrlString!))!)
        self.middleButton.sd_setBackgroundImage(with: middleButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
        //RightButton
        let rightButtonImageUrlString = self.carouselArray[newImage.next!].tvImage
        let rightButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(rightButtonImageUrlString!))!)
        self.rightButton.sd_setBackgroundImage(with: rightButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
        //ExtraLeft
        let extraLeftButtonImageUrlString = self.carouselArray[newImage.extraOne!].tvImage
        let extraLeftButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(extraLeftButtonImageUrlString!))!)
        self.extraLeftButton.sd_setBackgroundImage(with: extraLeftButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
        //ExtraRight
        var extraRightCount = 0
        if newImage.next! + 1 < carouselArray.count{
            extraRightCount = newImage.next! + 1
        }
        let extraRightButtonImageUrlString = self.carouselArray[extraRightCount].tvImage
        let extraRightButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(extraRightButtonImageUrlString!))!)
        self.extraRightButton.sd_setBackgroundImage(with: extraRightButtonImageUrl!, for: .normal, placeholderImage:#imageLiteral(resourceName: "CarouselPlaceholder"))
        
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]
    {
        return [myPreferredFocuseView!]
    }
    
    func autoRotate()
    {
        let leftSwipe = UISwipeGestureRecognizer()
        leftSwipe.direction = .left
        horizontallySwipped(leftSwipe)
    }
    
    @IBAction func horizontallySwipped(_ sender: UISwipeGestureRecognizer) {
        if newImageLoaded == false{
            return
        }
        
        if sender.direction == .right{
            //extraLeft.backgroundColor = UIColor.yellow
            self.newImageLoaded = false
            let middelFrame = self.middleView.frame
            let rightFrame = self.rightView.frame
            let extraLeftFrame = self.extraLeftView.frame
            let leftFrame = self.leftView.frame
            //Towards right
            UIView.animateKeyframes(withDuration: 0.8, delay: 0.0, options: .calculationModePaced, animations: {
                self.middleView.frame = rightFrame
                self.leftView.frame = middelFrame
                self.extraLeftView.frame = leftFrame
                //self.extraOne.frame = rightFrame
                self.rightView.frame = self.extraRightView.frame
                
            }, completion: { (finished: Bool) -> Void in
                let previousImage = self.previousImage(current: self.current)
                self.current = previousImage.current!
                //LeftButton
                let leftButtonImageUrlString = self.carouselArray[previousImage.previous!].tvImage
                let leftButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(leftButtonImageUrlString!))!)
                self.leftButton.sd_setBackgroundImage(with: leftButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                //MiddleButton
                let middleButtonImageUrlString = self.carouselArray[previousImage.current!].tvImage
                let middleButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(middleButtonImageUrlString!))!)
                self.middleButton.sd_setBackgroundImage(with: middleButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                //RightButton
                let rightButtonImageUrlString = self.carouselArray[previousImage.next!].tvImage
                let rightButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(rightButtonImageUrlString!))!)
                self.rightButton.sd_setBackgroundImage(with: rightButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                //ExtraLeft
                let extraLeftButtonImageUrlString = self.carouselArray[previousImage.extraOne!].tvImage
                let extraLeftButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(extraLeftButtonImageUrlString!))!)
                self.extraLeftButton.sd_setBackgroundImage(with: extraLeftButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                
                
                //self.changeFocusForCarouselDelegate?.setFocusEnvironments()
                self.myPreferredFocuseView = self.middleButton
                self.leftView.frame = leftFrame
                self.extraLeftView.frame = extraLeftFrame
                self.rightView.frame = rightFrame
                self.middleView.frame = middelFrame
                //self.extraLeft.frame = extraLeftFrame
                self.newImageLoaded = true
                self.myPreferredFocuseView = self.middleButton
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            })
            
        }
        else if sender.direction == .left {
            // Towards left
            //extraRight.backgroundColor = UIColor.yellow
            self.newImageLoaded = false
            let middelFrame = self.middleView.frame
            let rightFrame = self.rightView.frame
            let extraRightFrame = self.extraRightView.frame
            let leftFrame = self.leftView.frame
            
            UIView.animateKeyframes(withDuration: 0.8, delay: 0.0, options: .calculationModeLinear, animations: {
                self.middleView.frame = leftFrame
                self.rightView.frame = middelFrame
                self.extraRightView.frame = rightFrame
                self.leftView.frame = self.extraLeftView.frame
                
            }, completion: { (finished: Bool) -> Void in
                let nextImage = self.nextImage(current: self.current)
                self.current = nextImage.current!
                
                //LeftButton
                let leftButtonImageUrlString = self.carouselArray[nextImage.previous!].tvImage
                let leftButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(leftButtonImageUrlString!))!)
                self.leftButton.sd_setBackgroundImage(with: leftButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                //MiddleButton
                let middleButtonImageUrlString = self.carouselArray[nextImage.current!].tvImage
                let middleButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(middleButtonImageUrlString!))!)
                self.middleButton.sd_setBackgroundImage(with: middleButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                //RightButton
                let rightButtonImageUrlString = self.carouselArray[nextImage.next!].tvImage
                let rightButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(rightButtonImageUrlString!))!)
                self.rightButton.sd_setBackgroundImage(with: rightButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                //ExtraRight
                let extraRightButtonImageUrlString = self.carouselArray[nextImage.extraOne!].tvImage
                let extraRightButtonImageUrl = URL(string: (JCDataStore.sharedDataStore.configData?.configDataUrls?.image?.appending(extraRightButtonImageUrlString!))!)
                self.extraRightButton.sd_setBackgroundImage(with: extraRightButtonImageUrl!, for: .normal, placeholderImage: #imageLiteral(resourceName: "CarouselPlaceholder"))
                
                //CallToChangeTheFocusOfTheButton 
                //self.changeFocusForCarouselDelegate?.setFocusEnvironments()
                
                self.leftView.frame = leftFrame
                self.rightView.frame = rightFrame
                self.middleView.frame = middelFrame
                self.extraRightView.frame = extraRightFrame
                self.newImageLoaded = true
                self.myPreferredFocuseView = self.middleButton
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
                
            })
            
        }
    }
    @IBAction func singlyTapped(_ sender: UITapGestureRecognizer) {
        
    }
    @IBAction func didClickOnMiddleButton(_ sender: Any) {
        let itemToPlay = ["item":(carouselArray[current])]
        NotificationCenter.default.post(name: cellTapNotificationName, object: nil, userInfo: itemToPlay)
    }
    
    //Next Image call for headercell of table
    func nextImage(current: Int) -> CarouselImageType {
        var nextImageType = CarouselImageType()
        nextImageType.previous = current
        if current + 1 < (carouselArray.count){
            nextImageType.current = current + 1
        }else{
            nextImageType.current = 0
        }
        if nextImageType.current! + 1 < (carouselArray.count){
            nextImageType.next = nextImageType.current! + 1
        }else{
            nextImageType.next = 0
        }
        if nextImageType.next! + 1 < (carouselArray.count){
            nextImageType.extraOne = nextImageType.next! + 1
        }else{
            nextImageType.extraOne = 0
        }
        return nextImageType
    }
    
    //Previous Image call for headercell of table
    func previousImage(current: Int) -> CarouselImageType {
        var nextImageType = CarouselImageType()
        nextImageType.next = current
        //let collectionArray = (JCDataStore.sharedDataStore.homeData?.data?[0].items)!
        if current - 1 > -1{
            nextImageType.current = current - 1
        }else{
            nextImageType.current = carouselArray.count - 1
        }
        if nextImageType.current! - 1 > -1{
            nextImageType.previous = nextImageType.current! - 1
        }else{
            nextImageType.previous = carouselArray.count - 1
        }
        if nextImageType.previous! - 1 > -1{
            nextImageType.extraOne = nextImageType.previous! - 1
        }else{
            nextImageType.extraOne = carouselArray.count - 1
        }
        return nextImageType
    }

    
}
struct CarouselImageType {
    var next: Int?
    var current: Int?
    var previous: Int?
    var extraOne: Int?
}
