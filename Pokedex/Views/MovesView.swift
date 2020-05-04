//
//  MovesView.swift
//  Pokedex
//
//  Created by Piotr on 22/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class MovesView: UIView {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
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
        Bundle.main.loadNibNamed("MovesView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setCounters(arrayOfCounters: [Float]){
        
        for index in 0..<arrayOfCounters.count{
            let demageView = createDemageView(type: K.typesKey[index], value: arrayOfCounters[index])
            let label = UILabel()
            label.text = "SS"
            switch index {
            case 0...5:
                topStackView.addArrangedSubview(demageView)
            case 6...11:
                middleStackView.addArrangedSubview(demageView)
            case 11...18:
                bottomStackView.addArrangedSubview(demageView)
            default:
                print("Out of range")
            }
            
        }
        
    }
    
    private func createDemageView(type: String, value: Float) -> UIStackView{
        
        let stackView = UIStackView()
//        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 3
        let typeLabel: UILabel = {
            let label = UILabel()
            label.layer.cornerRadius = 5
            label.text = type.prefix(3).uppercased()
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.backgroundColor = UIColor(named: type)
            label.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
            label.heightAnchor.constraint(equalToConstant: self.frame.width/7).isActive = true
            label.layer.masksToBounds = true
            return label
        }()
        let valueLabel: UILabel = {
            let label = UILabel()
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.textAlignment = .center
            label.text = "x\(value)"
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 5
            label.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
            if value == 1 {
                label.textColor = UIColor.lightGray
            }else{
                label.textColor = UIColor.white
                label.backgroundColor = UIColor(named: String(value))
            }
            
            return label
        }()
        valueLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(valueLabel)
//        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }
    
}
