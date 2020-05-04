//
//  Demage.swift
//  Pokedex
//
//  Created by Piotr on 27/04/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import Foundation

struct Demage{
    
    var demageArray = ["normal":1.0,
                       "fire":1.0,
                       "water":1.0,
                       "electric":1.0,
                       "grass":1.0,
                       "ice":1.0,
                       "fighting":1.0,
                       "poison":1.0,
                       "ground":1.0,
                       "flying":1.0,
                       "psychic":1.0,
                       "bug":1.0,
                       "rock":1.0,
                       "ghost":1.0,
                       "dragon":1.0,
                       "dark":1.0,
                       "steel":1.0,
                       "fairy":1.0]

    func gedDemageArray() -> [Float]{
        let tempDemageArray: [Float] = {
            var array = [Float]()
            for key in K.typesKey{
                array.append(Float(demageArray[key]!))
            }
            return array
        }()
        return tempDemageArray
    }
}
