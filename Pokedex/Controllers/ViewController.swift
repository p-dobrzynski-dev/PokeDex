//
//  ViewController.swift
//  Pokedex
//
//  Created by Piotr on 16/02/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var pokeballImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleImage.layer.shadowColor = UIColor.black.cgColor
        titleImage.layer.shadowOpacity = 0.75
        titleImage.layer.shadowOffset = .zero
        titleImage.layer.shadowRadius = 5
        titleImage.layer.masksToBounds = false
        
        pokeballImage.layer.shadowColor = UIColor.gray.cgColor
        pokeballImage.layer.shadowOpacity = 0.75
        pokeballImage.layer.shadowOffset = .zero
        pokeballImage.layer.shadowRadius = 3
        pokeballImage.layer.masksToBounds = false

        startButton.backgroundColor = UIColor.lightGray
        startButton.layer.cornerRadius = 5
        startButton.layer.masksToBounds = true
        startButton.layer.shadowPath = UIBezierPath(roundedRect: startButton.bounds, cornerRadius: startButton.layer.cornerRadius).cgPath
        startButton.layer.shadowColor = UIColor.darkGray.cgColor
        startButton.layer.shadowOpacity = 0.75
        startButton.layer.shadowOffset = .zero
        startButton.layer.shadowRadius = 5
        startButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        startButton.layer.masksToBounds = false
        
    }
    @IBAction func showList(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.listSeque, sender: self)
    }
}
