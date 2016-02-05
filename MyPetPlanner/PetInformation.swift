//
//  PetInformation.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 1/7/16.
//  Copyright © 2016 Brittany Stewart. All rights reserved.
//

import Foundation

import UIKit
import EventKit
import EventKitUI

class PetInformation: UIViewController {
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var length: UITextField!
    @IBOutlet weak var weight: UITextField!
    
    @IBOutlet weak var additionalInfo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadInfo()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {

    }
 
    func dismissKeyboard() { // Dismiss keyboard when user taps outside the text field
        view.endEditing(true)
    }
    
    func loadInfo() { // Load saved information
        petName.text = NSUserDefaults.standardUserDefaults().stringForKey("petName")
        length.text = NSUserDefaults.standardUserDefaults().stringForKey("length")
        weight.text = NSUserDefaults.standardUserDefaults().stringForKey("weight")
        additionalInfo.text = NSUserDefaults.standardUserDefaults().stringForKey("additionalInfo")
    }
    
    @IBAction func save(sender: UIButton) { // Save new or edited information
        NSUserDefaults.standardUserDefaults().setValue(petName.text, forKey: "petName")
        NSUserDefaults.standardUserDefaults().setValue(length.text, forKey: "length")
        NSUserDefaults.standardUserDefaults().setValue(weight.text, forKey: "weight")
        NSUserDefaults.standardUserDefaults().setValue(additionalInfo.text, forKey: "additionalInfo")
        
        let alert = UIAlertView()
        alert.title = "Saved"
        alert.message = "Pet information saved successfully."
        alert.addButtonWithTitle("OK")
        alert.show()
    }
}