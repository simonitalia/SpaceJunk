//
//  GameScene.swift
//  SpaceJunk
//
//  Created by Simon Italia on 2/16/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfieldBackground: SKEmitterNode!
    var playerCharacter: SKSpriteNode!
    
    var enemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer!
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = ("Score: \(score)")
        }
    }
    
    override func didMove(to view: SKView) {
        
        //Create starfieldBackground object and add to scene
        backgroundColor = UIColor.black
        starfieldBackground = SKEmitterNode(fileNamed: "Starfield")
        starfieldBackground.position = CGPoint(x: 1024, y: 384)
        starfieldBackground.advanceSimulationTime(10)
        starfieldBackground.zPosition = -1
        addChild(starfieldBackground)
        
        //Create playerCharacter / ship object and add to scene
        playerCharacter = SKSpriteNode(imageNamed: "player")
        playerCharacter.position = CGPoint(x:100, y: 384)
        playerCharacter.physicsBody = SKPhysicsBody(texture: playerCharacter.texture!, size: playerCharacter.size)
        playerCharacter.physicsBody?.contactTestBitMask = 1
            //Collision detection configuration
        addChild(playerCharacter)
        
        //Create scoreLabel object and add to scene
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.color = UIColor.white
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        //Configure scene gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //Create gameTimer
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //Determine where player touched, and position characterNode at touchedLocation
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touched = touches.first else {return}
        var touchedLocation = touched.location(in: self)
        
        //Clamp all touch points below Y 100 to Y 100
        if touchedLocation.y < 100 {
            touchedLocation.y = 100
        
        //Clamp all touch points above Y 668 to Y 668
        } else if touchedLocation.y > 668 {
            touchedLocation.y = 668
        }
        
        playerCharacter.position = touchedLocation
        
    }
    
    @objc func createEnemy() {
        
        //Randomize order of enemies array
        enemies.shuffle()
        
        //Get enemy from inside array position 0, add to scene
        let enemy = SKSpriteNode(imageNamed: enemies[0])
        enemy.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(enemy)
        
        //Configure enemy physics and contactTestBitMask
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.contactTestBitMask = 1
        enemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemy.physicsBody?.angularVelocity = 5
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.angularDamping = 0
        
    }
    
    //Remove enemy node from scene once it has moved off screen via update() method
    override func update(_ currentTime: TimeInterval) {
        
        for enemy in children {
            if enemy.position.x < -300 {
                enemy.removeFromParent()
            }
        }
        
        //Update player score
        if !isGameOver {
            score += 1
        }

    }//End update()
    
    //playerCharacter node hit by enemy node handler
    
    func didBegin(_ contact: SKPhysicsContact) {
        let playerCharacterExplode = SKEmitterNode(fileNamed: "explosion")!
        playerCharacterExplode.position = playerCharacter.position
        addChild(playerCharacterExplode)
        
        playerCharacter.removeFromParent()
        
        //Stop score from updating
        isGameOver = true
    }
    
}

