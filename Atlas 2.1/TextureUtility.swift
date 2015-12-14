//
//  TextureUtility.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/12/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

func textureNameForTileType(type:TileType) -> String
{
    var textureName = "g1"
    
    switch (type)
    {
        case .FLOOR:
            textureName = "g1"
            break
        case .WALL:
            textureName = "w1"
            break
        default:
            break
    }
    
    return textureName
}