//
//  Movable.swift
//  Robotron2117
//
//  Created by Steve Sparks on 2/12/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import SpriteKit

class Movable : GameNode {
    var previousPosition : CGPoint = .zero

    var dead = false

    enum WalkDirection : String {
        case north = "north"
        case south = "south"
        case east = "east"
        case west = "west"
        
        func vector() -> CGVector {
            switch self {
            case .north: return CGVector(dx: 0, dy: -1)
            case .south: return CGVector(dx: 0, dy: 1)
            case .east: return CGVector(dx: 1, dy: 0)
            case .west: return CGVector(dx: -1, dy: 0)
            }
        }
        
        static func random() -> WalkDirection {
            switch (Int(arc4random() % 4)) {
            case 0: return .north
            case 1: return .south
            case 2: return .east
            default: return .west
            }
        }
        
        func reverse() -> WalkDirection {
            switch self {
            case .north: return .south
            case .south: return .north
            case .east: return .west
            case .west: return .east
            }
        }
        
        func spriteView() -> String {
            switch self {
            case .north: return "back"
            case .south: return "front"
            case .east: return "right"
            case .west: return "left"
            }
        }
    }
    
    var nodeSpeed : CGFloat = 1.0
    
    var lastWalkVector : CGVector = .zero
    
    func walk() {
        
    }
    
    // called when walker hits a wall
    func revert(_ obstacle: SKSpriteNode) {
        self.position = self.previousPosition
    }
    
    func move(_ direction : CGVector) -> Bool {
        guard !dead else {
            return false
        }
        previousPosition = position
        var vec = direction
        vec.dx *= nodeSpeed
        vec.dy *= nodeSpeed
        var pos = position
        pos.x = pos.x + vec.dx
        pos.y = pos.y + vec.dy
        
        let mySize = universe.frame.size
        let screenBorderWidth = universe.screenBorderWidth
        let borderRect = CGRect(x: screenBorderWidth*1.2, y: screenBorderWidth*2, width: mySize.width-(2.8*screenBorderWidth), height: mySize.height-(4*screenBorderWidth))
        if borderRect.contains(pos) {
            previousPosition = position
            lastWalkVector = vec
            position = pos
            return true
        }
        return false
    }

}


extension CGVector {
    var walkDirection : Movable.WalkDirection {
        switch (dx, dy) {
        case let (x, y) where y < 0 && fabs(y)>fabs(x): return .south
        case let (x, y) where x > 0 && fabs(y)<fabs(x): return .east
        case let (x, y) where x < 0 && fabs(y)<fabs(x): return .west
        case let (x, y) where y > 0 && fabs(y)>fabs(x): return .north
        default: return .south
        }
    }
}

