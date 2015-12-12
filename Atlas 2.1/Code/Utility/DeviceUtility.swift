//
//  DeviceUtility.swift
//  Hexbreaker
//
//  Created by Dusty Artifact on 11/26/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

func isIpad() -> Bool
{
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
}