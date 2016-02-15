//
//  VideoPlayerViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 11/17/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Parse

class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationItem!
    var restaurantName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = restaurantName
        print(restaurantName)
        var query = PFQuery(className: "Reviews")
        query.whereKey("placeName", equalTo: restaurantName)
        var names = query.findObjects() as! [PFObject]
        var videoFile = names[0]["reviewFile"]
        var videoFileFile = videoFile as! PFFile
        var videoFileURL = videoFileFile.url

        
        
        let videoURL = NSURL(string: videoFileURL!)
        let player = AVPlayer(URL: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.navigationItem.title = restaurantName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
