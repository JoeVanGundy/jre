//
//  PlaceTableViewController.swift
//  jre
//
//  Created by Edillower Wang on 3/26/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import Firebase

class PlaceTableViewController: UITableViewController {
    
    
    
    let ref = Firebase(url: "https://jrecse.firebaseio.com/posts")
    let userRef = Firebase(url: "https://jrecse.firebaseio.com/users")

    var placeID = ""
    var placeTitile = ""
    var mediaURL = ""
    var posts=[AnyObject]()
    var likeCountLocalRecord=[Int]()
    var unlikeCountLocalRecord=[Int]()
    var buttonEnabled=[Bool]()
    var reportEnabled=[Bool]()

    var flag=true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print("----------------")
        print(placeID)
        print("----------------")

        ref.queryOrderedByChild("post_placeID").queryEqualToValue(placeID)  //TODO: Add place key and target value
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                    for child in snapshot.children{
                        if((child.value["post_flag_count"] as! Int)<5){
                            self.posts.append(child)
                            self.likeCountLocalRecord.append(child.value["post_up_votes"] as! Int)
                            self.unlikeCountLocalRecord.append(child.value["post_down_votes"] as! Int)
                            if(self.userRef.authData != nil){
                                let userID = String(self.userRef.authData)
                                let voteRecord = child.value["post_user_voted"] as! String
                                if (voteRecord.rangeOfString(userID) != nil){
                                    self.buttonEnabled.append(false)
                                }else{
                                    self.buttonEnabled.append(true)
                                }
                            }else{
                                self.buttonEnabled.append(true)
                            }
                            
                            if(self.userRef.authData != nil){
                                let userID = String(self.userRef.authData)
                                let reportRecord = child.value["post_user_reported"] as! String
                                if (reportRecord.rangeOfString(userID) != nil){
                                    self.reportEnabled.append(false)
                                }else{
                                    self.reportEnabled.append(true)
                                }
                            }else{
                                self.reportEnabled.append(true)
                            }
                        }
                    }
                    self.tableView.reloadData()
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cell
        
        myCell.VideoPreview.image = UIImage(named: "test.jpg")
        
        let post_description = self.posts[indexPath.row].value["post_description"] as! String
        let post_creation_date = self.posts[indexPath.row].value["post_creation_date"] as! Double
        let likeCount=self.likeCountLocalRecord[indexPath.row]
        let unlikeCount=self.unlikeCountLocalRecord[indexPath.row]
        
        myCell.VideoDescription.text = post_description
        
        let date = NSDate(timeIntervalSince1970: post_creation_date)
        
        myCell.VideoInfo.text = "Posted at: " + String(date)
        
        myCell.VideoUpVotes.text = String(likeCount)
        
        myCell.VideoDownVotes.text = String(unlikeCount)
        
        myCell.upVoteButton.enabled=self.buttonEnabled[indexPath.row]
        
        myCell.upVoteButton.tag=indexPath.row
        
        myCell.upVoteButton.addTarget(self, action: #selector(PlaceTableViewController.upVoteAction(_:)), forControlEvents: .TouchUpInside)
        
        myCell.downVoteButton.enabled=self.buttonEnabled[indexPath.row]
        
        myCell.downVoteButton.tag=indexPath.row
        
        myCell.downVoteButton.addTarget(self, action: #selector(PlaceTableViewController.downVoteAction(_:)), forControlEvents: .TouchUpInside)
 
        return myCell
    }
    
    @IBAction func upVoteAction(sender: UIButton){
        
        if (userRef.authData != nil) {
            // user authenticated
            self.buttonEnabled[sender.tag]=false
            let likeCount=self.likeCountLocalRecord[sender.tag] + 1
            self.likeCountLocalRecord[sender.tag]=likeCount
            self.tableView.reloadData()
            
            let childName = self.posts[sender.tag].key
            let hopperRef = self.ref.childByAppendingPath(childName)
            let update = ["post_up_votes": likeCount]
            hopperRef.updateChildValues(update)
            
            var votedUser = self.posts[sender.tag].value["post_user_voted"] as! String
            votedUser.appendContentsOf(String(userRef.authData))
            let update2 = ["post_user_voted": votedUser]
            hopperRef.updateChildValues(update2)
        } else {
            // No user is signed in
            self.performSegueWithIdentifier("gotoLoginView", sender: nil)
        }

    }

    
    @IBAction func downVoteAction(sender: UIButton){
        if (userRef.authData != nil) {
            // user authenticated
            self.buttonEnabled[sender.tag]=false
            let unlikeCount=self.unlikeCountLocalRecord[sender.tag] + 1
            self.unlikeCountLocalRecord[sender.tag]=unlikeCount
            self.tableView.reloadData()
        
            let childName = self.posts[sender.tag].key
            let hopperRef = self.ref.childByAppendingPath(childName)
            let update = ["post_down_votes": unlikeCount]
            hopperRef.updateChildValues(update)
            
            var votedUser = self.posts[sender.tag].value["post_user_voted"] as! String
            votedUser.appendContentsOf(String(userRef.authData))
            let update2 = ["post_user_voted": votedUser]
            hopperRef.updateChildValues(update2)
        }else{
            self.performSegueWithIdentifier("gotoLoginView", sender: nil)
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tableViewToMediaPlayerView" {
            if let destination = segue.destinationViewController as? MediaPlayerViewController {
                
                destination.placeID = self.placeID
                destination.placeName = self.placeTitile
                destination.mediaURL = self.mediaURL
                
            }
        }
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(self.posts)
        print(indexPath.row)
        let mediaURLString = self.posts[indexPath.row].value["post_media_url"] as! String
        print("---------777---------")
        print(mediaURLString)
        self.mediaURL = mediaURLString
        print("---------888---------")
        print(self.mediaURL)
        self.performSegueWithIdentifier("tableViewToMediaPlayerView", sender: nil)
        
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Report Abuse", handler:{action, indexpath in
            
            if (self.userRef.authData != nil) {
                
                
                self.tableView.setEditing(false, animated: false)
                
                
                if (self.reportEnabled[indexPath.row]){
                    let alertController = UIAlertController(title: "Thanks!", message:
                        "Your report is submitted.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    
                    var reportCount = self.posts[indexPath.row].value["post_flag_count"] as! Int
                    let childName = self.posts[indexPath.row].key
                    
                    let hopperRef = self.ref.childByAppendingPath(childName)
                    reportCount = reportCount + 1
                    let update = ["post_flag_count": reportCount]
                    hopperRef.updateChildValues(update)
                    
                    var reportedUser = self.posts[indexPath.row].value["post_user_voted"] as! String
                    reportedUser.appendContentsOf(String(self.userRef.authData))
                    let update2 = ["post_user_reported": reportedUser]
                    hopperRef.updateChildValues(update2)
                    
                    self.reportEnabled[indexPath.row]=false

                }else{
                    let alertController = UIAlertController(title: "Thanks!", message:
                        "You have already reported this post.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                }
                

            }else{
                
                self.performSegueWithIdentifier("gotoLoginView", sender: nil)
            }
            
        })
        
        reportAction.backgroundColor = UIColor.redColor()
        
        return [reportAction]
        
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
