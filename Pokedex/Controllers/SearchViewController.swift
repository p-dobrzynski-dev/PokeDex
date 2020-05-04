//
//  SearchViewController.swift
//  Pokedex
//
//  Created by Piotr on 01/05/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var pokemonNamesList: [String]!
    var searchdata: [String]!
    
    var pokemonModel: PokemonModel = PokemonModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchBar.becomeFirstResponder()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchdata = pokemonNamesList
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pokemonModel = PokemonModel()
    }
    
    
    func fetchPokemonInfo(pokemonID: Int, pokemonName: String){
        
        pokemonModel.pokemonName = pokemonName.uppercased()
        pokemonModel.pokemonID = pokemonID
        
        //        Getting pokemon image
        Alamofire.request("https://img.pokemondb.net/sprites/x-y/normal/\(pokemonName).png").responseImage { (response) in
            switch response.result{
            case .success(let value):
                
                if let image = UIImage(data: value.pngData()!, scale: 0.5){
                    self.pokemonModel.pokemonImage = image
                }
                
                DispatchQueue.main.async {
                    if self.checkIfPokemonInfoFull(){
                        self.goToDetail()
                    }
                }
                
            case .failure(let error):
                print(error)
                self.pokemonModel.pokemonImage = UIImage(named: "pokeball")!
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
                    self.pokemonModel.pokemonTypesList = pokomonTypeList
                }
                DispatchQueue.main.async {
                    if self.checkIfPokemonInfoFull(){
                        self.goToDetail()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func checkIfPokemonInfoFull() -> Bool {
        if pokemonModel.pokemonImage.size.width != 0 && pokemonModel.pokemonTypesList.isEmpty == false{
            return true
        }
        else{
            return false
        }
    }
    
    private func goToDetail(){
        let detailVC = storyboard?.instantiateViewController(withIdentifier: K.DetailStoryBoard) as? DatailViewController
        detailVC?.pokemon = pokemonModel
        self.navigationController?.pushViewController(detailVC!, animated: true)
    }
}



extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchdata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.serchCellIndentifier, for: indexPath)
        cell.textLabel?.text = searchdata[indexPath.row]
        return cell
    }
}

extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index: Int = pokemonNamesList.firstIndex(of: searchdata[indexPath.row])!
        let name: String = pokemonNamesList[index].lowercased()
        fetchPokemonInfo(pokemonID: index+1, pokemonName: name)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           cell.backgroundColor = .clear
           cell.selectionStyle = .none
       }
}

extension SearchViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchdata = pokemonNamesList
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchdata = searchText.isEmpty ? pokemonNamesList : pokemonNamesList.filter{
            
            (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil,locale: nil) != nil
        }
        tableView.reloadData()
    }
}
