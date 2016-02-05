//
//  SelectDate.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 1/1/16.
//  Copyright © 2016 Brittany Stewart. All rights reserved.
//

import Foundation
import UIKit

protocol sendDate
{
    func sendDateToPreviousVC(date: NSDate)
}

class SelectDate: UIViewController  { // Class to allow user to select a date from the datepicker and send it back to the previous detail page
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var mDelegate:sendDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning()
    {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func acceptDate(sender: UIButton) {
        print("Test Save Date")
        // Notify the caller that a date was selected.
        sendDateToPreviousVC(datePicker.date)
        // Pop the view controller.
        navigationController?.popViewControllerAnimated(true)
    }
    
    func sendDateToPreviousVC(date: NSDate){
        self.mDelegate?.sendDateToPreviousVC(date)
        
    }
}