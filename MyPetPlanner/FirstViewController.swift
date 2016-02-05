//
//  FirstViewController.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 9/8/15.
//  Copyright (c) 2015 Brittany Stewart. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var remindersTableView: UITableView!
    
    var careItems: [CareItem] = []

    var selectedItem:CareItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList", name: "careListShouldRefresh", object: nil)
        // Do any additional setup after loading the view, typically from a nib.

        refreshList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        refreshList()
    }
 
    func refreshList() {    // Reload table and disable the add button when the 64 notification limit is reached
        careItems = CareList.sharedInstance.allItems()
        if (careItems.count >= 64) {
            self.navigationItem.rightBarButtonItem!.enabled = false
        }
        
        Session.SharedInstance.itemPassed = 0
        Session.SharedInstance.selectedSoundIndex = -1
        selectedItem = Session.SharedInstance.selectedItem
        
        CareList.sharedInstance.setBadgeNumbers()
        remindersTableView.hidden = false
        remindersTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return careItems.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { // Load each cell with the notification title
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")!
        
        
        let careItem = careItems[indexPath.row] as CareItem
        
        cell.textLabel?.text = careItem.title as String!
        if (careItem.isOverdue) { // Show overdue items in red
            cell.detailTextLabel?.textColor = UIColor.redColor()
        } else {
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "'Due' MMM dd 'at' h:mm a"
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(careItem.date)
    
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { // Delete selected notification
        if editingStyle == .Delete {
            var item = careItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            CareList.sharedInstance.removeItem(item)
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { // Set session variables when an existing notification is selected for editing
        selectedItem = careItems[indexPath.row]
        Session.SharedInstance.selectedItem = selectedItem
        Session.SharedInstance.itemPassed = 1
    }
    
}

