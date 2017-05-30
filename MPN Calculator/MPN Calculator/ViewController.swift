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
    
    @IBOutlet weak var lclLabel: UILabel!
    @IBOutlet weak var uclLabel: UILabel!
    @IBOutlet weak var mpnLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    var numberOfPositivesArray = [Double]()
    var numberOfTubesArray = [Double]()
    var volsInocArray = [Double]()
    
    var mostProbableNumber = Double()
    var confidenceInterval = Double()
    var lTermSum = Double()
    var rTermSum = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissNumpad))
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
            getLTermRTermConfidenceInterval()
            self.lclLabel.text = "\(Double(round(calculateLCL() * 1000) / 1000))"
            self.uclLabel.text = "\(Double(round(calculateUCL() * 1000) / 1000))"
            self.confidenceLabel.text = "\(Double(round(confidenceInterval * 1000) / 1000))"
            self.mpnLabel.text = "\(Double(round(calculateActualMPN() * 1000) / 1000))"
            
            
        }

    }
    
    
    func initialGuess() {
        
        self.numberOfPositivesArray = [Double(numberPositive1.text!)!, Double(numberPositive2.text!)!, Double(numberPositive3.text!)!]
        self.numberOfTubesArray = [Double(numberTubes1.text!)!, Double(numberTubes2.text!)!, Double(numberTubes3.text!)!]
        self.volsInocArray = [Double(volume1.text!)!, Double(volume2.text!)!, Double(volume3.text!)!]
        
        var positives = Double()
        var tubes = Double()
        var vol = Double()
        
        
        for (index, value) in self.numberOfPositivesArray.enumerated() {
            if 0 < value && value < self.numberOfTubesArray[index] {
                positives = value
                tubes = self.numberOfTubesArray[index]
                vol = self.volsInocArray[index]
                break
            }
        }

        self.mostProbableNumber = -(1.0 / vol) * log10((tubes-positives) / tubes)
        print(self.mostProbableNumber)
    }
    
    func getLTermRTermConfidenceInterval() {
        for (index, value) in self.numberOfTubesArray.enumerated() {
            if value > 0 {
                
                self.lTermSum += self.volsInocArray[index]*self.numberOfPositivesArray[index]/(1-exp(-self.volsInocArray[index]*self.mostProbableNumber))
                
                self.rTermSum += self.volsInocArray[index] * self.numberOfTubesArray[index]
                
                self.confidenceInterval += self.numberOfTubesArray[index] * pow(self.volsInocArray[index], 2) / (exp(self.volsInocArray[index] * self.mostProbableNumber)-1)
            }
        }
    }
    
    
    func calculateActualMPN() -> Double {
        var newMPN = self.mostProbableNumber * pow(10, (1-self.rTermSum/self.lTermSum))
        while ((self.mostProbableNumber / newMPN) * 100) < 99.99 {
            print(self.mostProbableNumber)
            self.mostProbableNumber = newMPN
            getLTermRTermConfidenceInterval()
            newMPN = self.mostProbableNumber * pow(10, (1-self.rTermSum/self.lTermSum))
        }
        return newMPN
    }
    
    func calculateUCL() -> Double {
       let uclValue = exp(log(self.mostProbableNumber) + 1.96 / (self.mostProbableNumber * self.confidenceInterval.squareRoot()))
        
        return uclValue
    }
    
    func calculateLCL() -> Double {
        let lclValue = exp(log(self.mostProbableNumber) - 1.96 / (self.mostProbableNumber * self.confidenceInterval.squareRoot()))
        
        return lclValue

    }
    

    
// Handling invalid entries
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

