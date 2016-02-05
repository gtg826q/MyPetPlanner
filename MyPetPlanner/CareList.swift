//
//  CareList.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 12/29/15.
//  Copyright © 2015 Brittany Stewart. All rights reserved.
//

import Foundation
import UIKit

class CareList { // Class for list of care reminders which can be accessed by the other classes
    class var sharedInstance : CareList {
        struct Static {
            static let instance : CareList = CareList()
        }
        return Static.instance
    }
    
    private let ITEMS_KEY = "careItems"
    
    func allItems() -> [CareItem] { // Load items from stored dictionary and return array
        var careDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? [:]
        let items = Array(careDictionary.values)
        return items.map({CareItem(date: $0["date"] as! NSDate, title: $0["title"] as! String, UUID: $0["UUID"] as! String!, index: $0["index"] as! Int, soundTitle: $0["soundTitle"] as! String)}).sort({(left: CareItem, right:CareItem) -> Bool in
            (left.date.compare(right.date) == .OrderedAscending)
        })
    }
    
    func addItem(item: CareItem) { // Add new item and schedule notification
        var careDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary()
        careDictionary[item.UUID] = ["date": item.date, "title": item.title, "UUID": item.UUID, "index": item.index, "soundTitle": item.soundTitle]
        NSUserDefaults.standardUserDefaults().setObject(careDictionary, forKey: ITEMS_KEY)
        
        var notification = UILocalNotification()
        notification.alertTitle = item.title
        notification.alertBody = "care Item \"\(item.title)\" Is Overdue"
        notification.alertAction = "open"
        notification.fireDate = item.date
        notification.soundName = item.soundTitle
        notification.userInfo = ["title": item.title, "UUID": item.UUID]
        notification.category = "care_CATEGORY"
  
        switch (item.index) {
        case 1:
            notification.repeatInterval = NSCalendarUnit.Minute;
            break;
        case 2:
            notification.repeatInterval = NSCalendarUnit.Hour;
            break;
        case 3:
            notification.repeatInterval = NSCalendarUnit.Day;
            break;
        case 4:
            notification.repeatInterval = NSCalendarUnit.Weekday;
            break;
        default:
            break;
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        self.setBadgeNumbers()
    }
    
    func removeItem(item: CareItem) { // Cancel notification and remove from stored dictionary
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] {
            if (notification.alertTitle! as String == item.title) {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
        }
        
        if var careItems = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) {
            careItems.removeValueForKey(item.UUID)
            NSUserDefaults.standardUserDefaults().setObject(careItems, forKey: ITEMS_KEY)
        }
        
        self.setBadgeNumbers()
    }
    
    func setBadgeNumbers() { // Set app badge number for all overdue items that do not repeat
        var notifications = UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification]
        var careItems: [CareItem] = self.allItems()
        
        for notification in notifications {
            var overdueItems = careItems.filter({ (careItem) -> Bool in
                return (careItem.date.compare(notification.fireDate!) != .OrderedDescending && careItem.index == 0)
            })
            
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            notification.applicationIconBadgeNumber = overdueItems.count
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
}