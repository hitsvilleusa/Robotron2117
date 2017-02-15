//
//  GameUniverse+StateMachines.swift
//  Robotron2117
//
//  Created by Steve Sparks on 2/14/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import GameplayKit

protocol GameLevelDelegate : NSObjectProtocol {
    func levelOver(_ universe: GameUniverse)
}

class GameLevelStateMachine : GKStateMachine {
    weak var universe : GameUniverse?
    weak var levelDelegate : GameLevelDelegate?
    
    let playing = Playing()
    let ready = Ready()
    let won = Won()
    let lost = Lost()
    
    init(_ universe: GameUniverse) {
        super.init(states: [ready, playing, won, lost] )
        self.universe = universe
    }
    
    override func enter(_ stateClass: AnyClass) -> Bool {
        let ret = super.enter(stateClass)
        if ret, let universe = universe {
            switch(stateClass) {
            case is Ready.Type:
                universe.showReadyLabel({
                    _ = self.enter(Playing.self)
                })
            case is Playing.Type:
                universe.startGame()
            case is Won.Type:
                self.levelDelegate?.levelOver(universe)
            case is Lost.Type:
                gameOver()
            default: break;
            }
        }
        return ret
    }
    
    func gameOver() {
        if let universe = universe {
            self.levelDelegate?.levelOver(universe)
        }
    }
    
    public func begin() {
        _ = enter(Ready.self)
    }
    
    public func win() {
        _ = enter(Won.self)
    }
    
    public func lose() {
        _ = enter(Lost.self)
    }
    
    class Ready : GKState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Playing.self
        }
    }
    class Playing : GKState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Won.self || stateClass == Lost.self
        }
    }
    class Won : GKState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool { return false }
    }
    class Lost : GKState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool { return false }
    }
}

extension GameUniverse {
    func showReadyLabel(_ block: @escaping () -> Void) {
        let label = SKLabelNode(text: "LEVEL \(level)")
        label.fontName = UIFont.customFontName
        label.fontSize = 100
        let sz = self.frame.size
        label.position = CGPoint(x: sz.width/2.0, y: sz.height*0.6)
        addChild(label)
        
        let group = SKAction.group([SKAction.scale(to: 0.001, duration: 2), SKAction.fadeOut(withDuration: 2)])
        label.run(SKAction.sequence([group]), completion: {
            label.removeFromParent()
            block()
        })
    }

    func showGameOverLabel(_ block: @escaping () -> Void) {
        let label = SKLabelNode(text: "GAME OVER")
        label.fontName = UIFont.customFontName
        label.fontSize = 200
        let sz = self.frame.size
        label.position = CGPoint(x: sz.width/2.0, y: sz.height*0.6)
        addChild(label)
        
        let group = SKAction.group([SKAction.scale(to: 0.001, duration: 2), SKAction.fadeOut(withDuration: 2)])
        label.run(SKAction.sequence([group]), completion: {
            label.removeFromParent()
            block()
        })
    }

    func showLivesRemainingLabel(_ lives: Int, block: @escaping () -> Void) {
        let livesStr : String = {
            if lives==1 {
                return "LIFE"
            } else {
                return "LIVES"
            }
        }()
        
        let label = SKLabelNode(text: "\(lives) \(livesStr) LEFT")
        label.fontName = UIFont.customFontName
        label.fontSize = 100
        let sz = self.frame.size
        label.position = CGPoint(x: sz.width/2.0, y: sz.height*0.65)
        addChild(label)
        
        let group = SKAction.group([SKAction.scale(to: 0.001, duration: 2), SKAction.fadeOut(withDuration: 2)])
        label.run(SKAction.sequence([group]), completion: {
            label.removeFromParent()
            block()
        })
    }

}
