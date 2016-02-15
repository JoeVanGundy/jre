//
//  ReviewsViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 11/15/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var restaurantNames = [""]
    @IBOutlet weak var tableView: UITableView!
    var textArray: NSMutableArray! = NSMutableArray()
    
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        print("Hello")
//        for name in restaurantNames{
//            print(name)
//            self.textArray.addObject(name)
//        }
//        self.view.setNeedsDisplay()
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFQuery(className: "Reviews")
        var names = query.findObjects() as! [PFObject]
        var done = false
        for name in names { // message is of PFObject type
            if done == false {
                self.textArray.addObject(name["placeName"]!)
                //   print(name)
            }
        }
        done = true
        
        
        
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.textArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.textArray.objectAtIndex(indexPath.row) as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        print(currentCell.textLabel!.text)
        performSegueWithIdentifier("reviewsToVideo", sender: self)
        //print("You selected cell #\(indexPath.row)!")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "reviewsToVideo") {
            var svc = segue.destinationViewController as! VideoPlayerViewController
            let indexPath = tableView.indexPathForSelectedRow!
            
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            
            svc.restaurantName = (currentCell.textLabel?.text)!
            
        }
    }

}
