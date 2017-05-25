//
//  ViewController.swift
//  MPN Calculator
//
//  Created by Mike Miksch on 5/24/17.
//  Copyright © 2017 Mike Miksch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var numberPositive1: UITextField!
    @IBOutlet weak var numberPositive2: UITextField!
    @IBOutlet weak var numberPositive3: UITextField!
    
    @IBOutlet weak var numberTubes1: UITextField!
    @IBOutlet weak var numberTubes2: UITextField!
    @IBOutlet weak var numberTubes3: UITextField!
    
    @IBOutlet weak var volume1: UITextField!
    @IBOutlet weak var volume2: UITextField!
    @IBOutlet weak var volume3: UITextField!
    
    @IBOutlet weak var lcl: UILabel!
    @IBOutlet weak var ucl: UILabel!
    @IBOutlet weak var mpn: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
    }
    
    
}

