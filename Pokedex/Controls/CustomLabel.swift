//
//  CustomLabel.swift
//  Pokedex
//
//  Created by Piotr on 22/04/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {

    
    override func draw(_ rect: CGRect) {

        let inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        super.drawText(in: rect.inset(by: inset))
    }

}
