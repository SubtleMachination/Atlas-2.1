//
//  TileViewRegistry.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/14/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class TileViewRegistry
{
    // y, x
    var rows:[Int:[Int:SKSpriteNode]]
    // x, y
    var cols:[Int:[Int:SKSpriteNode]]
    
    init()
    {
        rows = [Int:[Int:SKSpriteNode]]()
        cols = [Int:[Int:SKSpriteNode]]()
    }
    
    func registerSpriteAtCoord(coord:DiscreteTileCoord, sprite:SKSpriteNode)
    {
        if let _ = rows[coord.y]
        {
            rows[coord.y]![coord.x] = sprite
        }
        else
        {
            var newRow = [Int:SKSpriteNode]()
            newRow[coord.x] = sprite
            rows[coord.y] = newRow
        }
        
        if let _ = cols[coord.x]
        {
            cols[coord.x]![coord.y] = sprite
        }
        else
        {
            var newCol = [Int:SKSpriteNode]()
            newCol[coord.y] = sprite
            cols[coord.y] = newCol
        }
    }
    
    func unregisterSpriteAtCoord(coord:DiscreteTileCoord) -> SKSpriteNode?
    {
        var sprite:SKSpriteNode?
        
        if let _ = rows[coord.y]
        {
            sprite = rows[coord.y]!.removeValueForKey(coord.x)
        }
        
        if let _ = cols[coord.x]
        {
            sprite = cols[coord.x]!.removeValueForKey(coord.y)
        }
        
        return sprite
    }
    
    func spriteRegisteredAt(coord:DiscreteTileCoord) -> Bool
    {
        if let _ = cols[coord.x]
        {
            if let _ = cols[coord.x]![coord.y]
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    func allCoords() -> Set<DiscreteTileCoord>
    {
        var coords = Set<DiscreteTileCoord>()
        
        for (x, col) in cols
        {
            for (y, _) in col
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                coords.insert(coord)
            }
        }
        
        return coords
    }
    
    func allSprites() -> Set<SKSpriteNode>
    {
        var sprites = Set<SKSpriteNode>()
        
        for (_, col) in cols
        {
            for (_, sprite) in col
            {
                sprites.insert(sprite)
            }
        }
        
        return sprites
    }
    
    func allData() -> [DiscreteTileCoord:SKSpriteNode]
    {
        var data = [DiscreteTileCoord:SKSpriteNode]()
        
        for (x, col) in cols
        {
            for (y, sprite) in col
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                data[coord] = sprite
            }
        }
        
        return data
    }
}