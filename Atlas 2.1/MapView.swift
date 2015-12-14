//
//  MapView.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/11/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

enum MapState
{
    case UNLOADED, LOADED
}

class MapView : SKNode, MapObserver
{
    var tileViewNode:SKNode
    var tileTextures:SKTextureAtlas
    var tileSize:CGSize
    var viewSize:CGSize
    var viewBoundSize:CGSize
    var mapState:MapState = MapState.UNLOADED
    
    var registeredTiles:[DiscreteTileCoord:SKSpriteNode]
    
    var tileViewRect:TileRect?
    var modelDelegate:ModelDelegate?
    
    // TO MOVE TO MODEL:
    var cameraInWorld:TileCoord
    var cameraOnScreen:CGPoint
    
    init(viewSize:CGSize, tileSize:CGSize)
    {
        self.viewSize = viewSize
        self.tileSize = tileSize
        self.viewBoundSize = CGSizeMake(viewSize.width + (tileSize.width * 2.0), viewSize.height + (tileSize.height * 2.0))
        
        tileViewNode = SKNode()
        tileViewNode.position = CGPointZero
        
        tileTextures = SKTextureAtlas(named:"Tiles")
        
        cameraInWorld = TileCoord(x:0.0, y:0.0)
        cameraOnScreen = CGPointZero
        
        registeredTiles = [DiscreteTileCoord:SKSpriteNode]()
        
        super.init()

        self.addChild(tileViewNode)
        
        let guide_vertical = SKSpriteNode(imageNamed:"square.png")
        guide_vertical.resizeNode(1, y:15)
        guide_vertical.position = CGPointZero
        self.addChild(guide_vertical)
        
        let guide_horizontal = SKSpriteNode(imageNamed:"square.png")
        guide_horizontal.resizeNode(15, y:1)
        guide_horizontal.position = CGPointZero
        self.addChild(guide_horizontal)
        
        
        let borderWidth = (viewBoundSize.width - viewSize.width) * 10.0
        let borderHeight = (viewBoundSize.height - viewSize.height) * 10.0
        
        let borderLeft = SKSpriteNode(imageNamed:"square.png")
        borderLeft.resizeNode(borderWidth, y:viewBoundSize.height*1.5)
        borderLeft.position = CGPointMake(-1*((viewSize.width/2.0) + (borderWidth/2.0)), 0)
        borderLeft.color = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        borderLeft.colorBlendFactor = 1.0
        self.addChild(borderLeft)
        
        let borderRight = SKSpriteNode(imageNamed:"square.png")
        borderRight.resizeNode(borderWidth, y:viewBoundSize.height*1.5)
        borderRight.position = CGPointMake((viewSize.width/2.0) + (borderWidth/2.0), 0)
        borderRight.color = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        borderRight.colorBlendFactor = 1.0
        self.addChild(borderRight)
        
        let borderUp = SKSpriteNode(imageNamed:"square.png")
        borderUp.resizeNode(viewBoundSize.width*1.5, y:borderHeight)
        borderUp.position = CGPointMake(0, (viewSize.height/2.0) + (borderHeight/2.0))
        borderUp.color = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        borderUp.colorBlendFactor = 1.0
        self.addChild(borderUp)
        
        let borderDown = SKSpriteNode(imageNamed:"square.png")
        borderDown.resizeNode(viewBoundSize.width*1.5, y:borderHeight)
        borderDown.position = CGPointMake(0, -1*((viewSize.height/2.0) + (borderHeight/2.0)))
        borderDown.color = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        borderDown.colorBlendFactor = 1.0
        self.addChild(borderDown)
    }
    
    func addTileViewAt(coord:DiscreteTileCoord, type:TileType)
    {
        // Create a tile sprite for it
        if (type != .VOID)
        {
            let tileTextureName = textureNameForTileType(type)
            let tileSprite = SKSpriteNode(texture:tileTextures.textureNamed(tileTextureName))
            tileSprite.resizeNode(tileSize.width, y:tileSize.height)
            tileSprite.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            tileViewNode.addChild(tileSprite)
            
            // Register the tile with the ViewModel
            registeredTiles[coord] = tileSprite
        }
    }
    
    func removeTileViewAt(coord:DiscreteTileCoord)
    {
        if let tileSprite = registeredTiles[coord]
        {
            tileSprite.removeFromParent()
            registeredTiles.removeValueForKey(coord)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Observer
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func changeOccurredAt(coord:DiscreteTileCoord)
    {
        if (tileViewRect!.contains(coord))
        {
            // Delete that tile and re-draw it from scratch
            removeTileViewAt(coord)
            
            if let newType = modelDelegate?.tileAt(coord)
            {
                addTileViewAt(coord, type:newType)
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func pan(screenDelta:CGPoint)
    {
        let screenCameraDelta = CGPointMake(-1*screenDelta.x, -1*screenDelta.y)
        let tileCameraDelta = tileDeltaForScreenDelta(screenCameraDelta, tileSize:tileSize)
        cameraInWorld += tileCameraDelta
        
        repositionTilesInView(screenDelta)
        let rectInfo = recalculateTileRect()
        if (rectInfo.updateNeeded)
        {
            updateTilesInView(rectInfo.oldRect)
        }
    }
    
    func rescale(scaleDelta:CGFloat)
    {
        resizeTilesInView(scaleDelta)
        let rectInfo = recalculateTileRect()
        if (rectInfo.updateNeeded)
        {
            updateTilesInView(rectInfo.oldRect)
        }
    }
    
    func update()
    {

    }
    
    func reloadMap()
    {
        if let _ = modelDelegate
        {
            let mapBounds = modelDelegate!.getBounds()
            cameraInWorld = TileCoord(x:Double(mapBounds.left + mapBounds.right + 1)/2.0, y:Double(mapBounds.down + mapBounds.up + 1)/2.0)
            
            recalculateTileRect()
            completelyRedrawView()
        }
    }
    
    func recalculateTileRect() -> (updateNeeded:Bool, oldRect:TileRect?)
    {
        let rightScreenBound = CGFloat(viewBoundSize.width / 2.0)
        let leftScreenBound = -1.0 * rightScreenBound
        let upScreenBound = CGFloat(viewBoundSize.height / 2.0)
        let downScreenBound = -1.0 * upScreenBound
        
        let rightTileBound = tileCoordForScreenPos(CGPointMake(rightScreenBound, 0), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().x
        let leftTileBound = tileCoordForScreenPos(CGPointMake(leftScreenBound, 0), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().x
        let upTileBound = tileCoordForScreenPos(CGPointMake(0, upScreenBound), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().y
        let downTileBound = tileCoordForScreenPos(CGPointMake(0, downScreenBound), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().y
        
        let newTileViewRect = TileRect(left:leftTileBound, right:rightTileBound, up:upTileBound, down:downTileBound)
        
        var updateNeeded = true
        let oldTileViewRect = tileViewRect
        
        if let _ = oldTileViewRect
        {
            // Compare the old and new... are they the same?
            if (oldTileViewRect!.compare(newTileViewRect))
            {
                updateNeeded = false
            }
        }
        
        tileViewRect = newTileViewRect
        
        return (updateNeeded:updateNeeded, oldRect:oldTileViewRect)
    }
    
    func clearView()
    {
        for (coord, tileSprite) in registeredTiles
        {
            tileSprite.removeFromParent()
            registeredTiles.removeValueForKey(coord)
        }
    }
    
    func repositionTilesInView(screenDelta:CGPoint)
    {
        for (_, tileSprite) in registeredTiles
        {
            tileSprite.position += screenDelta
        }
    }
    
    func resizeTilesInView(scaleDelta:CGFloat)
    {
        let absoluteScaleDelta = 1.0 + scaleDelta
        tileSize = CGSizeMake(tileSize.width*absoluteScaleDelta, tileSize.height*absoluteScaleDelta)
        
        for (coord, tileSprite) in registeredTiles
        {
            tileSprite.resizeNode(tileSize.width, y:tileSize.height)
            tileSprite.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        }
    }
    
    // Redraws the entire view from scratch
    func updateTilesInView(oldRect:TileRect?)
    {
        if let _ = modelDelegate
        {
            // Remove the out-of-bounds coords
            for (coord, _) in registeredTiles
            {
                if (!tileViewRect!.contains(coord))
                {
                    removeTileViewAt(coord)
                }
            }
            
            // Add any new coords not already on the board
            for x in tileViewRect!.left...tileViewRect!.right
            {
                for y in tileViewRect!.down...tileViewRect!.up
                {
                    addMissingTiles(x, y:y)
                }
            }
        }
    }
    
    func addMissingTiles(x:Int, y:Int)
    {
        let coord = DiscreteTileCoord(x:x, y:y)
        
        if let _ = registeredTiles[coord]
        {
            
        }
        else
        {
            if let tileType = modelDelegate?.tileAt(coord)
            {
                addTileViewAt(coord, type:tileType)
            }
        }
    }
    
    func completelyRedrawView()
    {
        clearView()
        
        // Render the map
        for x in tileViewRect!.left...tileViewRect!.right
        {
            for y in tileViewRect!.down...tileViewRect!.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                if let tileType = modelDelegate?.tileAt(coord)
                {
                    addTileViewAt(coord, type:tileType)
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Delegate
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func registerModelDelgate(delegate:ModelDelegate)
    {
        modelDelegate = delegate
        
        reloadMap()
        
        mapState = MapState.LOADED
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Crap
    //////////////////////////////////////////////////////////////////////////////////////////

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}