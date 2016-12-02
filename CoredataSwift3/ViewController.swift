//
//  ViewController.swift
//  CoredataSwift3
//
//  Created by Amrit on 12/2/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test().newsAdded() // data Save
        
        //delete 
        
//        CoredataManager().deleteDataBaseOfNewsIfItDeletedFromBackEnd(newsID: 1000)
        
        CoredataManager().retriveSavedData(saveResult: { (data) in
            
            for dat in data{
                let id = dat.id
                let name = dat.name
                print(id)
                print(name)
            }
            }) { (unknownError) in
                if unknownError{
                    print("Data can't retrive")
                }
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

