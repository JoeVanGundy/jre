//
//  MediaPlayerViewController.swift
//  jre
//
//  Created by Edillower Wang on 3/29/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MediaPlayerViewController: UIViewController {
    
    var placeID = ""
    var placeName = ""
    var isVideo = false
    var mediaURL = ""

    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myVideoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaView.hidden = true
        myVideoView.hidden = true
        myImageView.hidden = true
        
        
        if(NSURL(string: mediaURL)!.pathExtension == "png"){

            isVideo = false
            displayImage()
            
        }
        else{
            isVideo = true
            playVideo()
        }

        // Do any additional setup after loading the view.
    }
    
    func displayImage(){
        
    }
    func playVideo(){
       
        
//        self.mediaView.hidden = false
//        self.myVideoView.hidden = false
//        self.isVideo = true
//        let player = AVPlayer(URL: NSURL(string: "http://s3.amazonaws.com/jrecse/A11D4FD6-C8A6-4A97-9B18-597E7F1D67D9-2209-000002B389A5FD96.mov")!)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.myVideoView.bounds
//        self.myVideoView.layer.addSublayer(playerLayer)
//        player.play()
//        
//        
//        // Add notification block
//        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem, queue: nil)
//        { notification in
//            let t1 = CMTimeMake(0, 100);
//            player.seekToTime(t1)
//            player.play()
//        }
        
//        let videoURL = NSURL(string: mediaURL)
//        let player = AVPlayer(URL: videoURL!)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(playerLayer)
//        player.play()
        let videoURL = NSURL(string: "http://desnhl4nu1gy2.cloudfront.net/0BE3BBC2-1BF8-49C8-A24E-0B87C790D802-1154-000000B263AAE181.mov")
        let player = AVPlayer(URL: videoURL!)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        player.play()


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    @IBAction func goBackButton(sender: AnyObject) {
        
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
