//
//  GameViewController.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/11/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController:UIViewController
{
    var scene:AtlasScene?
    
    // Control
    var panStart:CGPoint?
    var previousScale:CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:"handlePan:")
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.maximumNumberOfTouches = 2
        
        self.view!.addGestureRecognizer(panRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target:self, action:"handlePinch:")
        
        self.view!.addGestureRecognizer(pinchRecognizer)
        
        
        
        scene = AtlasScene(size:(skView.frame.size))
        
        skView.showsFPS = true
        skView.showsNodeCount = true

        scene!.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    
    func handlePan(recognizer:UIPanGestureRecognizer)
    {
        let location = recognizer.locationInView(recognizer.view)
        let spriteKitLocation = CGPointMake(location.x, -1*location.y)
        
        switch (recognizer.state)
        {
            case .Began:
                panStart = spriteKitLocation
                break
            case .Changed:
                if (recognizer.numberOfTouches() == 2)
                {
                    let delta = spriteKitLocation - panStart!
                    panStart = spriteKitLocation
                    scene?.pan(delta)
                }
                break
            case .Ended:
                panStart = nil
                break
            default:
                panStart = nil
                break
        }
    }
    
    func handlePinch(recognizer:UIPinchGestureRecognizer)
    {
        switch (recognizer.state)
        {
            case .Began:
                previousScale = recognizer.scale
                break
            case .Changed:
                if (recognizer.numberOfTouches() == 2)
                {
                    let trueDelta = recognizer.scale - previousScale!
                    previousScale = recognizer.scale
                    scene?.pinch(trueDelta)
                }
                break
            case .Ended:
                panStart = nil
                break
            default:
                panStart = nil
                break
        }
    }

    override func shouldAutorotate() -> Bool
    {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            return .AllButUpsideDown
        }
        else
        {
            return .All
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}
