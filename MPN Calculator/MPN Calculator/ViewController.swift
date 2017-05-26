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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissNumpad")
//        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissNumpad() {
        view.endEditing(true)
    }
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        let validation : Bool = validateFields()
        if validation == false {
            presentAlert()
        } else {
            initialGuess()
        }

    }
    
    
    func initialGuess() {
        
        let numberOfPostives = [Double(numberPositive1.text!)!, Double(numberPositive2.text!)!, Double(numberPositive3.text!)!]
        let numberOfTubes = [Double(numberTubes1.text!)!, Double(numberTubes2.text!)!, Double(numberTubes3.text!)!]
        let volsInoc = [Double(volume1.text!)!, Double(volume2.text!)!, Double(volume3.text!)!]
        
        var positives = Double()
        var tubes = Double()
        var vol = Double()
        
        var guess = Double()
        
        for (index, value) in numberOfPostives.enumerated() {
            if 0 < value && value < numberOfTubes[index] {
                positives = value
                tubes = numberOfTubes[index]
                vol = volsInoc[index]
                break
            }
        }
        print(positives)
        print(tubes)
        print(vol)
        guess = -(1.0 / vol) * log10((tubes-positives) / tubes)
        print(guess)
        
        
    }
    
    func validateFields() -> Bool {
        let mandatoryFields = [numberPositive1, numberPositive2, numberPositive3, numberTubes1, numberTubes2, numberTubes3, volume1, volume2, volume3]
        
        var result = Bool()
        
        //Need logic to handle .01 versus 0.01
        
        for each in mandatoryFields {
            if each?.text == "" {
                result = false
            } else {
                result = true
            }
        }
        
        return result

    }
    
    func presentAlert() {
        let alert = UIAlertController(title: nil, message: "Please complete all fields", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}

