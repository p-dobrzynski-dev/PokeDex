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
    @IBOutlet weak var searchButton: UIButton!
    
    var pokemonAdressList: [PokemonModel] = []
    var isFetchingNewPokemons = false
    
    let numberOfLoadPokemons = 100
    var pokemonNamesList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPokemonNames()
        
        tableView.backgroundColor = .clear
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIndentifier)
        
        //Register Loading Cell
        let tableViewLoadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(tableViewLoadingCellNib, forCellReuseIdentifier: "loadingcellid")
        
        fetchPokemonList(from: 0, to: numberOfLoadPokemons)
        searchButton.backgroundColor = UIColor(named: "searchButtonColor")
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        searchButton.layer.cornerRadius = searchButton.frame.width/2
        searchButton.layer.shadowColor = UIColor.black.cgColor
        searchButton.layer.shadowOpacity = 0.75
        searchButton.layer.shadowOffset = .zero
        searchButton.layer.shadowRadius = 5
        searchButton.layer.masksToBounds = false
        
        showSpinner(onView: self.view)
        
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: K.SearchStoryBoard) as? SearchViewController
        searchVC?.pokemonNamesList = pokemonNamesList
        self.navigationController?.pushViewController(searchVC!, animated: false)
        
    }
    
    func fetchPokemonNames(){
        Alamofire.request("https://pokeapi.co/api/v2/pokemon?&limit=890&offset=0").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let results = json["results"].array{
                    for result in results{
                        if let name = result["name"].string{
                            self.pokemonNamesList.append(name.capitalizingFirstLetter())
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
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
                            let pokemonAdress = PokemonModel(urlAdress: url, pokemonName: name, pokemonID: pokeID)
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
                
                DispatchQueue.main.async {
                    if self.checkIfPokemonInfoFull(){
                        self.tableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print(error)
                self.pokemonAdressList[pokemonID-1].pokemonImage = UIImage(named: "pokeball")!
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
                DispatchQueue.main.async {
                    if self.checkIfPokemonInfoFull(){
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
            removeSpinner()
            return true
        }else{
            return false
        }
    }
}


//MARK: Table View Source Extension
extension ListViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        let pokemonCellsNumber = pokemonAdressList.count
        //        return pokemonCellsNumber
        //
        if section == 0 {
            //Return the amount of items
            return pokemonAdressList.count
        } else if section == 1 {
            //Return the Loading cell
            return 1
        } else {
            //Return nothing
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell  = tableView.dequeueReusableCell(withIdentifier: K.cellIndentifier, for: indexPath) as! PokemonCell
            
            let pokemonObject = pokemonAdressList[indexPath.row]
            
            cell.PokemonName.text = pokemonObject.pokemonName.capitalizingFirstLetter()
            cell.PokemonID.text = "\(pokemonObject.fullPokemonID())"
            cell.PokemonImage.image = pokemonObject.pokemonImage
            
            cell.PokemonImage.layer.shadowColor = UIColor.black.cgColor
            cell.PokemonImage.layer.shadowOpacity = 0.75
            cell.PokemonImage.layer.shadowOffset = .zero
            cell.PokemonImage.layer.shadowRadius = 5
            cell.PokemonImage.layer.masksToBounds = false
            
            cell.setPokemonTypes(typesArray: pokemonObject.pokemonTypesList)
            cell.Bubble.backgroundColor = UIColor(named: "\(pokemonObject.pokemonTypesList[0])")
            
            return cell
        }
            
        else if pokemonAdressList.count == 0 {
            let cell = UITableViewCell()
            return cell
        }
            
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingcellid", for: indexPath) as! LoadingCell
            cell.rotate()
            return cell
        }
    }
    
}

//MARK: Table View Delegate Extension
extension ListViewController: UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: K.DetailStoryBoard) as? DatailViewController
        detailVC?.pokemon = pokemonAdressList[indexPath.row]
        self.navigationController?.pushViewController(detailVC!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 0 {
            return 55
        }else{
            return tableView.rowHeight
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - scrollView.frame.height) && !isFetchingNewPokemons{
            fetchPokemonList(from: pokemonAdressList.count, to: numberOfLoadPokemons)
            //            isFetchingNewPokemons = true
        }
        
        //        if scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 100 {
        //            if !isFetchingNewPokemons{
        //                fetchPokemonList(from: pokemonAdressList.count, to: numberOfLoadPokemons)
        //            }
        //        }
    }
    
}

var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

        DispatchQueue.main.async {
            let loadingImage: UIImageView = {
                let imageView = UIImageView(image: UIImage(named: "pokeball"))
                let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
                rotationAnimation.duration = 0.5;
                rotationAnimation.isCumulative = true;
                rotationAnimation.repeatCount = .infinity;
                imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
                imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                imageView.center = spinnerView.center
                imageView.alpha = 0.7
                return imageView
            }()
            
            spinnerView.addSubview(loadingImage)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
