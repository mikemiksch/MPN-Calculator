//
//  ViewController.swift
//  MPN Calculator
//
//  Created by Mike Miksch on 5/24/17.
//  Copyright © 2017 Mike Miksch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
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
        self.numberPositive1.delegate = self
        self.numberPositive2.delegate = self
        self.numberPositive3.delegate = self
        self.numberTubes1.delegate = self
        self.numberTubes2.delegate = self
        self.numberTubes3.delegate = self
        self.volume1.delegate = self
        self.volume2.delegate = self
        self.volume3.delegate = self
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
            self.mpnLabelField.text = "\(Double(round(calculateActualMPN() * 1000) / 1000))"
            self.lclLabelField.text = "\(Double(round(calculateLCL() * 1000) / 1000))"
            self.uclLabelField.text = "\(Double(round(calculateUCL() * 1000) / 1000))"
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
        var positives = Double()
        var tubes = Double()
        var vol = Double()
        
        let firstRowPositives = self.numberOfPositivesArray[0]
        let firstRowTubes = self.numberOfTubesArray[0]
        let secondRowPositives = self.numberOfPositivesArray[1]
        let firstRowVol = self.volsInocArray[0]
        
        if firstRowPositives == firstRowTubes && secondRowPositives == 0 {
            self.mostProbableNumber = 1 / firstRowVol
        } else {
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
        
        if validateCompletion() == false {
            presentCompletionAlert()
            result = false
        } else {
            self.numberOfPositivesArray = [Double(numberPositive1.text!)!, Double(numberPositive2.text!)!, Double(numberPositive3.text!)!]
            self.numberOfTubesArray = [Double(numberTubes1.text!)!, Double(numberTubes2.text!)!, Double(numberTubes3.text!)!]
            self.volsInocArray = [Double(checkDecimal(input: volume1)!)!, Double(checkDecimal(input: volume2)!)!, Double(checkDecimal(input: volume3)!)!]
            
            if validateTubeCounts() == false {
                presentTubeCountAlert()
                result = false
            }
            
            if validateVolumeValues() == false {
                presentVolumeAlert()
                result = false
            }
        }
        
        return result
    }
    
//MARK: Handling invalid entries
    
    func checkDecimal(input: CustomTextField!) -> String? {
        if var inputText = input.text {
            if inputText.characters.first == "."  {
                inputText.insert("0", at: inputText.startIndex)
            }
            return inputText
        }
        return nil
    }
    
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
        for (index, _) in self.numberOfPositivesArray.enumerated() {
            if self.numberOfPositivesArray[index] > self.numberOfTubesArray[index] {
                result = false
            }
        }
        return result
    }
    

    func validateVolumeValues() -> Bool {
        var result = true
        let lastIdx = volsInocArray.count - 1
        for i in 1...lastIdx {
            if volsInocArray[i] >= volsInocArray[i - 1] {
                result = false
            }
        }
        return result
    }
    
    
//MARK: Invalid entry alerts
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
    
//MARK: Text field delegate code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch string {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return true
        case "." :
            let inputArray = Array(textField.text!.characters)
            var decimalCount = 0
            for character in inputArray {
                if character == "." {
                    decimalCount += 1
                }
            }
            
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let inputArray = Array(string.characters)
            if inputArray.count == 0 {
                return true
            }
            return false
        }
    }

}

