//
//  ReminderDetail.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 11/23/15.
//  Copyright © 2015 Brittany Stewart. All rights reserved.
//
//  Class to setup local notification reminders

import Foundation

import UIKit
import EventKit
import EventKitUI

class ReminderDetail: UITableViewController, sendBack {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var soundTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repeatInterval: UISegmentedControl!
    
    var editingItem = false
    
    var toPass:String! = ""
    
    var selectedItem:CareItem!
    
    var soundName:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadSelectedItem()
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadSelectedItem() { // Load selected item if one exists

        if Session.SharedInstance.itemPassed > 0 {
            selectedItem = Session.SharedInstance.selectedItem
            
            if self.selectedItem.UUID.characters.count > 0 {
                
                if toPass.isEmpty {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.datePicker.date = self.selectedItem.date
                        self.titleField.text = self.selectedItem.title
                        self.repeatInterval.selectedSegmentIndex = self.selectedItem.index
                        
                        if self.selectedItem.soundTitle.characters.count > 0 {
                            self.soundTitle.text = self.selectedItem.soundTitle
                        }
                        else {
                            self.soundTitle.text = "Select Sound"
                        }
                    }
                }
            }
        }
    }
    
    func sendURLToPreviousVC(description: String) { // Get chosen sound from Sound Selection screen
        self.toPass = description
        
        if !toPass.isEmpty {
            
            if toPass != "None" {
            
                soundName = self.toPass + ".wav"
            }
            else {
                soundName = "Select Sound"
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.soundTitle.text = self.soundName
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) { // Segue to Sound Selection Screen
        if (segue.identifier == "soundSegue") {
            let reminderDetailController = segue!.destinationViewController as! SoundSelection;
            reminderDetailController.mDelegate = self
            
            print("prepare for segue")
            
        }
    }
    
    @IBAction func save(sender: UIButton) { // Save item and remove previously existing item if editing an item
        
        print("test save")
        
        let careItem = CareItem(date: datePicker.date, title: titleField.text!, UUID: NSUUID().UUIDString, index: repeatInterval.selectedSegmentIndex, soundTitle: soundName)
  
        if Session.SharedInstance.itemPassed == 1 {
            
            Session.SharedInstance.itemPassed = 0
            
            CareList.sharedInstance.removeItem(selectedItem)
        }

        CareList.sharedInstance.addItem(careItem)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }

}
