//
//  AlarmSelection.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 12/22/15.
//  Copyright © 2015 Brittany Stewart. All rights reserved.
//

import Foundation
import UIKit

protocol sendAlarm // Delegate to send selected alarm offset back to detail view
{
    func sendOffsetToPreviousVC(offset: Int, offsetName: String)
}

class AlarmSelection: UIViewController {
    
    @IBOutlet weak var alarmTableView: UITableView!
    
    var checked = [Bool](count: 9, repeatedValue: false)
    
    var url = NSURL()
    
    var mDelegate:sendAlarm?
    
    var selectedItemSound:CareItem!
    
    var arrOffsetNames: [String]?
    
    var arrOffsets: [Int]?
    
    var selectedOffset = 0
    
    override func viewDidLoad() { // Load arrays of offset names and corresponding offset values
        super.viewDidLoad()
        arrOffsetNames = ["At time of event", "5 minutes before", "15 minutes before", "30 minutes before", "1 hour before", "2 hours before", "1 day before", "2 days before", "1 week before"]
        arrOffsets = [0, -300, -900, -1800, -3600,-7200, -86400, -172800, -604800]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) { // Reset checkmarks and load previously selected offset if one exists
        self.resetChecks(alarmTableView)
        self.loadSelectedOffset()
    }
    
    func resetChecks(tableView: UITableView)
    {
        for i in 0...tableView.numberOfSections-1
        {
            for j in 0...tableView.numberOfRowsInSection(i)-1
            {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    cell.accessoryType = .None
                }
                
            }
        }
    }
    
    func loadSelectedOffset() { // Set offset index session variable
        
        selectedOffset = Session.SharedInstance.selectedOffset
        

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrOffsets!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { // Load cell with names of offsets and set checkmark
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")!
        
        cell.textLabel?.text = arrOffsetNames![indexPath.row]
        
        if checked[indexPath.row] == false {
            
            cell.accessoryType = .None
        }
        else if checked[indexPath.row] == true {
            
            cell.accessoryType = .Checkmark
        }
        

 
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { // Set session variables for selected offset and set checkmark
        
        print("selected")
        print(arrOffsetNames![indexPath.row])
        print(arrOffsets![indexPath.row])
        
        let offset = arrOffsets![indexPath.row]
        
        let offsetName = arrOffsetNames![indexPath.row]
        
        print(offset)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark
            {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            }
            else
            {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
                sendOffsetToPreviousVC(offset, offsetName: offsetName)
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark
            {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            }
            else
            {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
                sendOffsetToPreviousVC(arrOffsets![indexPath.row], offsetName: arrOffsetNames![indexPath.row])
            }
        }
    }
    
    func sendOffsetToPreviousVC(offset: Int, offsetName: String){ // Send selected offset back to detail view
        self.mDelegate?.sendOffsetToPreviousVC(offset, offsetName: offsetName)
        
    }
    
}
