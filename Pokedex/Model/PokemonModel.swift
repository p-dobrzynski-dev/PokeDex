//
//  PokemonAdress.swift
//  Pokedex
//
//  Created by Piotr on 17/02/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import Foundation
import UIKit

struct PokemonModel {
    var urlAdress = ""
    var pokemonName = ""
    var pokemonID = 0
    var pokemonImage = UIImage()
    var pokemonTypesList = [String]()

    func fullPokemonID() -> String {
        let fullID = "#\(String(format: "%03d", pokemonID ))"
        return fullID
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
