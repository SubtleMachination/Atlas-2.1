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
    var map:TileMap
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
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
        
        let tileSize = CGSizeMake(20, 20)
        let mapViewSize = CGSizeMake(500, 500)
        
        let mapBounds = TileRect(left:0, right:50, up:50, down:0)
        map = TileMap(bounds:mapBounds, random:true)
        
        mapView = MapView(viewSize:mapViewSize, tileSize:tileSize)
        map.registerObserver(mapView)
        mapView.position = center
        
        super.init(size:size)
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(mapView)
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
        let randomCoord = map.randomCoord()
        let randomType = TileClasses.all.randomElement()
        
        map.setTileAt(randomCoord, type:randomType)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
//        if let firstTouch = touches.first
//        {
//            let screenLocation = firstTouch.locationInNode(mapView)
//            let tileLocation = tileCoordForScreenPos(screenLocation, cameraInWorld:mapView.cameraInWorld, cameraOnScreen:mapView.cameraOnScreen, tileSize:mapView.tileSize)
//            let discreteTileLocation = tileLocation.roundDown()
//            print("screen: \(screenLocation), tile:\(discreteTileLocation)")
//        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        
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
