//
//  EditorTileButton.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/14/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class EditorTileButton : SKNode
{
    var size:CGSize
    var touchable:CGRect
    var selectionImage:SKSpriteNode
    
    init(size:CGSize, type:TileType)
    {
        self.size = size
        touchable = CGRectMake(-1*((size.width*1.2)/2.0), -1*((size.height*1.2)/2.0), size.width*1.2, size.height*1.2)
        
        let tileImage = SKSpriteNode(imageNamed:"square.png")
        
        if (type != .VOID)
        {
            let imageName = "\(textureNameForTileType(type)).png"
            tileImage.texture = SKTexture(imageNamed:imageName)
        }
        else
        {
            tileImage.color = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
            tileImage.colorBlendFactor = 1.0
        }
        
        tileImage.resizeNode(size.width, y:size.height)
        tileImage.position = CGPointZero
        tileImage.zPosition = 10
        
        selectionImage = SKSpriteNode(imageNamed:"square.png")
        selectionImage.resizeNode(size.width*1.15, y:size.height*1.15)
        selectionImage.position = CGPointZero
        selectionImage.zPosition = 1
        selectionImage.alpha = 0.0
        
        super.init()
    
        self.addChild(selectionImage)
        self.addChild(tileImage)
    }
    
    func select()
    {
        selectionImage.removeAllActions()
        let fadeAction = fadeTo(selectionImage, alpha:1.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        selectionImage.runAction(fadeAction)
    }
    
    func deselect()
    {
        selectionImage.removeAllActions()
        let fadeAction = fadeTo(selectionImage, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        selectionImage.runAction(fadeAction)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}