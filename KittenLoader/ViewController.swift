//
//  ViewController.swift
//  KittenLoader
//
//  Created by Michael Tackes on 2/17/15.
//  Copyright (c) 2015 Michael Tackes. All rights reserved.
//
//  Kitten images from placekitten.com
//  Check http://placekitten.com/attribution.html for image attribution

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundColorBox: UIView!
    @IBOutlet var boxSizeSmall: [NSLayoutConstraint]!
    
    @IBOutlet weak var kittenButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var loadMethodToggle: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if boxSizeSmall == nil { return .Default }
        
        let lightBackground = boxSizeSmall[0].active
        
        if lightBackground {
            return .Default
        } else {
            return .LightContent
        }
    }
    
    // MARK: - User Tap Methods
    @IBAction func fetchKitten(sender: UIButton) {
        loadingStartAnimation()
        
        if loadMethodToggle.selectedSegmentIndex == 0 {
            if let kittenImage = badLoad() {
                loadingDoneAnimation(kittenImage)
                
            } else {
                loadingFailed()
            }
        } else if loadMethodToggle.selectedSegmentIndex == 1 {
            goodLoad(loadingDoneAnimation, failure: loadingFailed)
        } else { println("How did you get here?") }
    }
    
    @IBAction func closeKitten() {
        NSLayoutConstraint.activateConstraints(boxSizeSmall)
        self.setNeedsStatusBarAppearanceUpdate()
        activitySpinner.stopAnimating()
        UIView.animateWithDuration(0.5) {
            self.activitySpinner.alpha = 0
            self.imageView.alpha = 0
            self.kittenButton.alpha = 1
            self.backgroundColorBox.layoutIfNeeded()
        }
    }
    
    // MARK: - Loading Start/Stop Methods
    func loadingStartAnimation() {
        NSLayoutConstraint.deactivateConstraints(boxSizeSmall)
        self.setNeedsStatusBarAppearanceUpdate()
        activitySpinner.startAnimating()
        UIView.animateWithDuration(0.3) {
            self.kittenButton.alpha = 0
            self.activitySpinner.alpha = 1
            self.backgroundColorBox.layoutIfNeeded()
        }
    }
    
    func loadingDoneAnimation(image: UIImage) {
        imageView.image = image
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.activitySpinner.alpha = 0
            self.imageView.alpha = 1
            }) { (succeeded: Bool) in
                if succeeded {
                    self.activitySpinner.stopAnimating()
                } else {
                    println("loadingDoneAnimation failed!")
                }
        }
        
    }
    
    func loadingFailed() {
        println("failed to load image")
        closeKitten()
    }
    
    // MARK: - Download Image Methods
    func badLoad() -> UIImage? {
        let minSize = 100
        let maxHeight = Int(self.view.frame.height)
        let maxWidth = Int(self.view.frame.width)
        
        let width = Int(arc4random_uniform(UInt32(maxWidth) - UInt32(minSize))) + minSize
        let height = Int(arc4random_uniform(UInt32(maxHeight) - UInt32(minSize))) + minSize
        
        let data = NSData(contentsOfURL: NSURL(string: "http://placekitten.com/\(width)/\(height)")!)
        if let kittenData = data {
            return UIImage(data: kittenData)
        } else {
            return nil
        }
    }
    
    func goodLoad(completion: (UIImage) -> (), failure: () -> ()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            
            let image = self.badLoad()
            
            dispatch_async(dispatch_get_main_queue()) {
                if let checkedImage = image {
                    completion(checkedImage)
                } else {
                    failure()
                }
            }
        }
    }
}

