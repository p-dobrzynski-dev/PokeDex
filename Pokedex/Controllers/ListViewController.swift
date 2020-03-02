//
//  ListViewController.swift
//  Pokedex
//
//  Created by Piotr on 16/02/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import AlamofireImage


class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var image: UIImageView!
    var pokemonAdressList: [PokemonAdress] = []
    var isFetchingNewPokemons = false
    
    let numberOfLoadPokemons = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignbackground()
        tableView.backgroundColor = .clear
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIndentifier)
        fetchPokemonList(from: 0, to: numberOfLoadPokemons)
    }
    
    func assignbackground(){
        let background = UIImage(named: "pokeball_crop")

        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }

    
    func fetchPokemonList(from: Int, to: Int){
        
        
        self.isFetchingNewPokemons = true
        
        Alamofire.request("https://pokeapi.co/api/v2/pokemon?&limit=\(to)&offset=\(from)").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let results = json["results"].array{
                    for result in results{
                        if let url = result["url"].string, let name = result["name"].string{
                            let pokeID = self.pokemonAdressList.count + 1
                            let pokemonAdress = PokemonAdress(urlAdress: url, pokemonName: name, pokemonID: pokeID)
                            self.pokemonAdressList.append(pokemonAdress)
                            self.fetchPokemonInfo(pokemonID: pokeID, pokemonName: name)
                        }
                        else{
                            print("ERRROR")
                        }
                    }
                                        
                    
                }
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
    
    func fetchPokemonInfo(pokemonID: Int, pokemonName: String){
        //        Getting pokemon image
        Alamofire.request("https://img.pokemondb.net/sprites/x-y/normal/\(pokemonName).png").responseImage { (response) in
            switch response.result{
            case .success(let value):
                
                if let image = UIImage(data: value.pngData()!, scale: 0.5){
                    self.pokemonAdressList[pokemonID-1].pokemonImage = image
                }
                if self.checkIfPokemonInfoFull(){
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
        //        Getting pokemon type and id
        Alamofire.request("https://pokeapi.co/api/v2/pokemon/\(pokemonID)").responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                if let results = json["types"].array{
                    
                    var dictOfPokemonTypes = [Int:String]()
                    for result in results{
                        if let pokemonType = result["type"]["name"].string, let pokemonSlot = result["slot"].int{
                            dictOfPokemonTypes[pokemonSlot] = pokemonType
                        }
                    }
                    let sortedDictOfPokemonTypes = dictOfPokemonTypes.sorted( by: { $0.0 < $1.0 })
                    let pokomonTypeList = sortedDictOfPokemonTypes.map { return $0.value }
                    self.pokemonAdressList[pokemonID-1].pokemonTypesList = pokomonTypeList
                }
                if self.checkIfPokemonInfoFull(){
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkIfPokemonInfoFull() -> Bool {
        
        var numberOfFullyLoadedPokemons = 0
        for pokemon in pokemonAdressList{
            if pokemon.pokemonImage.size.width != 0 && pokemon.pokemonTypesList.isEmpty == false{
                numberOfFullyLoadedPokemons += 1
            }
        }
        if numberOfFullyLoadedPokemons == pokemonAdressList.count{
            isFetchingNewPokemons = false
            return true
        }else{
            return false
        }
    }
}


//MARK: Table View Source Extension
extension ListViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pokemonCellsNumber = pokemonAdressList.count
        return pokemonCellsNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: K.cellIndentifier, for: indexPath) as! PokemonCell
        
        let pokemonObject = pokemonAdressList[indexPath.row]
        
        cell.PokemonName.text = pokemonObject.pokemonName.capitalizingFirstLetter()
        cell.PokemonID.text = "\(pokemonObject.fullPokemonID())"
        cell.PokemonImage.image = pokemonObject.pokemonImage
        
        cell.PokemonImage.layer.shadowColor = UIColor.black.cgColor
        cell.PokemonImage.layer.shadowOpacity = 0.75
        cell.PokemonImage.layer.shadowOffset = .zero
        cell.PokemonImage.layer.shadowRadius = 5
        
        cell.setPokemonTypes(typesArray: pokemonObject.pokemonTypesList)
        cell.Bubble.backgroundColor = UIColor(named: "\(pokemonObject.pokemonTypesList[0])")
        
        return cell
    }
    
    
    
}

//MARK: Table View Delegate Extension
extension ListViewController: UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(pokemonAdressList[indexPath.row].pokemonName)
        performSegue(withIdentifier: K.detailSeques, sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
        let cellRotation = CATransform3DTranslate(CATransform3DIdentity, 0, 20, 0)
        cell.layer.transform = cellRotation
        cell.alpha = 0.0
        
        
        UIView.animate(withDuration: 0.15) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 100 {
            if !isFetchingNewPokemons{
                fetchPokemonList(from: pokemonAdressList.count, to: numberOfLoadPokemons)
            }
        }
    }
    
}

