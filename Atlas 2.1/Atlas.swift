//
//  Atlas.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/16/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

enum OperatingState
{
    case RUNNING, HALTED, STEPPING
}

protocol IntelligentAgentDelegate
{
    func proceed()
    func nextAction()
    func halt()
}

struct Action
{
    var coord:DiscreteTileCoord
    var value:TileType
}

class Atlas : MapObserver
{
    var model:ModelDelegate?
    var bounds:TileRect?
    
    var operatingState:OperatingState = OperatingState.HALTED
    
    var cognitionRegulator:NSTimer = NSTimer()
    var actionRegulator:NSTimer = NSTimer()
    
    var actions:Queue<Action>
    
    var levelQuality:Double = 0.0
    var mostPromisingRoom:TileRect
    
    init()
    {
        self.actions = Queue<Action>()
        
        self.cognitionRegulator = NSTimer()
        self.actionRegulator = NSTimer()
        
        self.mostPromisingRoom = TileRect(left:0, right:0, up:0, down:0)
        
        self.initializeRegulators()
    }
    
    func initializeRegulators()
    {
        let cognitiveSpeed = 1.0/Double(30)
        let actionSpeed = 1.0/Double(10)
        
        cognitionRegulator = NSTimer.scheduledTimerWithTimeInterval(cognitiveSpeed, target:self, selector:"cognitiveCore:", userInfo:nil, repeats:true)
        actionRegulator = NSTimer.scheduledTimerWithTimeInterval(actionSpeed, target:self, selector:"actionCore:", userInfo:nil, repeats:true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Core Operators
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func halt()
    {
        operatingState = OperatingState.HALTED
    }
    
    func proceed()
    {
        operatingState = OperatingState.RUNNING
    }
    
    // Performs exactly one action and halts
    func nextAction()
    {
        operatingState = OperatingState.STEPPING
    }
    
    @objc func cognitiveCore(timer:NSTimer)
    {
        if (operatingState != .HALTED)
        {
            if (actions.count < 10)
            {
                // RANDOM ACTION
                
//                let randomX = randIntBetween(bounds!.left, stop:bounds!.right)
//                let randomY = randIntBetween(bounds!.down, stop:bounds!.up)
//                let randomCoord = DiscreteTileCoord(x:randomX, y:randomY)
//                let randomValue = TileClasses.nonVoid.randomElement()
//                
//                let randomAction = Action(coord:randomCoord, value:randomValue)
//                actions.enqueue(randomAction)
                
                evaluate()
                decide()
            }
        }
    }
    
    @objc func actionCore(timer:NSTimer)
    {
        if (operatingState != .HALTED)
        {
            // WARXING: Perform the next action on the queue
            
            if (!actions.isEmpty())
            {
                if let nextAction = actions.dequeue()
                {
                    model?.setTileAt(nextAction.coord, type:nextAction.value)
                }
            }
            
            if (operatingState == .STEPPING)
            {
                operatingState = .HALTED
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Map Observer
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func registerModelDelgate(delegate:ModelDelegate)
    {
        model = delegate
        bounds = model!.getBounds()
    }
    
    func changeOccurredAt(coord:DiscreteTileCoord)
    {
        // Assume that all changes are a threat to the goal
        actions.clear()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Hard-Coded Cognition
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func evaluate()
    {
        // Check the map: How "Good" is the rectangular room with walls?
        
        
        
        // Evaluate our most promising room candidate
//        mostPromisingRoom.width()
        
        
        let areaInfo = distribution(TileRect(left:9, right:11, up:11, down:9))
        
        if let floorCoverage = areaInfo.distribution[.FLOOR]
        {
            levelQuality = floorCoverage
        }
        else
        {
            levelQuality = 0.0
        }
    }
    
    func decide()
    {
        let areaInfo = distribution(TileRect(left:9, right:11, up:11, down:9))
        
        if (levelQuality < 1.0)
        {
            for (type, coordArray) in areaInfo.tiles
            {
                if (type != .FLOOR)
                {
                    for coord in coordArray
                    {
                        let action = Action(coord:coord, value:.FLOOR)
                        actions.enqueue(action)
                    }
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Additional Cognition
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func evaluateRoom(area:TileRect) -> Double
    {
        var roomQuality = 0.0
        
        if (area.width() > 2 && area.height() > 2)
        {
            roomQuality = 1.0
        }
        
        return roomQuality
    }
    
    func distribution(region:TileRect) -> (distribution:[TileType:Double], tiles:[TileType:[DiscreteTileCoord]])
    {
        var totalTiles = 0
        var tileCount = [TileType:Int]()
        var tiles = [TileType:[DiscreteTileCoord]]()
        
        for x in region.left...region.right
        {
            for y in region.down...region.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                if let type = model!.tileAt(coord)
                {
                    if let count = tileCount[type]
                    {
                        tileCount[type] = count+1
                    }
                    else
                    {
                        tileCount[type] = 1
                    }
                    
                    if let _ = tiles[type]
                    {
                        tiles[type]?.append(coord)
                    }
                    else
                    {
                        tiles[type] = [coord]
                    }
                    
                    totalTiles++
                }
            }
        }
        
        var proportions = [TileType:Double]()
        
        for (type, count) in tileCount
        {
            proportions[type] = Double(count) / Double(totalTiles)
        }
        
        return (distribution:proportions, tiles:tiles)
    }
}