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
    var mapBounds:TileRect
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
        
        mapBounds = TileRect(left:0, right:0, up:0, down:0)
        
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
        if (type != .VOID)
        {
            let textureName = textureNameAtCoord(coord, type:type)
            
            let tileSprite = SKSpriteNode(texture:tileTextures.textureNamed(textureName))
            tileSprite.resizeNode(tileSize.width, y:tileSize.height)
            tileSprite.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            tileViewNode.addChild(tileSprite)
            
            // Register the tile with the ViewModel
            registeredTiles[coord] = tileSprite
        }
    }
    
    func addBlankAt(coord:DiscreteTileCoord)
    {
        let tileSprite = SKSpriteNode(imageNamed:"square.png")
        tileSprite.resizeNode(tileSize.width, y:tileSize.height)
        tileSprite.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        tileSprite.color = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
        tileSprite.colorBlendFactor = 1.0
        
        tileViewNode.addChild(tileSprite)
        registeredTiles[coord] = tileSprite
    }
    
    func removeTileViewAt(coord:DiscreteTileCoord)
    {
        if let tileSprite = registeredTiles[coord]
        {
            tileSprite.removeFromParent()
            registeredTiles.removeValueForKey(coord)
            
            // Update the tile above (in case it needs a texture swap)
            let tileAbove = DiscreteTileCoord(x:coord.x, y:coord.y+1)
            refreshTextureAtCoord(tileAbove)
        }
    }
    
    func textureNameAtCoord(coord:DiscreteTileCoord, type:TileType) -> String
    {
        var textureName = textureNameForTileType(type)
        let coordBelow = DiscreteTileCoord(x:coord.x, y:coord.y-1)
        
        if let coordBelowType = modelDelegate?.tileAt(coordBelow)
        {
            if (type == .WALL && coordBelowType != .WALL)
            {
                textureName += "a"
            }
        }
        else
        {
            // No tile exists below
            if (type == .WALL)
            {
                textureName += "a"
            }
        }
        
        return textureName
    }
    
    // Assumes a NON-VOID tile at specified coord
    func refreshTextureAtCoord(coord:DiscreteTileCoord)
    {
        if let type = modelDelegate?.tileAt(coord)
        {
            let textureName = textureNameAtCoord(coord, type:type)
            
            if let tileView = registeredTiles[coord]
            {
                tileView.texture = tileTextures.textureNamed(textureName)
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Observer
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func changeOccurredAt(coord:DiscreteTileCoord)
    {
        if (tileViewRect!.contains(coord))
        {
            if let newType = modelDelegate?.tileAt(coord)
            {
                if (newType == .VOID)
                {
                    removeTileViewAt(coord)
                }
                else
                {
                    if let _ = registeredTiles[coord]
                    {
                        // Refresh texture
                        refreshTextureAtCoord(coord)
                        // Refresh the texture above
                        refreshTextureAtCoord(DiscreteTileCoord(x:coord.x, y:coord.y+1))
                    }
                    else
                    {
                        addTileViewAt(coord, type:newType)
                        // Refresh the texture above
                        refreshTextureAtCoord(DiscreteTileCoord(x:coord.x, y:coord.y+1))
                    }
                }
            }
            else
            {
                removeTileViewAt(coord)
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
            mapBounds = modelDelegate!.getBounds()
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
        
        var newTileSize = CGSizeMake(tileSize.width*absoluteScaleDelta, tileSize.height*absoluteScaleDelta)
        
        if (newTileSize.width > CGFloat(50.0) || newTileSize.height > CGFloat(50.0))
        {
            // Enforce maximum zoom
            newTileSize = CGSizeMake(CGFloat(50), CGFloat(50))
        }
        
        if (newTileSize.width < CGFloat(20.0) || newTileSize.height < CGFloat(20.0))
        {
            // Enforce minimum zoom
            newTileSize = CGSizeMake(CGFloat(20), CGFloat(20))
        }
        
        let adjustment_x = abs(newTileSize.width - tileSize.width)
        let adjustment_y = abs(newTileSize.height - tileSize.height)
        
        if (adjustment_x > 0.01 || adjustment_y > 0.01)
        {
            tileSize = newTileSize
            
            for (coord, tileSprite) in registeredTiles
            {
                tileSprite.resizeNode(tileSize.width, y:tileSize.height)
                tileSprite.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            }
        }
    }
    
    // Redraws the entire view from scratch
    func updateTilesInView(oldRect:TileRect?)
    {
        if let _ = modelDelegate
        {
            if let oldRect = oldRect
            {
                if let newRect = tileViewRect
                {
                    let oldLeft = oldRect.left
                    let oldRight = oldRect.right
                    let oldUp = oldRect.up
                    let oldDown = oldRect.down
                    
                    let newLeft = newRect.left
                    let newRight = newRect.right
                    let newUp = newRect.up
                    let newDown = newRect.down
                    
                    let leftDelta = newLeft - oldLeft
                    let rightDelta = newRight - oldRight
                    let upDelta = newUp - oldUp
                    let downDelta = newDown - oldDown
                    
                    if (leftDelta > 0)
                    {
                        removeTilesInRect(oldLeft, right:newLeft-1, down:oldDown, up:oldUp)
                    }
                    else if (leftDelta < 0)
                    {
                        addMissingTilesInRect(newLeft, right:oldLeft-1, down:newDown, up:newUp)
                    }
                    
                    if (rightDelta > 0)
                    {
                        addMissingTilesInRect(oldRight+1, right:newRight, down:newDown, up:newUp)
                    }
                    else if (rightDelta < 0)
                    {
                        removeTilesInRect(newRight+1, right:oldRight, down:oldDown, up:oldUp)
                    }
                    
                    if (upDelta > 0)
                    {
                        addMissingTilesInRect(newLeft, right:newRight, down:oldUp+1, up:newUp)
                    }
                    else if (upDelta < 0)
                    {
                        removeTilesInRect(oldLeft, right:oldRight, down:newUp+1, up:oldUp)
                    }
                    
                    if (downDelta > 0)
                    {
                        removeTilesInRect(oldLeft, right:oldRight, down:oldDown, up:newDown-1)
                    }
                    else if (downDelta < 0)
                    {
                        addMissingTilesInRect(newLeft, right:newRight, down:newDown, up:oldDown-1)
                    }
                }
            }
            else
            {
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
    }
    
    func removeTilesInRect(left:Int, right:Int, down:Int, up:Int)
    {
        for x in left...right
        {
            for y in down...up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                removeTileViewAt(coord)
            }
        }
    }
    
    func addMissingTilesInRect(left:Int, right:Int, down:Int, up:Int)
    {
        for x in left...right
        {
            for y in down...up
            {
                addMissingTiles(x, y:y)
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
            else if !mapBounds.contains(coord)
            {
                addBlankAt(coord)
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
    
    func tileAtLocation(location:CGPoint) -> DiscreteTileCoord?
    {
        let tileLocation = tileCoordForScreenPos(location, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        let discreteTileLocation = tileLocation.roundDown()
        
        if (tileViewRect!.contains(discreteTileLocation))
        {
            return discreteTileLocation
        }
        else
        {
            return nil
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