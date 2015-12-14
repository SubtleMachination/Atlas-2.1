//
//  Map.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/12/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

enum TileType
{
    case VOID, FLOOR, WALL
}

struct TileClasses
{
    static let all:[TileType] = [.VOID, .FLOOR, .WALL]
    static let nonVoid:[TileType] = [.FLOOR, .WALL]
}

protocol MapObserver
{
    func registerModelDelgate(delegate:ModelDelegate)
    func changeOccurredAt(coord:DiscreteTileCoord)
}

protocol ModelDelegate
{
    func tileAt(coord:DiscreteTileCoord) -> TileType?
    func getBounds() -> TileRect
}

class TileMap : ModelDelegate
{
    var tiles:[DiscreteTileCoord : TileType]
    var bounds:TileRect
    
    var observers:[MapObserver]
    
    init(bounds:TileRect, random:Bool)
    {
        self.bounds = bounds
        tiles = [DiscreteTileCoord : TileType]()
        
        observers = [MapObserver]()
        
        // Initialize tiles within bounds
        for x in bounds.left...bounds.right
        {
            for y in bounds.down...bounds.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                let tileType = (random) ? TileClasses.nonVoid.randomElement() : .VOID
                setTileAt(coord, type:tileType)
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Observers
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func registerObserver(observer:MapObserver)
    {
        observer.registerModelDelgate(self)
        observers.append(observer)
    }
    
    func notifyObserversOfChange(coord:DiscreteTileCoord)
    {
        for observer in observers
        {
            observer.changeOccurredAt(coord)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Access Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func withinBounds(coord:DiscreteTileCoord) -> Bool
    {
        return bounds.contains(coord)
    }
    
    func tileExistsAt(coord:DiscreteTileCoord) -> Bool
    {
        if let _ = tiles[coord]
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func tileAt(coord:DiscreteTileCoord) -> TileType?
    {
        return tiles[coord]
    }
    
    func getBounds() -> TileRect
    {
        return bounds
    }
    
    func setTileAt(coord:DiscreteTileCoord, type:TileType)
    {
        if withinBounds(coord)
        {
            if let oldType = tiles[coord]
            {
                if (oldType != type)
                {
                    tiles[coord] = type
                    notifyObserversOfChange(coord)
                }
            }
            else
            {
                tiles[coord] = type
                notifyObserversOfChange(coord)
            }
        }
    }
    
    func randomCoord() -> DiscreteTileCoord
    {
        let random_x = randIntBetween(bounds.left, stop:bounds.right)
        let random_y = randIntBetween(bounds.down, stop:bounds.up)
        
        return DiscreteTileCoord(x:random_x, y:random_y)
    }
    
    func setAllTiles(type:TileType)
    {
        for (coord, _) in tiles
        {
            setTileAt(coord, type:type)
        }
    }
    
    func randomizeAllTiles()
    {
        for (coord, _) in tiles
        {
            let randomType = TileClasses.all.randomElement()
            setTileAt(coord, type:randomType)
        }
    }
}