//
//  Coordinate.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/12/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

struct TileCoord:Hashable
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
    
    var hashValue:Int
    {
        return "(\(x), \(y))".hashValue
    }
}

struct DiscreteTileCoord:Hashable
{
    var x:Int
    var y:Int
    
    func makePrecise() -> TileCoord
    {
        return TileCoord(x:Double(x), y:Double(y))
    }
    
    var hashValue:Int
    {
        return "(\(x), \(y))".hashValue
    }
}

struct TileRect
{
    var left:Int
    var right:Int
    var up:Int
    var down:Int
    
    func contains(coord:DiscreteTileCoord) -> Bool
    {
        return (coord.x <= right && coord.x >= left && coord.y <= up && coord.y >= down)
    }
    
    func compare(other:TileRect) -> Bool
    {
        return (other.left == left && other.right == right && other.up == up && other.down == down)
    }
    
    func width() -> Int
    {
        return (right-left)+1
    }
    
    func height() -> Int
    {
        return (up-down)+1
    }
}



func +(lhs:TileCoord, rhs:TileCoord) -> TileCoord
{
    return TileCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

func -(lhs:TileCoord, rhs:TileCoord) -> TileCoord
{
    return TileCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

func ==(lhs:TileCoord, rhs:TileCoord) -> Bool
{
    return (lhs.x == rhs.x) && (lhs.y == rhs.y)
}

func +=(inout lhs:TileCoord, rhs:TileCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

func +(lhs:DiscreteTileCoord, rhs:DiscreteTileCoord) -> DiscreteTileCoord
{
    return DiscreteTileCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

func -(lhs:DiscreteTileCoord, rhs:DiscreteTileCoord) -> DiscreteTileCoord
{
    return DiscreteTileCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

func ==(lhs:DiscreteTileCoord, rhs:DiscreteTileCoord) -> Bool
{
    return (lhs.x == rhs.x) && (lhs.y == rhs.y)
}

func +=(inout lhs:DiscreteTileCoord, rhs:DiscreteTileCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPointMake(lhs.x + rhs.x, lhs.y + rhs.y)
}

func -(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPointMake(lhs.x - rhs.x, lhs.y - rhs.y)
}

func += (inout lhs:CGPoint, rhs:CGPoint)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}



func screenDeltaForTileDelta(tileDelta:TileCoord, tileSize:CGSize) -> CGPoint
{
    return CGPointMake(CGFloat(tileDelta.x) * tileSize.width, CGFloat(tileDelta.y) * tileSize.height)
}

func screenCameraDeltaForCoord(coord:TileCoord, cameraInWorld:TileCoord, tileSize:CGSize) -> CGPoint
{
    let deltaInWorld = coord - cameraInWorld
    return CGPointMake(CGFloat(deltaInWorld.x) * tileSize.width, CGFloat(deltaInWorld.y) * tileSize.height)
}

func screenPosForCoord(coord:TileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    let screenCameraDelta = screenCameraDeltaForCoord(coord, cameraInWorld:cameraInWorld, tileSize:tileSize)
    return screenCameraDelta + cameraOnScreen
}

func screenPosForTileViewAtCoord(coord:TileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    let screenPos = screenPosForCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
    return screenPos + CGPointMake(CGFloat(Double(tileSize.width) / 2.0), CGFloat(Double(tileSize.height) / 2.0))
}

func screenPosForTileViewAtCoord(coord:DiscreteTileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    return screenPosForTileViewAtCoord(coord.makePrecise(), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
}

func tileCoordForScreenPos(pos:CGPoint, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> TileCoord
{
    let screenDelta = pos - cameraOnScreen
    let tileDelta = tileDeltaForScreenDelta(screenDelta, tileSize:tileSize)
    
    return cameraInWorld + tileDelta
}

func tileDeltaForScreenDelta(delta:CGPoint, tileSize:CGSize) -> TileCoord
{
    let tileDelta_x = Double(delta.x / tileSize.width)
    let tileDelta_y = Double(delta.y / tileSize.height)
    return TileCoord(x:tileDelta_x, y:tileDelta_y)
}