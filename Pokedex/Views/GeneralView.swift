//
//  GeneralView.swift
//  Pokedex
//
//  Created by Piotr on 21/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class GeneralView: UIView {
    
    
    @IBOutlet weak var categoryValueLabel: UILabel!
    @IBOutlet weak var abiblitiesValueLabel: UILabel!
    @IBOutlet weak var heightValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var genderRateValueLabel: UILabel!
    @IBOutlet weak var eggGroupsValueLabel: UILabel!
    @IBOutlet weak var infoValueLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("GeneralView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("AAS")
    }
}
