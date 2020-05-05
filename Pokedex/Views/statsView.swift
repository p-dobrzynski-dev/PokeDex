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
    @IBOutlet weak var hpValueLabel: UILabel!
    @IBOutlet weak var hpValueProgressView: UIProgressView!
    @IBOutlet weak var attackValueLabel: UILabel!
    @IBOutlet weak var attackValueProgressView: UIProgressView!
    @IBOutlet weak var defenseValueLabel: UILabel!
    @IBOutlet weak var defenseValueProgressView: UIProgressView!
    @IBOutlet weak var specialAttackValueLabel: UILabel!
    @IBOutlet weak var specialAttackValueProgressView: UIProgressView!
    @IBOutlet weak var specialDefenseValueLabel: UILabel!
    @IBOutlet weak var specialDefenseValueProgressView: UIProgressView!
    @IBOutlet weak var speedValueLabel: UILabel!
    @IBOutlet weak var speedValueProgressView: UIProgressView!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    
    var statsDict: [String:(label: UILabel, progressView: UIProgressView)] = [String:(label: UILabel, progressView: UIProgressView)]()
    
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
        
        statsDict["hp"] = (label: hpValueLabel, progressView: hpValueProgressView)
        statsDict["special-defense"] = (label: specialDefenseValueLabel, progressView: specialDefenseValueProgressView)
        statsDict["special-attack"] = (label: specialAttackValueLabel, progressView: specialAttackValueProgressView)
        statsDict["defense"] = (label: defenseValueLabel, progressView: defenseValueProgressView)
        statsDict["attack"] = (label: attackValueLabel, progressView: attackValueProgressView)
        statsDict["speed"] = (label: speedValueLabel, progressView: speedValueProgressView)
        
    }
    
    public func setStatsColor(color: UIColor){
        for stat in statsDict{
            stat.value.progressView.tintColor = color
            stat.value.progressView.layer.cornerRadius = 10
            stat.value.progressView.clipsToBounds = true
        }
    }
    
    public func updateStats(detailDict: [String:Int]){
        var total: Int = 0
        for stat in detailDict{
            total += stat.value
            statsDict[stat.key]?.label.text = "\(stat.value)"
            statsDict[stat.key]?.progressView.setProgress(Float(stat.value)/255.0, animated: false)
        }
        totalValueLabel.text = "\(total)"
    }
}
