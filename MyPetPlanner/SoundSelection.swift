//
//  SoundSelection.swift
//  MyPetPlanner
//
//  Created by Brittany Stewart on 12/22/15.
//  Copyright © 2015 Brittany Stewart. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol sendBack // delegate to send selected sound back to detail view
{
    func sendURLToPreviousVC(url: String)
}

class SoundSelection: UIViewController, AVAudioPlayerDelegate  {

    @IBOutlet weak var soundsTableView: UITableView!
    
    let paths: [NSURL] = NSBundle.mainBundle().URLsForResourcesWithExtension("wav", subdirectory: "")!

    var checked = [Bool](count: 6, repeatedValue: false)
    
    var url = NSURL()
    
    var mDelegate:sendBack?
    
    //var selectedItemSound:CareItem!
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    
    var arrSounds: [String]?
    
    var soundIndex = -1
    
    
    override func viewDidLoad() {
        print("sound load")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        arrSounds = ["None", "iMacStartup", "MusicBox", "ComputerMagic", "ElectricalSweep", "Tone"] // array of sound titles
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillAppear(animated: Bool) {
        self.resetChecks(soundsTableView)
        self.loadSelectedItem() // load previously selected sound if one exists
    }

    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            if soundIndex > -1 {
                sendURLToPreviousVC(arrSounds![soundIndex])
            }
        }
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
 
    func loadSelectedItem() {

        //selectedItemSound = Session.SharedInstance.selectedItem
        
        if Session.SharedInstance.selectedSoundIndex > -1 {
            checked[Session.SharedInstance.selectedSoundIndex] = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return paths.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { // Load cells with sound titles and set checkmarks
        
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")!
        
        cell.textLabel?.text = arrSounds![indexPath.row]

        if checked[indexPath.row] == false {
            
            cell.accessoryType = .None
        }
        else if checked[indexPath.row] == true  || Session.SharedInstance.selectedSoundIndex == indexPath.row {
            
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { // Play sound when cell is selected and set checkmark

        if indexPath.row > 0 {
        
            let soundName = arrSounds![indexPath.row]
        
            var path = NSBundle.mainBundle().pathForResource(soundName, ofType: "wav")
        
            let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(soundName, ofType: "wav")!)
        
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: url)
                audioPlayer.prepareToPlay()
            audioPlayer.play()
            } catch {
                
                print("Could not load file.")
            }
        }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType != .Checkmark
            {
                cell.accessoryType = .Checkmark
                checked = [Bool](count: 6, repeatedValue: false)
                Session.SharedInstance.selectedSoundIndex = indexPath.row
                checked[indexPath.row] = true
                soundIndex = indexPath.row
            }
        }
        
        soundsTableView.reloadData();
    }
    


    func sendURLToPreviousVC(name: String){ // Send selected sound back to detail view
        self.mDelegate?.sendURLToPreviousVC(name)
        
    }

}