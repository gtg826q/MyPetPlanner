//
//  Session.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 1/2/16.
//  Copyright © 2016 Brittany Stewart. All rights reserved.
//

import Foundation

class Session { // Session class to store variables which can be accessed by the other classes
    static let SharedInstance = Session(selectedItem: CareItem(date: NSDate(),  title: "", UUID: "", index: -1, soundTitle: ""), itemPassed: 0, selectedEvent: -1, selectedOffset: -1, selectedSoundIndex: -1)
    
    var selectedItem: CareItem
    var itemPassed: Int
    var selectedEvent: Int
    var selectedOffset: Int
    var selectedSoundIndex: Int

    init(selectedItem: CareItem, itemPassed: Int, selectedEvent: Int, selectedOffset: Int, selectedSoundIndex: Int) {
        self.selectedItem = selectedItem
        self.itemPassed = itemPassed
        self.selectedEvent = selectedEvent
        self.selectedOffset = selectedOffset
        self.selectedSoundIndex = selectedSoundIndex
    }
    
}