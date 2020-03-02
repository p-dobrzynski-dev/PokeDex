//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Piotr on 17/02/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class PokemonCell: UITableViewCell {
    
    
    @IBOutlet weak var Bubble: UIView!
    @IBOutlet weak var PokemonName: UILabel!
    @IBOutlet weak var PokemonID: UILabel!
    @IBOutlet weak var PokemonImage: UIImageView!
    @IBOutlet weak var PokemoTypesStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code\
        
        Bubble.layer.cornerRadius = Bubble.frame.height/5
        
        contentView.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        Bubble.layer.shadowColor = UIColor.black.cgColor
        Bubble.layer.shadowOpacity = 0.75
        Bubble.layer.shadowOffset = .zero
        Bubble.layer.shadowRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setPokemonTypes(typesArray: [String]){
        for view in self.PokemoTypesStackView.subviews {
            view.removeFromSuperview()
        }
        
        for pokemonType in typesArray{
            let typeView = PokemonTypeView()
            typeView.fillView.backgroundColor = UIColor(named: pokemonType)
            typeView.typeNameLabel.text = pokemonType
            PokemoTypesStackView.addArrangedSubview(typeView)
        }
        PokemoTypesStackView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
}
