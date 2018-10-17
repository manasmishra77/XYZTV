
//
//  CarouselViewForDisney.swift
//  JioCinema
//
//  Created by Shweta Adagale on 10/09/18.
//  Copyright © 2018 Reliance Jio Infocomm. Ltd. All rights reserved.
//

import UIKit
protocol DisneyButtonTapDelegate{
    func presentVCOnButtonTap(tag : Int)
}

class CarouselViewForDisney: UIView {
    var delegate : DisneyButtonTapDelegate?
    @IBOutlet weak var viewOfButtons: UIView!
    @IBOutlet weak var moviesButton: JCDisneyButton!
    @IBOutlet weak var tvShowButtton: JCDisneyButton!
    @IBOutlet weak var kidsButton: JCDisneyButton!
    @IBAction func onMoviesTapped(_ sender: UIButton) {
        delegate?.presentVCOnButtonTap(tag: sender.tag)
    }
    @IBAction func onTVshowTapped(_ sender: UIButton) {
        delegate?.presentVCOnButtonTap(tag: sender.tag)
    }
    @IBAction func onKidesTapped(_ sender: UIButton) {
        delegate?.presentVCOnButtonTap(tag: sender.tag)
    }
}
