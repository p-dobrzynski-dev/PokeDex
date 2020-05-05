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
    @IBOutlet weak var typesStackView: UIStackView!
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
    
    var mainColor: UIColor = UIColor()
    var lastViewIndex: Int = 0
    
    override func viewDidLayoutSubviews() {
        fitSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomNavigationButton()
        bottomViewTopConstraint.constant = view.bounds.height * 0.35
        
        bottomView.layer.cornerRadius = 30
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.layer.shadowColor = UIColor.gray.cgColor
        bottomView.layer.shadowOpacity = 0.75
        bottomView.layer.shadowOffset = .zero
        bottomView.layer.shadowRadius = 10
        bottomView.layer.masksToBounds = false
        
        let pokemonImageSize = view.bounds.width * 0.5
        pokemonImageWidth.constant = pokemonImageSize
        pokemonImageHeight.constant = pokemonImageSize
        pokemonImage.image = pokemon.pokemonImage
        pokemonImage.layer.shadowOpacity = 0.75
        pokemonImage.layer.shadowOffset = .zero
        pokemonImage.layer.shadowRadius = 5
        pokemonImage.layer.masksToBounds = false
        
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
        fetchPokemon()
        
        //Getting pokemon general info
        fetchPokemonSpecies()
        
        
        for pokemonType in pokemon.pokemonTypesList{
            let typeLabel: UILabel = {
                let label = UILabel()
                label.sizeToFit()
                label.text = pokemonType.uppercased()
                label.layer.cornerRadius = 15
                label.font = UIFont.boldSystemFont(ofSize: 15)
                label.textAlignment = .center
                label.widthAnchor.constraint(equalToConstant: 80).isActive = true
                //                                label.heightAnchor.constraint(equalToConstant: 35).isActive = true
                label.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
                label.layer.borderWidth = 3
                label.textColor = .white
                label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
                return label
            }()
            
            typesStackView.addArrangedSubview(typeLabel)
        }
        typesStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    private func fitSubviews(){
        generalView.frame = selectedView.bounds
        statsView.frame = selectedView.bounds
        evolutionView.frame = selectedView.bounds
        movesView.frame = selectedView.bounds
    }
    
    private func fetchPokemon(){
        // Getting pokemon type and id
        Alamofire.request("https://pokeapi.co/api/v2/pokemon/\(pokemon.pokemonID)").responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                var stats: [String:Int] = [String:Int]()
                if let statsList = json["stats"].array{
                    for stat in statsList{
                        if let statName = stat["stat"]["name"].string{
                            stats[statName] = stat["base_stat"].int!
                        }
                    }
                }
                
                let weight: Int = json["weight"].int!
                let height: Int = json["height"].int!
                
                var abibilitesText: String {
                    var text = ""
                    let sortedAbilitiesArray = json["abilities"].array!.sorted{
                        $0["slot"].intValue < $1["slot"].intValue
                    }
                    
                    for (index,abilitieJSON) in sortedAbilitiesArray.enumerated(){
                        text += abilitieJSON["ability"]["name"].string!.capitalizingFirstLetter()
                        if index != sortedAbilitiesArray.endIndex-1 {
                            text += ", "
                        }
                    }
                    return text
                }
                
                if let typesArray = json["types"].array{
                    let typesUrlArray: [String] = {
                        var array = [String]()
                        for type in typesArray {
                            if let typeUrl = type["type"]["url"].string{
                                array.append(typeUrl)
                            }
                        }
                        return array
                    }()
                    
                    self.fetchPokemonTypes(typesArray: typesUrlArray)
                }
                
                
                DispatchQueue.main.async {
                    self.generalView.weightValueLabel.text = "\(Float(weight)/10) kg"
                    self.generalView.heightValueLabel.text = "\(Float(height)/10) m"
                    self.generalView.abiblitiesValueLabel.text = abibilitesText
                    self.statsView.updateStats(detailDict: stats)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchPokemonTypes(typesArray:[String]){
        
        var demageStruct = Demage()
        var jsonCounter:Int = 0
        for pokemonTypeUrl in typesArray{
            // Getting pokemon type and id
            Alamofire.request(pokemonTypeUrl).responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    
                    if let demageRalation = json["damage_relations"].dictionary{
                        if let doubleDemageFromArray = demageRalation["double_damage_from"]?.array{
                            if doubleDemageFromArray.count != 0{
                                for demageValue in doubleDemageFromArray{
                                    demageStruct.demageArray[demageValue["name"].string!]! *= 2
                                }
                            }
                        }
                        
                        if let halfDemageFromArray = demageRalation["half_damage_from"]?.array{
                            if halfDemageFromArray.count != 0{
                                for demageValue in halfDemageFromArray{
                                    demageStruct.demageArray[demageValue["name"].string!]! *= 0.5
                                }
                            }
                        }
                        
                        if let noDemageFromArray = demageRalation["no_damage_from"]?.array{
                            if noDemageFromArray.count != 0{
                                for demageValue in noDemageFromArray{
                                    demageStruct.demageArray[demageValue["name"].string!]! *= 0
                                }
                            }
                        }
                        
                        jsonCounter+=1
                    }
                    if jsonCounter == typesArray.count{
                        DispatchQueue.main.async {
                            self.movesView.setCounters(arrayOfCounters: demageStruct.gedDemageArray())
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        
    }
    
    private func fetchPokemonSpecies(){
        // Getting pokemon type and id
        Alamofire.request("https://pokeapi.co/api/v2/pokemon-species/\(pokemon.pokemonID)").responseJSON { (response) in
            switch response.result{
            case .success(let value):
                
                let json = JSON(value)
                
                let genderRate: Int = json["gender_rate"].int!
                
                var maleRate: Float = 0
                var femaleRate: Float = 0
                switch genderRate {
                case 0:
                    maleRate = 100
                    femaleRate = 0
                case 1:
                    maleRate = 87.5
                    femaleRate = 12.5
                case 2:
                    maleRate = 100
                    femaleRate = 0
                case 4:
                    maleRate = 100
                    femaleRate = 0
                case 6:
                    maleRate = 100
                    femaleRate = 0
                case 7:
                    maleRate = 100
                    femaleRate = 0
                case 8:
                    maleRate = 100
                    femaleRate = 0
                case -1:
                    maleRate = 100
                    femaleRate = 0
                default:
                    maleRate = 0
                    femaleRate = 0
                }
                
                var eggGroupsText:String{
                    var text: String = ""
                    if let eggGroupsArray: [JSON] = json["egg_groups"].array {
                        for (index,eggGroup) in eggGroupsArray.enumerated(){
                            text += "\(eggGroup["name"].string!.capitalizingFirstLetter())"
                            if index != eggGroupsArray.endIndex-1 {
                                text += ", "
                            }
                        }
                    }
                    return text
                }
                
                var generaText: String{
                    var text: String = ""
                    if let generasArray: [JSON] = json["genera"].array{
                        for genera in generasArray{
                            if genera["language"]["name"].string! == "en"{
                                text = genera["genus"].string!
                            }
                        }
                    }
                    return text
                }
                
                var flavorText: String{
                    var text: String = ""
                    
                    if let flavorArray: [JSON] = json["flavor_text_entries"].array{
                        for flavor in flavorArray{
                            if (flavor["language"]["name"].string! == "en" && flavor["version"]["name"].string! == "y" ){
                                text = flavor["flavor_text"].string!.replacingOccurrences(of: "\n", with: "  ")
                            }
                            
                        }
                    }
                    return text
                }
                
                
                
                if let evolutionChainUrl = json["evolution_chain"]["url"].string{
                    self.fetchPokemonEvolutionChain(url: evolutionChainUrl)
                }
                
                DispatchQueue.main.async {
                    self.generalView.genderRateValueLabel.text = "M: \(maleRate)% F: \(femaleRate)%"
                    self.generalView.eggGroupsValueLabel.text = eggGroupsText
                    self.generalView.categoryValueLabel.text = generaText
                    self.generalView.infoValueLabel.text = flavorText
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    private func fetchPokemonEvolutionChain(url: String){
        // Getting pokemon type and id
        Alamofire.request(url).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                
                let json = JSON(value)
                
                let evolutionTuple = (name: json["chain"]["species"]["name"].string!, level: 0, item: "")
                var evolutionChain = [evolutionTuple]
                if let firstEvolvesTo: [JSON] = json["chain"]["evolves_to"].array{
                    if firstEvolvesTo.count > 0 {
                        
                        var firstEvolutionTuple = evolutionTuple
                        if let firstEvolution: String = firstEvolvesTo[0]["species"]["name"].string{
                            firstEvolutionTuple.name = firstEvolution
                        }
                        
                        if let evolutionItem:String = firstEvolvesTo[0]["evolution_details"][0]["item"]["name"].string{
                            firstEvolutionTuple.item = evolutionItem
                        }
                        
                        if let firstEvolutionLevel: Int = firstEvolvesTo[0]["evolution_details"][0]["min_level"].int{
                            firstEvolutionTuple.level = firstEvolutionLevel
                        }
                        evolutionChain.append(firstEvolutionTuple)
                        
                        if let secondEvolvesTo: [JSON] = firstEvolvesTo[0]["evolves_to"].array{
                            if secondEvolvesTo.count > 0 {
                                
                                var secondEvolutionTuple = evolutionTuple
                                if let secondEvolution: String = secondEvolvesTo[0]["species"]["name"].string{
                                    secondEvolutionTuple.name = secondEvolution
                                }
                                
                                if let evolutionItem:String = secondEvolvesTo[0]["evolution_details"][0]["item"]["name"].string{
                                    secondEvolutionTuple.item = evolutionItem
                                }
                                
                                if let secondEvolutionLevel: Int = secondEvolvesTo[0]["evolution_details"][0]["min_level"].int{
                                    secondEvolutionTuple.level = secondEvolutionLevel
                                }
                                
                                evolutionChain.append(secondEvolutionTuple)
                                
                            }
                        }
                    }
                }
                
                self.fetchPokemonEvolutionImages(evolutionDetails: evolutionChain)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func fetchPokemonEvolutionImages(evolutionDetails: [(name: String, level:Int,item:String)]){
        
        var imagesArray: [String: UIImage] = [:]
        // Getting pokemon type and id
        for pokemonTuple in evolutionDetails{
            Alamofire.request("https://img.pokemondb.net/sprites/x-y/normal/\(pokemonTuple.name).png").responseImage { (response) in
                switch response.result{
                case .success(let value):
                    if let image = UIImage(data: value.pngData()!, scale: 1){
                        imagesArray[pokemonTuple.name] = image
                    }
                    if imagesArray.count == evolutionDetails.count{
                        DispatchQueue.main.async {
                            for (pokemonIndex, pokTuple) in evolutionDetails.enumerated(){
                                
                                let containerView: UIView = {
                                    let view = UIView()
                                    view.layer.cornerRadius = 20
                                    view.layer.shadowColor = UIColor.lightGray.cgColor
                                    view.layer.shadowOffset = CGSize(width: 1, height: 1)
                                    view.layer.shadowRadius = 3
                                    view.layer.shadowOpacity = 0.5
                                    view.backgroundColor = UIColor.white
                                    return view
                                }()
                                
                                let pokemonImageView: UIImageView = UIImageView(image: imagesArray[pokTuple.name])
                                containerView.addSubview(pokemonImageView)
                                
                                pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
                                pokemonImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                                pokemonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                                
                                //                                pokemonImageView.contentMode = .scaleToFill
                                pokemonImageView.clipsToBounds = true
                                pokemonImageView.widthAnchor.constraint(equalToConstant: self.evolutionView.frame.width/3).isActive = true
                                pokemonImageView.heightAnchor.constraint(equalToConstant: self.evolutionView.frame.width/3).isActive = true
                                pokemonImageView.layer.shadowOpacity = 0.75
                                pokemonImageView.layer.shadowColor = UIColor.gray.cgColor
                                pokemonImageView.layer.shadowOffset = .zero
                                pokemonImageView.layer.shadowRadius = 3
                                pokemonImageView.layer.masksToBounds = false
                                
                                containerView.widthAnchor.constraint(equalToConstant: self.evolutionView.frame.width/3).isActive = true
                                
                                self.evolutionView.evolutionStackView.addArrangedSubview(containerView)
                                
                                let levelLabel: UILabel = {
                                    let label = UILabel()
                                    label.font = UIFont.boldSystemFont(ofSize: 17)
                                    label.numberOfLines = 0
                                    if (pokemonIndex != evolutionDetails.startIndex && evolutionDetails.count != 0){
                                        if pokTuple.level != 0{
                                            label.text = "Level \(pokTuple.level)"
                                        }
                                        else if pokTuple.item != ""{
                                            label.text = "Using \(pokTuple.item)"
                                        }
                                        else{
                                            label.text = "?"
                                        }
                                    }
                                    label.textAlignment = .center
                                    return label
                                }()
                                
                                self.evolutionView.levelsStackView.addArrangedSubview(levelLabel)
                                
                                
                                let pokemonNameLabel: UILabel = {
                                    let label = UILabel()
                                    label.text = pokTuple.name.capitalizingFirstLetter()
                                    label.textAlignment = .center
                                    label.font = UIFont.italicSystemFont(ofSize: 17)
                                    return label
                                }()
                                self.evolutionView.pokemonNamesStackView.addArrangedSubview(pokemonNameLabel)
                                self.evolutionView.stackViewHeight.constant = self.evolutionView.frame.width/3
                                
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    private func addSemgnetedControl(){
        
        segmentedControl.options = [.indicatorViewBackgroundColor(UIColor(named: "\(pokemon.pokemonTypesList[0])")!),
                                    .cornerRadius(15.0),
                                    .animationSpringDamping(1.0)]
        segmentedControl.segments = LabelSegment.segments(withTitles: ["General", "Stats","Evolution","Defense"],
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
    
    private func setView(view: UIView, show: Bool, frame: CGRect, direction: String) {
        
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

