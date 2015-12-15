//
//  EditorPanel.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/14/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

enum PanelState
{
    case EXPANDED, COLLAPSED
}

class EditorViewPanel : SKNode
{
    var size:CGSize
    var selectedTileType:TileType = TileType.VOID
    
    var visualNode:SKNode
    
    var buttons:[TileType:EditorTileButton]
    
    var state:PanelState = PanelState.EXPANDED
    
    init(size:CGSize)
    {
        self.size = size
        
        visualNode = SKNode()
        visualNode.position = CGPointMake(0, (size.height / 2.0))
        
        let background = SKSpriteNode(imageNamed:"square.png")
        background.resizeNode(size.width, y:size.height)
        background.position = CGPointZero
        background.color = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1.0)
        background.colorBlendFactor = 1.0
        
        visualNode.addChild(background)
        
        let tileCount = TileClasses.all.count
        let useableDistance = size.width*0.80
        let tileSpacing = useableDistance / CGFloat(tileCount)
        let buttonSize = CGSizeMake(50, 50)
        
        buttons = [TileType:EditorTileButton]()
        
        var buttonCount = 0
        for tileType in TileClasses.all
        {
            let tileButton = EditorTileButton(size:buttonSize, type:tileType)
            tileButton.position = CGPointMake(-1*(useableDistance/2.0) + tileSpacing*CGFloat(buttonCount) + (tileSpacing/2.0), 0)
            buttonCount++
            visualNode.addChild(tileButton)
            
            buttons[tileType] = tileButton
        }
        
        super.init()
        
        self.addChild(visualNode)
        
        visuallySelectType(selectedTileType)
    }
    
    
    
    func selectAt(touch:UITouch)
    {
        var selectionChanged = false
        
        for (tileType, tileButton) in buttons
        {
            let location = touch.locationInNode(tileButton)
            if (tileButton.touchable.contains(location))
            {
                if (selectedTileType != tileType)
                {
                    selectionChanged = true
                    selectedTileType = tileType
                }
            }
        }
        
        if (selectionChanged)
        {
            visuallySelectType(selectedTileType)
        }
    }
    
    func visuallySelectType(newType:TileType)
    {
        for (tileType, tileButton) in buttons
        {
            if (tileType == newType)
            {
                tileButton.select()
            }
            else
            {
                tileButton.deselect()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}