//
//  ViewController.swift
//  MPN Calculator
//
//  Created by Mike Miksch on 5/24/17.
//  Copyright © 2017 Mike Miksch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var numberPositive1: CustomTextField!
    @IBOutlet weak var numberPositive2: CustomTextField!
    @IBOutlet weak var numberPositive3: CustomTextField!
    
    @IBOutlet weak var numberTubes1: CustomTextField!
    @IBOutlet weak var numberTubes2: CustomTextField!
    @IBOutlet weak var numberTubes3: CustomTextField!
    
    @IBOutlet weak var volume1: CustomTextField!
    @IBOutlet weak var volume2: CustomTextField!
    @IBOutlet weak var volume3: CustomTextField!
    
    @IBOutlet weak var mpnLabelTitle: UILabel!
    @IBOutlet weak var lclLabelTitle: UILabel!
    @IBOutlet weak var uclLabelTitle: UILabel!
    
    @IBOutlet weak var lclLabelField: UILabel!
    @IBOutlet weak var uclLabelField: UILabel!
    @IBOutlet weak var mpnLabelField: UILabel!

    
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
        view.addGestureRecognizer(tap)
        hide()
    }
    
    func dismissNumpad() {
        view.endEditing(true)
    }
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        let validation : Bool = validateFields()
        if validation == true {
            initialGuess()
            getLTermRTermConfidenceInterval()
            self.mpnLabelField.text = "\(Double(round(calculateActualMPN() * 100) / 100))"
            self.lclLabelField.text = "\(Double(round(calculateLCL() * 100) / 100))"
            self.uclLabelField.text = "\(Double(round(calculateUCL() * 100) / 100))"
            self.numberOfTubesArray.removeAll()
            self.numberOfPositivesArray.removeAll()
            self.volsInocArray.removeAll()
            self.mostProbableNumber = 0
            resetValues()
            show()
        }

    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        hide()
        self.numberPositive1.text = ""
        self.numberPositive2.text = ""
        self.numberPositive3.text = ""
        
        self.numberTubes1.text = ""
        self.numberTubes2.text = ""
        self.numberTubes3.text = ""
        
        self.volume1.text = ""
        self.volume2.text = ""
        self.volume3.text = ""
        
    }
    
    func show() {
        self.lclLabelField.isHidden = false
        self.lclLabelTitle.isHidden = false
        self.uclLabelField.isHidden = false
        self.uclLabelTitle.isHidden = false
        self.mpnLabelField.isHidden = false
        self.mpnLabelTitle.isHidden = false
    }
    
    func hide() {
        self.lclLabelField.isHidden = true
        self.lclLabelTitle.isHidden = true
        self.uclLabelField.isHidden = true
        self.uclLabelTitle.isHidden = true
        self.mpnLabelField.isHidden = true
        self.mpnLabelTitle.isHidden = true
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
    }
    
    func getLTermRTermConfidenceInterval() {
        for (index, value) in self.numberOfTubesArray.enumerated() {
            if value > 0 {
                
                self.lTermSum += self.volsInocArray[index]*self.numberOfPositivesArray[index]/(1-exp(-self.volsInocArray[index]*self.mostProbableNumber))
                self.rTermSum += (self.volsInocArray[index] * self.numberOfTubesArray[index])
                self.confidenceInterval += self.numberOfTubesArray[index] * pow(self.volsInocArray[index], 2) / (exp(self.volsInocArray[index] * self.mostProbableNumber)-1)
            }
        }
    }
    
    
    func calculateActualMPN() -> Double {
        var newMPN = self.mostProbableNumber * pow(10, (1-self.rTermSum/self.lTermSum))
        while ((self.mostProbableNumber / newMPN) * 100) < 99.99 {
            self.mostProbableNumber = newMPN
            resetValues()
            getLTermRTermConfidenceInterval()
            newMPN = self.mostProbableNumber * pow(10, (1-self.rTermSum/self.lTermSum))
        }
        print(self.lTermSum)
        print(self.rTermSum)
        print(self.confidenceInterval)
        self.mostProbableNumber = newMPN
        return self.mostProbableNumber
    }
    
    func calculateUCL() -> Double {
       let uclValue = exp(log(self.mostProbableNumber) + (1.96 / (self.mostProbableNumber * self.confidenceInterval.squareRoot())))
        
        return uclValue
    }
    
    func calculateLCL() -> Double {
        let lclValue = exp(log(self.mostProbableNumber) - (1.96 / (self.mostProbableNumber * self.confidenceInterval.squareRoot())))
        
        return lclValue

    }
    
    func resetValues() {
        self.lTermSum = 0
        self.rTermSum = 0
        self.confidenceInterval = 0
    }
    
   
    @IBAction func aboutButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "InfoViewController", sender: sender)
    }
    
    @IBAction func instructionsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "InstructionsViewController", sender: sender)
    }
    
    func validateFields() -> Bool {
        var result = true
        print("This is the validate value when you first press calculate button: \(result)")
        
        
        if validateCompletion() == false {
            presentCompletionAlert()
            result = false
        }
        
        if validateTubeCounts() == false {
            presentTubeCountAlert()
            result = false
        }
        
        if validateVolumeValues() == false {
            presentVolumeAlert()
            result = false
        }
        
        print("This is the validate value after it runs: \(result)")
        return result
    }
    
// Handling invalid entries
    func validateCompletion() -> Bool {
        let mandatoryFields = [numberPositive1, numberPositive2, numberPositive3, numberTubes1, numberTubes2, numberTubes3, volume1, volume2, volume3]
        var result = true

        for each in mandatoryFields {
            if each?.text == "" {
                result = false
            }
        }
        
        return result

    }
    
    func validateTubeCounts() -> Bool {
        var result = true
        if let positives1Text = self.numberPositive1.text, let positives2Text = self.numberPositive2.text, let positives3Text = self.numberPositive3.text, let numberTubes1Text = self.numberTubes1.text, let numberTubes2Text = self.numberTubes2.text, let numberTubes3Text = self.numberTubes3.text {
            if let positives1Dbl = Double(positives1Text), let positives2Dbl = Double(positives2Text), let positives3Dbl = Double(positives3Text), let numberTubes1Dbl = Double(numberTubes1Text), let numberTubes2Dbl = Double(numberTubes2Text), let numberTubes3Dbl = Double(numberTubes3Text) {
                if positives1Dbl > numberTubes1Dbl || positives2Dbl > numberTubes2Dbl || positives3Dbl > numberTubes3Dbl {
                    result = false
                }
            }
        }
        return result
    }
    
    func validateVolumeValues() -> Bool {
        var result = true
        if let volume1Text = self.volume1.text, let volume2Text = self.volume2.text, let volume3Text = self.volume3.text {
            if let volume1Dbl = Double(volume1Text), let volume2Dbl = Double(volume2Text), let volume3Dbl = Double(volume3Text) {
                if volume1Dbl <= volume2Dbl || volume2Dbl <= volume3Dbl {
                    result = false
                }
                
            }
        }
        return result
    }
    
    func presentCompletionAlert() {
        let alert = UIAlertController(title: nil, message: "Please complete all fields", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentTubeCountAlert() {
        let alert = UIAlertController(title: nil, message: "Number of positive tubes cannot exceed number of all tubes for its series", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentVolumeAlert() {
        let alert = UIAlertController(title: nil, message: "Invalid volumes", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}

