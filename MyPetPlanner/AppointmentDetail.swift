//
//  AppointmentDetail.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 11/29/15.
//  Copyright © 2015 Brittany Stewart. All rights reserved.
//
//  Class to setup appointments

import Foundation

import UIKit
import EventKit
import EventKitUI

class AppointmentDetail: UITableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, sendDate, sendAlarm  {
    var eventStore : EKEventStore = EKEventStore()
    
    var calendars: [EKCalendar]?
    
    var dateSelected = 0
    
    var eventStartDate: NSDate!
    
    var eventEndDate: NSDate!
    
    var eventTitle = ""
    
    var editedEvent: EKEvent!
    
    var alarmDate: NSDate!
    
    var arrRepeatOptions: [String]?
    
    var indexOfSelectedRepeatOption = 0
    
    var vetCalendar: EKCalendar!
    
    var eventOffset = 0
    
    var eventOffsetName = ""
    
    var arrOffsetNames: [String]?
    
    var arrOffsets: [Int]?
    
    @IBOutlet weak var repeatIntervalPicker: UIPickerView!
    @IBOutlet weak var eventTitleField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var alarmDateLabel: UILabel!
    @IBOutlet weak var editEventTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        arrRepeatOptions = ["Never", "Every day", "Every 3 days", "Every week", "Every 2 weeks", "Every month", "Every six months", "Every year"]
        arrOffsetNames = ["At time of event", "5 minutes before", "15 minutes before", "30 minutes before", "1 hour before", "2 hours before", "1 day before", "2 days before", "1 week before"]
        arrOffsets = [0, -300, -900, -1800, -3600,-7200, -86400, -172800, -604800]
        self.loadCalendar()
        self.repeatIntervalPicker.reloadAllComponents()
        self.loadSelectedEvent()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadCalendar() { // Load app's Vet Appointments calendar
        self.calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        
        for calendar in calendars! {
            if calendar.title == "Vet Appointments" {
                vetCalendar = calendar
            }
        }
    }
    
    // Functions to setup repeat interval picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrRepeatOptions!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return arrRepeatOptions![row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.indexOfSelectedRepeatOption = row
    }
    
    func loadSelectedEvent() {// Load selected event if one exists
   
        let selectedEventIndex = Session.SharedInstance.selectedEvent
        
        if selectedEventIndex > -1 {
        
            let startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
            let endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
            let predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [vetCalendar])
        
            var eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]
        
            self.editedEvent = eV[selectedEventIndex]
        
            if self.editedEvent?.title.characters.count > 0 {
                
                self.determineIndexOfRepeatOption()
                
                eventTitle = self.editedEvent.title
                eventStartDate = self.editedEvent.startDate
                eventEndDate = self.editedEvent.endDate
                
                if self.editedEvent.hasAlarms {
                    print(self.editedEvent.alarms![0].relativeOffset)
                    eventOffset = Int(self.editedEvent.alarms![0].relativeOffset)
                    eventOffsetName = arrOffsetNames![(arrOffsets?.indexOf(eventOffset))!]
                    Session.SharedInstance.selectedOffset = (arrOffsets?.indexOf(eventOffset))!
                }
            }
        }
        reloadApptData()
    }
    
    func sendDateToPreviousVC(date: NSDate) { // Get chosen dates passed back form Date Selection screen
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd h:mm a"
        
        if (dateSelected == 1) {
            self.eventStartDate = date
        }
        else if (dateSelected == 2) {
            self.eventEndDate = date
        }
        else{
            self.alarmDate = date
        }
        reloadApptData()
    }
 
    func sendOffsetToPreviousVC(offset: Int, offsetName: String) { // Get chosen alarm offset from Alarm Selection screen

        self.eventOffset = offset
        
        self.eventOffsetName = offsetName
        
        reloadApptData()
    }
    
    func reloadApptData() { // Reload UI fields after selections are made
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd h:mm a"
        
        if self.eventTitle.characters.count > 0 {
            self.eventTitleField.text = self.eventTitle
        }
        if (self.eventStartDate == nil) {
            self.startDateLabel.text = "Select a start date..."
        }
        else{
            self.startDateLabel.text = dateFormatter.stringFromDate(self.eventStartDate)
        }
        if (self.eventEndDate == nil) {
            self.endDateLabel.text = "Select an end date..."
        }
        else{
            self.endDateLabel.text = dateFormatter.stringFromDate(self.eventEndDate)
        }
        if self.eventOffsetName == "" {
            self.alarmDateLabel.text = "+ Add a new alarm..."
        }
        else{
            self.alarmDateLabel.text = self.eventOffsetName
        }
        
        if self.indexOfSelectedRepeatOption > 0 {
            repeatIntervalPicker.selectRow(self.indexOfSelectedRepeatOption, inComponent: 0, animated: true)
        }
        else {
            repeatIntervalPicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func determineIndexOfRepeatOption () { // Determine index for repeat interval picker from previously selected event
        if (self.editedEvent.recurrenceRules != nil && self.editedEvent.recurrenceRules!.count > 0) {
            let rule = self.editedEvent.recurrenceRules![0]
    
            let frequency = rule.frequency;
            let interval = rule.interval;
    
            if (interval == 1){
                if (frequency == EKRecurrenceFrequency.Daily) {
                    self.indexOfSelectedRepeatOption = 1;
                }
                else if (frequency == EKRecurrenceFrequency.Weekly){
                    self.indexOfSelectedRepeatOption = 3;
                }
                else if (frequency == EKRecurrenceFrequency.Monthly){
                    self.indexOfSelectedRepeatOption = 5;
                }
                else{
                    self.indexOfSelectedRepeatOption = 7;
                }
            }
            else{
                if (frequency == EKRecurrenceFrequency.Daily) {
                    self.indexOfSelectedRepeatOption = 2;
                }
                else if (frequency == EKRecurrenceFrequency.Weekly){
                    self.indexOfSelectedRepeatOption = 4;
                }
                else{
                    self.indexOfSelectedRepeatOption = 6;
                }
            }
        }
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) { // Set date labels before segue to Date Selection screen
        if (segue.identifier == "selectStartDate") {
            dateSelected = 1
            self.eventTitle = self.eventTitleField.text!
            let selectDateController = segue!.destinationViewController as! SelectDate;
            selectDateController.mDelegate = self
        
            print("prepare for segue")
            
        }
        if (segue.identifier == "selectEndDate") {
            dateSelected = 2
            self.eventTitle = self.eventTitleField.text!
            let selectDateController = segue!.destinationViewController as! SelectDate;
            selectDateController.mDelegate = self
            
            print("prepare for segue")
            
        }
        if (segue.identifier == "selectAlarm") {
            self.eventTitle = self.eventTitleField.text!
            let selectAlarmController = segue!.destinationViewController as! AlarmSelection;
            selectAlarmController.mDelegate = self
            
            print("prepare for segue")
            
        }
    }
    
    @IBAction func saveTitle(sender: UITextField) { // Update title text field
        self.eventTitle = self.eventTitleField.text!
    }
    
    @IBAction func save(sender: UIButton) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd 'at' h:mm a"
        
        if (self.eventTitleField.text!.characters.count == 0) {
            return
        }
        
        if (self.eventStartDate == nil || self.eventEndDate == nil) {
            return
        }
        
        let event:EKEvent = EKEvent(eventStore: eventStore)
        event.title = self.eventTitleField.text!
        event.startDate = self.eventStartDate
        event.endDate = self.eventEndDate
        event.notes = self.eventTitleField.text!
        event.calendar = vetCalendar
        
        event.addAlarm(EKAlarm(relativeOffset: NSTimeInterval(eventOffset)))

        var frequency: EKRecurrenceFrequency
        var interval = 0
        
        switch (self.indexOfSelectedRepeatOption) {
        case 1:
            frequency = EKRecurrenceFrequency.Daily
            interval = 1
            break;
        case 2:
            frequency = EKRecurrenceFrequency.Daily
            interval = 3
        case 3:
            frequency = EKRecurrenceFrequency.Weekly
            interval = 1
        case 4:
            frequency = EKRecurrenceFrequency.Weekly
            interval = 2
        case 5:
            frequency = EKRecurrenceFrequency.Monthly
            interval = 1
        case 6:
            frequency = EKRecurrenceFrequency.Monthly
            interval = 6
        case 7:
            frequency = EKRecurrenceFrequency.Yearly
            interval = 1
            
        default:
            interval = 0
            frequency = EKRecurrenceFrequency.Daily
            break;
        }
        
        if (interval > 0) {
            let recurrenceEnd = EKRecurrenceEnd(endDate: event.endDate)
            let rule = EKRecurrenceRule(recurrenceWithFrequency: frequency, interval: interval, end: recurrenceEnd)
            event.recurrenceRules = [rule]
        }
        else{
            event.recurrenceRules = nil;
        }
        
        if Session.SharedInstance.selectedEvent > -1 {
            
            do {
                try eventStore.removeEvent(self.editedEvent, span: EKSpan.ThisEvent)
                print("Removed old event")
            } catch {
                print("Remove Error")
            }
            
            do {
                try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                print("Saved Event")
            } catch {
                print("Error")
            }
        
        }
        else {
            do {
                try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                print("Saved Event")
            } catch {
                print("Error")
            }
        }
        
        Session.SharedInstance.selectedEvent = -1
        
        self.navigationController?.popToRootViewControllerAnimated(true) 
    }
    
}

