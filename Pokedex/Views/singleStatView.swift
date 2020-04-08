//
//  singleStatView.swift
//  Pokedex
//
//  Created by Piotr on 11/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class singleStatView: UIView {
    
    @IBOutlet weak var statNameLabel: UILabel!
    @IBOutlet weak var statValueLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var statValueProgressView: UIProgressView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("singleStatView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        statValueProgressView.layer.cornerRadius = 10
        statValueProgressView.clipsToBounds = true
    }
    
    public func setStatValue(value: Int) {
        statValueLabel.text = "\(value)"
        let progressValue = Float(value)/100.0
        statValueProgressView.setProgress(progressValue, animated: true)
    }
    
    public func setProgressViewColor(color: UIColor){
        statValueProgressView.progressTintColor = color
    }

}
