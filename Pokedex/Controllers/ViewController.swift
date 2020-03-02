//
//  ViewController.swift
//  Pokedex
//
//  Created by Piotr on 16/02/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    @IBAction func showList(_ sender: UIButton) {
        
        performSegue(withIdentifier: K.listSeque, sender: self)
    }
}


