//
//  StatsView.swift
//  Pokedex
//
//  Created by Piotr on 07/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class StatsView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var hpStatView: singleStatView!
    @IBOutlet weak var attackStatView: singleStatView!
    @IBOutlet weak var defenseStatView: singleStatView!
    @IBOutlet weak var speedAtkStatView: singleStatView!
    @IBOutlet weak var speedDefStatView: singleStatView!
    @IBOutlet weak var speedStatView: singleStatView!
    @IBOutlet weak var totalStatView: singleStatView!
    
    var statsList: [singleStatView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("StatsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        hpStatView.statNameLabel.text = "HP"
        attackStatView.statNameLabel.text = "Attack"
        defenseStatView.statNameLabel.text = "Defense"
        speedAtkStatView.statNameLabel.text = "Sp. Atk"
        speedDefStatView.statNameLabel.text = "Sp. Def"
        speedStatView.statNameLabel.text = "Speed"
        totalStatView.statNameLabel.text = "Total"
        
        statsList = [hpStatView,attackStatView,defenseStatView,speedAtkStatView,speedDefStatView,speedStatView,totalStatView]
    }
    
    public func setStatsColor(color: UIColor){
        for stat in statsList{
            stat.setProgressViewColor(color: color)
        }
    }
    
    public func updateHp(value: Int){
        hpStatView.setStatValue(value: value)
    }
    
    public func updateSpeed(value: Int){
        speedStatView.setStatValue(value: value)
        
    }
    
    public func updateAttack(value: Int){
        attackStatView.setStatValue(value: value)
        
    }
    
    public func updateDefense(value: Int){
        defenseStatView.setStatValue(value: value)
        
    }
    
    public func updateSpecialDefense(value: Int){
        speedDefStatView.setStatValue(value: value)
        
    }
    
    public func updateSpecialAttack(value: Int){
        speedAtkStatView.setStatValue(value: value)
        
    }
    
    public func updateTotal(value: Int){
        totalStatView.setStatValue(value: value)
    }
}
