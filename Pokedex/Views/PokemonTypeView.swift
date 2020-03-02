//
//  PokemonTypeView.swift
//  Pokedex
//
//  Created by Piotr on 19/02/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class PokemonTypeView: UIView {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var fillView: UIView!
    @IBOutlet weak var typeNameLabel: UILabel!
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("PokemonTypeView", owner: self, options: nil)
        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
}
