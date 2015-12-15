//
//  GameScene.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/11/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

import UIKit
import SpriteKit

class AtlasScene:SKScene,PanHandler,PinchHandler,GestureHandler
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var tiles:SKTextureAtlas
    
    var mapView:MapView
    var editorPanel:EditorViewPanel
    var map:TileMap
    var atlas:Atlas
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Control
    //////////////////////////////////////////////////////////////////////////////////////////
    var gestureInProgress:Bool = false

    override init(size:CGSize)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        tiles = SKTextureAtlas(named:"Tiles")
        
        let tileSize = CGSizeMake(35, 35)
        let mapViewSize = CGSizeMake(700, 560)
        
        let mapBounds = TileRect(left:0, right:12, up:12, down:0)
        map = TileMap(bounds:mapBounds, random:false)
        
        mapView = MapView(viewSize:mapViewSize, tileSize:tileSize)
        map.registerObserver(mapView)
        mapView.position = CGPointMake(center.x, center.y + 50)
        
        editorPanel = EditorViewPanel(size:CGSizeMake(window.width, CGFloat(100)))
        editorPanel.position = CGPointMake(center.x, 0)
        
        atlas = Atlas()
        map.registerObserver(atlas)
        
        atlas.proceed()
        
        super.init(size:size)
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(mapView)
        self.addChild(editorPanel)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func update(currentTime: CFTimeInterval)
    {
//        let randomCoord = map.randomCoord()
//        let randomType = TileClasses.all.randomElement()
//        
//        map.setTileAt(randomCoord, type:randomType)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let firstTouch = touches.first
        {
            if (!gestureInProgress)
            {
                let _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:Selector("executeTouchesBeganAfterDelay:"), userInfo:["touch":firstTouch], repeats:false)
            }
        }
    }
    
    func executeTouchesBeganAfterDelay(timer:NSTimer)
    {
        if (!gestureInProgress)
        {
            let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
            let firstTouch = userInfo["touch"] as! UITouch
            
            // Check for selection changes
            editorPanel.selectAt(firstTouch)
            
            // Alter touched tile
            if let touchedTile = mapView.tileAtLocation(firstTouch.locationInNode(mapView))
            {
                map.setTileAt(touchedTile, type:editorPanel.selectedTileType)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let firstTouch = touches.first
        {
            if (!gestureInProgress)
            {
                let _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:Selector("executeTouchesMovedAfterDelay:"), userInfo:["touch":firstTouch], repeats:false)
            }
        }
    }
    
    func executeTouchesMovedAfterDelay(timer:NSTimer)
    {
        if (!gestureInProgress)
        {
            let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
            let firstTouch = userInfo["touch"] as! UITouch
            
            // Alter touched tile
            if let touchedTile = mapView.tileAtLocation(firstTouch.locationInNode(mapView))
            {
                map.setTileAt(touchedTile, type:editorPanel.selectedTileType)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        
    }
    
    func pan(delta:CGPoint)
    {
        mapView.pan(delta)
    }
    
    func pinch(delta:CGFloat)
    {
        mapView.rescale(delta)
    }
    
    func gestureBegan()
    {
        gestureInProgress = true
    }
    
    func gestureEnded()
    {
        gestureInProgress = false
    }
}
