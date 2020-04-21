//
//  DatailViewController.swift
//  Pokedex
//
//  Created by Piotr on 01/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import Alamofire
import SwiftyJSON


class DatailViewController: UIViewController{
    
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var pokemonIDLabel: UILabel!
    @IBOutlet weak var bottomViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pokemonImageTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var pokemonImageWidth: NSLayoutConstraint!
    @IBOutlet weak var pokemonImageHeight: NSLayoutConstraint!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    
    var pokemon = PokemonModel()
    
    var generalView: GeneralView = {
        let view = GeneralView()
        view.tag = 1
        view.isHidden = false
        return view
    }()
    
    var statsView: StatsView = {
        let view = StatsView()
        view.tag = 2
        view.isHidden = true
        return view
    }()
    
    var evolutionView: EvolutionView = {
        let view = EvolutionView()
        view.tag = 3
        view.isHidden = true
        return view
    }()
    
    var movesView: MovesView = {
        let view = MovesView()
        view.tag = 4
        view.isHidden = true
        return view
    }()
    
    var speed: Int = 0
    var hp: Int = 0
    var attack: Int = 0
    var defense: Int = 0
    var specialDefense: Int = 0
    var specialAttack: Int = 0
    var total: Int = 0
    var mainColor: UIColor = UIColor()
    var lastViewIndex: Int = 0
    
    
    
    override func viewDidLayoutSubviews() {
        fitSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomViewTopConstraint.constant = view.bounds.height * 0.35
        
        bottomView.layer.cornerRadius = 30
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        let pokemonImageSize = view.bounds.height * 0.4
        pokemonImageWidth.constant = pokemonImageSize
        pokemonImageHeight.constant = pokemonImageSize
        
        pokemonImageTopConstaint.constant = view.bounds.height * 0.35 - pokemonImageSize*0.7
        pokemonImage.image = pokemon.pokemonImage
        pokemonImage.layer.shadowOpacity = 0.75
        pokemonImage.layer.shadowOffset = .zero
        pokemonImage.layer.shadowRadius = 5
        
        pokemonNameLabel.text = pokemon.pokemonName.capitalizingFirstLetter()
        
        pokemonIDLabel.text = pokemon.fullPokemonID()
        
        // Adding segmented control to bottom view
        addSemgnetedControl()
        
        selectedView.addSubview(generalView)
        selectedView.addSubview(statsView)
        selectedView.addSubview(evolutionView)
        selectedView.addSubview(movesView)
        
        fitSubviews()
        
        //Setting colors
        if let mainColor = UIColor(named: "\(pokemon.pokemonTypesList[0])"){
            topView.backgroundColor = mainColor
            statsView.setStatsColor(color: mainColor)
        }
        
        
        // Getting stats of pokemon
        fetchPokemonStats()
        
        // Getting species of pokemon
        fetchPokemonSpecies()
        
        //Getting pokemon general info
        fetchPokemonGeneral()
    }
    
    private func fitSubviews(){
        generalView.frame = selectedView.bounds
        statsView.frame = selectedView.bounds
        evolutionView.frame = selectedView.bounds
        movesView.frame = selectedView.bounds
    }
    
    private func fetchPokemonStats(){
        //        Getting pokemon type and id
        Alamofire.request("https://pokeapi.co/api/v2/pokemon/\(pokemon.pokemonID)").responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if let statsList = json["stats"].array{
                    for stat in statsList{
                        switch stat["stat"]["name"] {
                        case "speed":
                            self.speed = stat["base_stat"].int!
                        case "special-defense":
                            self.specialDefense = stat["base_stat"].int!
                        case "special-attack":
                            self.specialAttack = stat["base_stat"].int!
                        case "defense":
                            self.defense = stat["base_stat"].int!
                        case "attack":
                            self.attack = stat["base_stat"].int!
                        case "hp":
                            self.hp = stat["base_stat"].int!
                        default:
                            print("Couldnt find stat")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.updateStats()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchPokemonGeneral(){
        
        //      Getting pokemon type and id
        Alamofire.request("https://pokeapi.co/api/v2/pokemon-species/\(pokemon.pokemonID)").responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if let statsList = json["stats"].array{
                    for stat in statsList{
                        switch stat["stat"]["name"] {
                        case "speed":
                            self.speed = stat["base_stat"].int!
                        case "special-defense":
                            self.specialDefense = stat["base_stat"].int!
                        case "special-attack":
                            self.specialAttack = stat["base_stat"].int!
                        case "defense":
                            self.defense = stat["base_stat"].int!
                        case "attack":
                            self.attack = stat["base_stat"].int!
                        case "hp":
                            self.hp = stat["base_stat"].int!
                        default:
                            print("Couldnt find stat")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.updateStats()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    private func fetchPokemonSpecies(){
        
    }
    
    private func updateStats(){
        statsView.updateHp(value: hp)
        statsView.updateSpeed(value: speed)
        statsView.updateAttack(value: attack)
        statsView.updateDefense(value: defense)
        statsView.updateSpecialAttack(value: specialAttack)
        statsView.updateSpecialDefense(value: specialDefense)
    }
    
    
    private func addSemgnetedControl(){
        
        segmentedControl.options = [.indicatorViewBackgroundColor(UIColor(named: "\(pokemon.pokemonTypesList[0])")!),
                                    .cornerRadius(15.0),
                                    .animationSpringDamping(1.0)]
        segmentedControl.segments = LabelSegment.segments(withTitles: ["General", "Stats","Evolution","Moves"],
                                                          normalFont: UIFont(name: "HelveticaNeue", size: 17.0)!,
                                                          normalTextColor: .darkGray,
                                                          selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!,
                                                          selectedTextColor: .white)
        
    }
    
    @IBAction func segmentedIndexChanged(_ sender: BetterSegmentedControl) {
        if let nextView = selectedView.viewWithTag(sender.index+1){
            if sender.index+1 > lastViewIndex+1{
                setView(view: nextView, show: true, frame: selectedView.frame, direction: "ToLeft")
            }
            else{
                setView(view: nextView, show: true, frame: selectedView.frame, direction: "ToRight")
            }
        }
        
        if let lastView = selectedView.viewWithTag(lastViewIndex+1){
            if sender.index > lastViewIndex{
                setView(view: lastView, show: false, frame: selectedView.frame, direction: "ToLeft")
            }
            else{
                setView(view: lastView, show: false, frame: selectedView.frame, direction: "ToRight")
            }
            
            lastViewIndex = sender.index
        }
    }
    // MARK: - Action handlers
    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        
    }
    
    func setView(view: UIView, show: Bool, frame: CGRect, direction: String) {
        
        if show{
            view.isHidden = false
        }
        
        // SHOW
        if show{
            if direction == "ToLeft"{
                view.frame.origin.x = frame.size.width
            }else{
                view.frame.origin.x = -frame.size.width
            }
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveLinear,
                       animations: {
                        if show{
                            view.frame.origin.x = frame.origin.x
                        }
                        else{
                            if direction == "ToLeft"{
                                view.frame.origin.x = -frame.size.width
                            }else{
                                view.frame.origin.x = frame.size.width
                            }
                        }
        },completion: { (completed) in
            if !show{
                view.isHidden = true
                view.frame.origin.x = frame.origin.x
            }
        })
    }
    
}

