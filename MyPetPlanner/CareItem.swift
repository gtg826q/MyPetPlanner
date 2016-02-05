//
//  AtHomeItem.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 12/6/15.
//  Copyright © 2015 Brittany Stewart. All rights reserved.
//

import Foundation

struct CareItem { // Class for care reminders which includes all values needed to schedule notification
    var title: String
    var date: NSDate
    var UUID: String
    var index: Int
    var soundTitle: String
    
    init(date: NSDate, title: String, UUID: String, index: Int, soundTitle: String) {
        self.date = date
        self.title = title
        self.UUID = UUID
        self.index = index
        self.soundTitle = soundTitle
    }
    
    var isOverdue: Bool {
        return (NSDate().compare(self.date) == NSComparisonResult.OrderedDescending) 
    }
}