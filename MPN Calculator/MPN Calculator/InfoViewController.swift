//
//  InfoViewController.swift
//  MPN Calculator
//
//  Created by Mike Miksch on 6/5/17.
//  Copyright © 2017 Mike Miksch. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
