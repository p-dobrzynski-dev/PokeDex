//
//  DatailViewController.swift
//  Pokedex
//
//  Created by Piotr on 01/03/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit
import TinyConstraints
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
    
    var pokemon = PokemonModel()
    
    var statsView: StatsView!
    var generalView: GeneralView!
    var evolutionView: EvolutionView!
    var movesView: MovesView!
    
    var speed: Int = 0
    var hp: Int = 0
    var attack: Int = 0
    var defense: Int = 0
    var specialDefense: Int = 0
    var specialAttack: Int = 0
    var total: Int = 0
    var mainColor: UIColor = UIColor()
    var lastViewIndex: Int = 0
    
    
    let segmetedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["General", "Stats","Evolution","Moves"])
        return sc
    }()
    
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
        
        // Do any additional setup after loading the view
        generalView = GeneralView(frame: bottomView.frame)
        generalView.tag = 1
        bottomView.addSubview(generalView)
        
        statsView = StatsView(frame: bottomView.frame)
        statsView.tag = 2
        statsView.isHidden = true
        bottomView.addSubview(statsView)
        
        evolutionView = EvolutionView(frame: bottomView.frame)
        evolutionView.tag = 3
        evolutionView.isHidden = true
        bottomView.addSubview(evolutionView)
        
        movesView = MovesView(frame: bottomView.frame)
        movesView.tag = 4
        movesView.isHidden = true
        bottomView.addSubview(movesView)
        
        //Setting colors
        if let mainColor = UIColor(named: "\(pokemon.pokemonTypesList[0])"){
            topView.backgroundColor = mainColor
            statsView.setStatsColor(color: mainColor)
        }
        
        statsView.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 120, left: 40, bottom: 0, right: 40), usingSafeArea: true)
        generalView.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 120, left: 40, bottom: 0, right: 40), usingSafeArea: true)
        evolutionView.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 120, left: 40, bottom: 0, right: 40), usingSafeArea: true)
        movesView.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 120, left: 40, bottom: 0, right: 40), usingSafeArea: true)
        
        // Getting stats of pokemon
        fetchPokemonStats()
        
        // Getting species of pokemon
        fetchPokemonSpecies()
        
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
        let segmentedControl = BetterSegmentedControl(frame: CGRect(x: 35.0, y: 40.0, width: 200.0, height: 30.0),
                                                      segments: LabelSegment.segments(withTitles: ["General", "Stats","Evolution","Moves"],
                                                                                      normalFont: UIFont(name: "HelveticaNeue", size: 13.0)!,
                                                                                      normalTextColor: .darkGray,
                                                                                      selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 13.0)!,
                                                                                      selectedTextColor: .white),
                                                      options:[.indicatorViewBackgroundColor(UIColor(named: "\(pokemon.pokemonTypesList[0])")!),
                                                               .cornerRadius(15.0),
                                                               .animationSpringDamping(1.0)])
        
        
        segmentedControl.addTarget(self,
                                   action: #selector(DatailViewController.navigationSegmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.tag = -1
        bottomView.addSubview(segmentedControl)
        
        segmentedControl.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 60, left: 12, bottom: 0, right: 12), usingSafeArea: true)
        segmentedControl.height(30)
    }
    
    // MARK: - Action handlers
    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        if let nextView = bottomView.viewWithTag(sender.index+1){
            if sender.index+1 > lastViewIndex+1{
                setView(view: nextView, show: true, frame: bottomView.frame, direction: "ToLeft")
            }
            else{
                setView(view: nextView, show: true, frame: bottomView.frame, direction: "ToRight")
            }
        }
        
        if let lastView = bottomView.viewWithTag(lastViewIndex+1){
            if sender.index > lastViewIndex{
                setView(view: lastView, show: false, frame: bottomView.frame, direction: "ToLeft")
            }
            else{
                setView(view: lastView, show: false, frame: bottomView.frame, direction: "ToRight")
            }
            
            lastViewIndex = sender.index
        }
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
                            view.frame.origin.x = frame.origin.x + 40
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
                view.frame.origin.x = frame.origin.x + 40
            }
        })
    }
    
}

