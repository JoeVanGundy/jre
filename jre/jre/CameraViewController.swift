//
//  CameraViewController.swift
//  jre
//
//  Created by Joey Van Gundy on 3/26/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoImageOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var closeCameraButton: UIButton!
    
    @IBOutlet weak var toggleFlashButton: UIButton!
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        
        do{
            let input =  try AVCaptureDeviceInput(device: backCamera)
            
            if(error == nil && captureSession?.canAddInput(input) != nil){
                captureSession?.addInput(input)
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                if(captureSession?.canAddOutput(stillImageOutput) != nil){
                    captureSession?.addOutput(stillImageOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    captureSession?.startRunning()
                }
            }
        }
        catch{
        
        }
    }

    @IBOutlet weak var tempImageView: UIImageView!
    
    func didPressTakePhoto(){
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                if(sampleBuffer != nil){
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                    var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.tempImageView.image = image
                    self.tempImageView.hidden = false
                    
                    
                     
                }
            })
        }
    }
    var didTakePhoto = Bool()
    func didPressTakeAnother(){
        if(didTakePhoto == true){
            tempImageView.hidden = true
            didTakePhoto = false
        }
        else{
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakeAnother()
        }
        
    }
    
    @IBAction func takeAnother(sender: AnyObject) {
        didPressTakeAnother()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
