//
//  CustomTextField.swift
//  MPN Calculator
//
//  Created by Mike Miksch on 6/7/17.
//  Copyright © 2017 Mike Miksch. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(paste(_:)) {
            return false
        }
        
        return true
    }
}
