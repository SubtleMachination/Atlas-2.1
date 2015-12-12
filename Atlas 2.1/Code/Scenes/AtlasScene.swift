//
//  GameScene.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/11/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

import SpriteKit

class AtlasScene:SKScene
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var tiles:SKTextureAtlas
    
    var mapView:MapView

    override init(size:CGSize)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        tiles = SKTextureAtlas(named:"Tiles")
        
        let tileSize = CGSizeMake(10, 10)
        let mapViewSize = CGSizeMake(300, 300)
        mapView = MapView(viewSize:mapViewSize, tileSize:tileSize)
        mapView.position = center
        
        super.init(size:size)
        
        self.addChild(mapView)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
