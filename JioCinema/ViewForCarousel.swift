//
//  ViewForCarousel.swift
//  TestApp
//
//  Created by Shweta Adagale on 20/11/18.
//  Copyright © 2018 Shweta Adagale. All rights reserved.
//

import UIKit

protocol CarousalImageDelegate {
    func setImageFor(_ imageView: UIImageView, for index: Int)
}

class ViewForCarousel: UIView ,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    private var indexOfCellBeforeDragging = 0
    private var indexOfCellBeforeScrolling = 0
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var heightOfPageControl: NSLayoutConstraint!
    var timer : Timer?
    var count : Int = 0
    var isCircular : Bool!
    var sepration : CGFloat!
    var hasFooter : Bool!
    var widthOfCell : CGFloat!
    var frameOfView : CGRect!
    var visiblePart : CGFloat!
    var autoScroll : Bool!
    var countOfArray : Int {
        get {
            if isCircular {
                return count * 30
            } else {
                return count
            }
        }
    }
    
    var indexpathVar = IndexPath(row: 0, section: 0)
    var carousalImageDelegate: CarousalImageDelegate?
    var myPreferedFocusView : UIView?
    override var preferredFocusEnvironments: [UIFocusEnvironment]{
        if let preferredView = myPreferedFocusView {
            return [preferredView]
        }
        return []
    }
    static func instantiate(count : Int, isCircular : Bool, sepration : CGFloat, visiblePercentageOfPeekingCell visiblePart : CGFloat, hasFooter : Bool,frameOfView : CGRect, backGroundColor : UIColor,autoScroll : Bool, setImage delegate: CarousalImageDelegate) -> ViewForCarousel {
         let view: ViewForCarousel = initFromNib()
//        if autoScroll {
//            view.startTimer()
//        }
        view.count = count
        view.isCircular = isCircular
        view.sepration = sepration
        view.frameOfView = frameOfView
        view.widthOfCell =  (frameOfView.width - 2 * sepration) / (1 + CGFloat(2 * visiblePart))
        view.hasFooter = hasFooter
        view.visiblePart = visiblePart
        view.autoScroll = autoScroll
        view.collectionView.register(UINib(nibName: "CarouselCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CarouselCollectionViewCell")

        view.carousalImageDelegate = delegate
        view.collectionView.isScrollEnabled = false
        view.configureCollectionViewLayoutItemSize()
        //UI changes in view
        view.frame = frameOfView
        view.backgroundColor = backGroundColor
        view.pageControl.numberOfPages = count
        view.heightOfPageControl.constant = 0
        view.pageControl.isHidden = true
        view.collectionView.delegate = view
        view.collectionView.dataSource = view
        let swipeRight = UISwipeGestureRecognizer(target: view, action: #selector(view.respondToSwipeGesture))
        swipeRight.direction = [.right]
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: view, action: #selector(view.respondToSwipeGesture))
        swipeLeft.direction = [.left]
        view.addGestureRecognizer(swipeLeft)
        
//        let swipeDown = UISwipeGestureRecognizer(target: view, action: #selector(view.respondToSwipeGesture))
//        swipeDown.direction = [.down]
//        view.addGestureRecognizer(swipeDown)
        //for circurlar carousel
//        if isCircular {
//        view.indexpathVar.row = count * 15
//            DispatchQueue.main.async {
//                view.scrollToSpecificPosition(index: view.indexpathVar)
//            }
////            view.pageControl.currentPage = indexPath.row % arrayOfImage.count
//        }
        if hasFooter {
            view.pageControl.isHidden = false
            view.heightOfPageControl.constant = 20
        }
        view.collectionViewFlowLayout.minimumLineSpacing = 0
        return view
    }

    private func calculateSectionInset() -> CGFloat {
        var inset : CGFloat = 0.0
        if let width = collectionView?.frame.width {
//            inset = (width - widthOfCell) / 4
            inset = visiblePart + sepration
        }
        return inset
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset()
        if isCircular {
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        }
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    private func indexOfMajorCell() -> Int {
        let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / widthOfCell
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(countOfArray - 1, index))
        return safeIndex
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(velocity)

        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
//
//        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        indexpathVar.row = indexOfMajorCell
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < countOfArray && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {

            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            indexpathVar.row = snapToIndex
        } else {
            indexpathVar.row = indexOfMajorCell
        }
        scrollToSpecificPosition(index: indexpathVar)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countOfArray
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("right")
                swipeToNextOrPrivious(swipeNext: true)
            case UISwipeGestureRecognizerDirection.left:
                print("left")
                swipeToNextOrPrivious(swipeNext: false)
//            case UISwipeGestureRecognizerDirection.down:
//                swipeDown()
            default:
                break
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell", for: indexPath) as! CarouselCollectionViewCell
        cell.rightSepration.constant = sepration / 2
        cell.leftSepration.constant = sepration / 2
        var index = indexPath.row
        if isCircular {
           index = indexPath.row % count
        }
        self.carousalImageDelegate?.setImageFor(cell.imageView, for: index)
        //cell.imageView.image = UIImage(named: arrayOfImage[index])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfCell = CGSize(width: widthOfCell - 40, height: frameOfView.height - 40)
        return sizeOfCell
    }
//    func startTimer() {
//        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewForCarousel.autoSwipe), userInfo: nil, repeats: true);
//    }
//    @objc func autoSwipe() {
//        if isCircular && autoScroll {
//            if indexOfMajorCell() > countOfArray - 14*(count){
//                indexpath.row = count * 15
//                scrollToSpecificPosition(index: indexpath)
//                return
//            }
//        }
//        indexOfCellBeforeScrolling = indexOfMajorCell()
//        let indexToScroll = IndexPath(row: indexOfCellBeforeScrolling + 1, section: 0)
//        if indexToScroll.row < countOfArray {
//            self.scrollToSpecificPosition(index: indexToScroll)
//        }
//    }
    func scrollToSpecificPosition(index : IndexPath,animation : Bool = true) {
        collectionView!.scrollToItem(at: index, at: .centeredHorizontally, animated: animation)
        pageControl.currentPage = index.row % count
        updateCellInFocus(previousFocusView: myPreferedFocusView, nextFocusedView: collectionView.cellForItem(at: index))
        myPreferedFocusView = collectionView.cellForItem(at: index)
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func updateCellInFocus(previousFocusView : UIView?, nextFocusedView : UIView?) {
            nextFocusedView?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            previousFocusView?.transform = CGAffineTransform(scaleX: 1, y: 1)

    }
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        indexpathVar.row = indexOfMajorCell()
//        if context.nextFocusedView == self {
//            self.collectionView.cellForItem(at: indexpathVar)?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
//        } else {
//            self.collectionView.cellForItem(at: indexpathVar)?.transform = CGAffineTransform(scaleX: 1, y: 1)
//        }
//    }
}
extension UIView {
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}
extension ViewForCarousel {
    func swipeToNextOrPrivious(swipeNext : Bool) {
//        if let focusedCell = UIScreen.main.focusedView as? UICollectionViewCell {
//            if let indexPath = collectionView.indexPath(for: focusedCell) {
//                print("IndexPath is \(indexPath)")
//                if indexPath.row < count && indexPath.row >= 0 {
//                    print("IndexPath is \(indexPath)")
//                    if swipeNext && indexPath.row != count - 1{
//                        indexpathVar = IndexPath(row: indexPath.row + 1, section: 0)
//                    } else if (indexPath.row != 0){
//                        indexpathVar = IndexPath(row: indexPath.row - 1, section: 0)
//                    }
//                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//                }
//            }
//        }
//        if let focusedCell = UIScreen.main.focusedView as? UICollectionViewCell {
            let indexPath : Int = indexOfMajorCell()
            indexpathVar.row = indexPath
            if indexPath < count && indexPath >= 0 {
                print("IndexPath is \(indexPath)")
                
                if swipeNext && indexPath != count - 1{
                    indexpathVar = IndexPath(row: indexPath + 1, section: 0)
                } else if (indexPath != 0) && !swipeNext{
                    indexpathVar = IndexPath(row: indexPath - 1, section: 0)
                }
                self.scrollToSpecificPosition(index: indexpathVar)
        }
 //       }
        
    }
}
public protocol CarouselImageDelegate {
    func setImageForCarouselDelegate(_ imageView: UIImageView, for index: Int)
}
