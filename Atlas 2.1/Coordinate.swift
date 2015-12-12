//
//  Coordinate.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/12/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

public struct TileCoord
{
    var x:Double
    var y:Double
    
    func roundDown() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:Int(floor(x)), y:Int(floor(y)))
    }
    
    func roundUp() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:Int(ceil(x)), y:Int(ceil(y)))
    }
}

public struct DiscreteTileCoord
{
    var x:Int
    var y:Int
    
    func makePrecise() -> TileCoord
    {
        return TileCoord(x:Double(x), y:Double(y))
    }
}





public func CoordMake(x:Double, _ y:Double) -> TileCoord
{
    return TileCoord(x:x, y:y)
}

public func DiscreteCoordMake(x:Int, _ y:Int) -> DiscreteTileCoord
{
    return DiscreteTileCoord(x:x, y:y)
}





public func -(lhs:TileCoord, rhs:TileCoord) -> TileCoord
{
    return TileCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

public func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPointMake(lhs.x + rhs.x, lhs.y + rhs.y)
}





public func screenCameraDeltaForCoord(coord:TileCoord, cameraInWorld:TileCoord, tileSize:CGSize) -> CGPoint
{
    let deltaInWorld = coord - cameraInWorld
    return CGPointMake(CGFloat(deltaInWorld.x) * tileSize.width, CGFloat(deltaInWorld.y) * tileSize.height)
}

public func screenPosForCoord(coord:TileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    let screenCameraDelta = screenCameraDeltaForCoord(coord, cameraInWorld:cameraInWorld, tileSize:tileSize)
    return screenCameraDelta + cameraOnScreen
}

public func screenPosForTileViewAtCoord(coord:TileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    let screenPos = screenPosForCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
    return screenPos + CGPointMake(CGFloat(Double(tileSize.width) / 2.0), CGFloat(Double(tileSize.height) / 2.0))
}

public func screenPosForTileViewAtCoord(coord:DiscreteTileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    return screenPosForTileViewAtCoord(coord.makePrecise(), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
}