//
//  SecondViewController.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 9/8/15.
//  Copyright (c) 2015 Brittany Stewart. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var eventStore : EKEventStore = EKEventStore()
    
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet weak var eventsTableView: UITableView!
    
    var calendars: [EKCalendar]?
    
    var vetCalendar: EKCalendar!
    
    var selectedEvent: EKEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Session.SharedInstance.selectedEvent = -1 // Reset session variable
    }
    
    override func viewWillAppear(animated: Bool) {
        checkCalendarAuthorizationStatus() // Check for calendar permission
        Session.SharedInstance.selectedEvent = -1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkCalendarAuthorizationStatus() {   // Check for calendar permission and proceed with loading the table if granted
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            self.needPermissionView.hidden = true
            self.eventsTableView.hidden = false
            loadCalendars()
            createCalendars()
            refreshTableView()
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            print( "Denied" )
        }
    }
    
    func requestAccessToCalendar() { // Ask for calendar permission and proceed with loading the table if granted
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    self.needPermissionView.hidden = true
                    self.eventsTableView.hidden = false
                    self.loadCalendars()
                    self.createCalendars()
                    self.refreshTableView()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
            }
        })
    }
    
    func loadCalendars() {  // Load list of calendars from event store
        self.calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
    }
    
    func refreshTableView() { // Refresh table
        eventsTableView.hidden = false
        eventsTableView.reloadData()
    }
    
    @IBAction func goToSettingsButtonTapped(sender: UIButton) {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // Number of rows is equal to the number of events in the event store
        
        if vetCalendar == nil {
            return 0
        }
        
        let startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
        let endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [self.vetCalendar])
        
    
        let eV = eventStore.eventsMatchingPredicate(predicate) as [EKEvent]

        return eV.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { // Load each cell with event title
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")!
        
        let startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
        let endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
        let predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [self.vetCalendar])
        
        let eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]
        
        if eV.count > 0 {
                cell.textLabel?.text = eV[indexPath.row].title
        } else {
            cell.textLabel?.text = "New Appointment"
        }
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Delete event when selected
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
            let endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
            let predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [vetCalendar])
            
            var eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]!
            
            do {
                try
                    eventStore.removeEvent(eV[indexPath.row], span: EKSpan.ThisEvent, commit: true)
            }
            catch {
                print("Could not remove event")
            }
            eventsTableView.reloadData()
            self.navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { // Set session variables when event is selected for editing
        
        let startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
        let endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
        let predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [vetCalendar])
        
        var eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]!
        
        selectedEvent = eV[indexPath.row]
        
        Session.SharedInstance.selectedEvent = indexPath.row

    }
    
    func createCalendars() { // Create the Vet Appointment calendar for the app if it does not already exist
        
        var calendarExists = false
        
        for calendar in calendars! {
            if calendar.title == "Vet Appointments" {
                calendarExists = true
                vetCalendar = calendar
            }
        }
        
        if calendarExists == false {
            let newCalendar = EKCalendar(forEntityType: EKEntityType.Event, eventStore: eventStore)
            newCalendar.title = "Vet Appointments"
        
            let sourcesInEventStore = eventStore.sources as [EKSource]
        
            if sourcesInEventStore.count > 0 {
                newCalendar.source = sourcesInEventStore.filter{
                    (source: EKSource) -> Bool in
                    source.sourceType == EKSourceType.Local
                    }.first!
            }
            else {
                self.navigationItem.rightBarButtonItem!.enabled = false
                let alert = UIAlertController(title: "Calendar could not save", message: "Calendar could not be created. Please exit and reload app.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(OKAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        

            do {
                try eventStore.saveCalendar(newCalendar, commit:true)
            } catch {
                self.navigationItem.rightBarButtonItem!.enabled = false
                let alert = UIAlertController(title: "Calendar could not save", message: "Calendar could not save", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(OKAction)
            
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        
            vetCalendar = newCalendar
            
            NSUserDefaults.standardUserDefaults().setObject(newCalendar.calendarIdentifier, forKey: "VetApptCalendar")
        }
    }
}
