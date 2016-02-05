//
//  HelpfulLinks.swift
//  HandicappedPetsInfo
//
//  Created by Brittany Stewart on 1/3/16.
//  Copyright © 2016 Brittany Stewart. All rights reserved.
//

import Foundation
import UIKit

class HelpfulLinks: UIViewController  {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openURL(url:String!) {
        let targetURL=NSURL(string: url)
        
        let application=UIApplication.sharedApplication()
        
        application.openURL(targetURL!)
    }
    
    @IBAction func dodgerslistLink(sender: UIButton) {
        print("Test Save Date")
        // Notify the caller that a date was selected.
        
        self.openURL("http://www.dodgerslist.com")
    }

    @IBAction func dogfoodadvisorLink(sender: UIButton) {
        print("Test Save Date")
        // Notify the caller that a date was selected.
        
        self.openURL("http://www.dogfoodadvisor.com")
    }
    
}