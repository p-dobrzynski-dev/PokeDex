//
//  GeneralView.swift
//  Pokedex
//
//  Created by Piotr on 21/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class GeneralView: UIView {
    
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
    
}
