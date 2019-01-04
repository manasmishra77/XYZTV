//
//  DisneyButtonsView.swift
//  
//
//  Created by Shweta Adagale on 26/12/18.
//

import UIKit
protocol DisneyButtonsTapedDelegate{
    func presentVCOnButtonTap(tag : Int)
}

class DisneyButtons: UIView {
    var delegate : DisneyButtonsTapedDelegate?
    override func awakeFromNib() {

    }
    @IBAction func moviesButtonTapped(_ sender: UIButton) {
        delegate?.presentVCOnButtonTap(tag: sender.tag)
    }
    @IBAction func tvShowTapped(_ sender: UIButton) {
        delegate?.presentVCOnButtonTap(tag: sender.tag)
    }
    @IBAction func kidsTapped(_ sender: UIButton) {
        delegate?.presentVCOnButtonTap(tag: sender.tag)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
