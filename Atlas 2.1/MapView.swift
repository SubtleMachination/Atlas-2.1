//
//  MapView.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/11/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class MapView:SKNode
{
    var tileViewNode:SKNode
    var tileTextures:SKTextureAtlas
    var tileSize:CGSize
    
    // TO MOVE TO MODEL:
    var cameraInWorld:TileCoord
    var cameraOnScreen:CGPoint
    
    init(viewSize:CGSize, tileSize:CGSize)
    {
        self.tileSize = tileSize
        
        tileViewNode = SKNode()
        tileViewNode.position = CGPointZero
        
        tileTextures = SKTextureAtlas(named:"Tiles")
        
        cameraInWorld = TileCoord(x:0.0, y:0.0)
        cameraOnScreen = CGPointZero
        
        super.init()
        
        let mapWidth = 4
        let mapHeight = 3
        
        for x in 0..<mapWidth
        {
            for y in 0..<mapHeight
            {
                let tileCoord = DiscreteTileCoord(x:x, y:y)
                print(tileCoord)
                let discreteTileCoord = tileCoord.makePrecise()
                let textureName = coinFlip() ? "g1" : "w1"
                let sprite = SKSpriteNode(texture:tileTextures.textureNamed(textureName))
                sprite.resizeNode(tileSize.width, y:tileSize.height)
                let tilePosition = screenPosForTileViewAtCoord(discreteTileCoord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
                sprite.position = tilePosition
                tileViewNode.addChild(sprite)
            }
        }

        self.addChild(tileViewNode)
        
        let guide_vertical = SKSpriteNode(imageNamed:"square.png")
        guide_vertical.resizeNode(1, y:15)
        guide_vertical.position = CGPointZero
        self.addChild(guide_vertical)
        
        let guide_horizontal = SKSpriteNode(imageNamed:"square.png")
        guide_horizontal.resizeNode(15, y:1)
        guide_horizontal.position = CGPointZero
        self.addChild(guide_horizontal)
    }
    
    

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}