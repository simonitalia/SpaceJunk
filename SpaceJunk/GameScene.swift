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
    
    //Parent / Container child node properties
    var spaceShip: SKSpriteNode!
    var laserBeam = SKSpriteNode()
    
    var laserButton: SKSpriteNode!
    var laserButtonLabel: SKLabelNode!
    
    var enemies = ["ball", "hammer", "tv"]
    var enemy = SKSpriteNode()
    var gameTimer: Timer!
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = ("Score: \(score)")
        }
    }
    
    //Property for handling laserBeam sound
//   var isSpaceShipAlive  true
    
    override func didMove(to view: SKView) {
        
        //Show physics info in scene
//        view.showsPhysics = true
        
        //Create starfieldBackground object and add to scene
        backgroundColor = UIColor.black
        starfieldBackground = SKEmitterNode(fileNamed: "Starfield")
        starfieldBackground.name = "starfield"
        starfieldBackground.position = CGPoint(x: 1024, y: 384)
        starfieldBackground.advanceSimulationTime(10)
        starfieldBackground.zPosition = -1
        addChild(starfieldBackground)
        
        //Create and add spaceShip to PlayerCharacter container
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.name = "spaceShip"
        spaceShip.zPosition = 1
        
        //spaceShip Physics
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.position = CGPoint(x:100, y: 384)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.contactTestBitMask = 1
            //This value mateches the enemy categoryBitMask
        addChild(spaceShip)
        
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
        
        //Create gameTimer timeInterval: 0.35
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        //Create laserButton object and add to scene
        laserButton = SKSpriteNode(imageNamed: "laserButton")
        laserButton.position = CGPoint(x:1024 - 60, y: 768 - 60)
        laserButton.name = "laserButton"
        laserButton.zPosition = 0
        addChild(laserButton)
        
        //Create laserButtonLabel
        laserButtonLabel = SKLabelNode(fontNamed: "Chalkduster")
        laserButtonLabel.color = UIColor.white
        laserButtonLabel.fontSize = 12
        laserButtonLabel.text = "PRESS ME"
        laserButtonLabel.position = CGPoint(x: 0, y: 0)
        laserButton.addChild(laserButtonLabel)
        
    }
    
    //Configure firing of laserBeam triggered by touch of laserButton
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Check game isn't over
        if isGameOver {
            return
        
        } else {
            
            //Create and add laserBeam to scene
            guard let touch = touches.first else { return }
            let touchLocation = touch.location(in: self)
            let touchedNodes = nodes(at: touchLocation)
            
            for touchedNode in touchedNodes {
                if touchedNode.name == "laserButton" {
                    
                    //Create laserBeam (Body A)
                    laserBeam = SKSpriteNode(imageNamed: "laserBeamGlow")
                    laserBeam.name = "laserBeam"
                    laserBeam.zPosition = 0
                    
                    //Position laserBeam at front of spaceship relative to playerCharacter container
                    laserBeam.position = CGPoint(x: 135, y: 0)
                    
                    //Give laserBeam a physicsBody
                    laserBeam.physicsBody = SKPhysicsBody(texture: laserBeam.texture!, size: laserBeam.size)
                    
                    //Collision values
                    laserBeam.physicsBody?.isDynamic = false
                    laserBeam.physicsBody?.categoryBitMask = 2
                        //Value matches the enemy contactBitMask
                    
                    //Play laserBeam firing sound
                    run(SKAction.playSoundFileNamed("laserBeamSound", waitForCompletion: false))
                    
                    //Add player to playerCharacter container
                    spaceShip.addChild(laserBeam)
                    
                    //Remove laserBeam image and node after x period
                    let wait = SKAction.wait(forDuration: 0.05)
                    let removeNode = SKAction.removeFromParent()
                    laserBeam.run(SKAction.sequence([wait, removeNode]))

                } //End if inner block
                
            } //End for loop
            
        } //End outer if, else  block
        
    } //End touchesBegan()
    
    //Determine where player touched and moves characterNode, position characterNode at touchedLocation
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touched = touches.first else {return}
        var touchedLocation = touched.location(in: self)
        
        //Clamp all touch points below Y 100 to Y 100
        if touchedLocation.y < 100 {
            touchedLocation.y = 100
        
        //Clamp all touch points above top of play area to top of play area
        } else if touchedLocation.y > 650 {
            touchedLocation.y = 650
        }
        
        //Move playerCharacter container node to touched location
        spaceShip.position = touchedLocation
        
    }
    
    //Detect if player stops touching spaceShip
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNodes = nodes(at: touchLocation)
        
        for touchedNode in touchedNodes {
            if touchedNode.name == "laserButton" {
                return
            }
        }
        
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = spaceShip.position
        spaceShip.removeFromParent()
        addChild(explosion)
        run(SKAction.playSoundFileNamed("explosionSound.caf", waitForCompletion: false))
        
        //Set isGameOver property to stop score from updating and silence laserBeam
        isGameOver = true
        
        //Call gameOver
        gameOver(triggeredByEnemy: false)
        
    }
    
    @objc func createEnemy() {
        
        //Randomize order of enemies array
        enemies.shuffle()
        
        //Get enemy from inside array position 0, add to scene
        enemy = SKSpriteNode(imageNamed: enemies[0])
        enemy.position = CGPoint(x: 1200, y: Int.random(in: 100...580))
        enemy.name = "enemy"
        enemy.zPosition = 1
        addChild(enemy)
        
        //Configure enemy physics and contactTestBitMask
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.contactTestBitMask = 2
            //This value matches the laserBeam categoryBitMask
        enemy.physicsBody?.categoryBitMask = 1
            //This value matches the spaceShip contactBitMask
        enemy.physicsBody?.isDynamic = true
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
    
    //Detect collisions between nodes
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        var nodeAName = nodeA.name
        var nodeBName = nodeB.name
        
        //Determine nodeA type
        switch nodeAName {
            
        case "laserBeam":
            nodeAName = "player"
            
        case "spaceShip":
            nodeAName = "player"
            
        case "enemy":
            nodeAName = "enemy"
            
        default:
            break
            
        }
        
        //Determine nodeB type
        switch nodeBName {
            
        case "laserBeam":
            nodeBName = "player"
            
        case "spaceShip":
            nodeBName = "player"
            
        case "enemy":
            nodeBName = "enemy"
            
        default:
            break
            
        }
        
        //Exit if both nodeAName and nodeBName is player
        if nodeAName == "player" && nodeBName == "player" { return }
        
        //Exit if both nodeAName and nodeBName is enemy
        if nodeAName == "enemy" && nodeBName == "enemy" { return }
        
        //If either nodeNameA or nodeNameB is an enemy node
        if nodeAName == "enemy" || nodeBName == "enemy"{
            
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            
            //If enemy hit laserBeam
            if nodeA.name == "laserBeam" || nodeB.name == "laserBeam" {
                
                //Determine which contact.body is the enemy
                if nodeA.name == "enemy" {
                    nodeA.removeFromParent()
                    explosion.position = nodeA.position
                        //remove enemy from scene
                
                } else if nodeB.name == "enemy" {
                    nodeB.removeFromParent()
                    explosion.position = nodeB.position
                        //expode enemy
                }
                
                //Add bonus points to player score
                score += 1000
                
            } else if nodeA.name == "spaceShip" || nodeB.name == "spaceShip" {
                
                explosion.position = spaceShip.position
                spaceShip.removeFromParent()
                
                //Stop score from updating and silcene laserBeam
                isGameOver = true
                
                gameOver(triggeredByEnemy: true)
                
            }
            
        //Add emitter explosion to scene and run explosion sound
        addChild(explosion)
        run(SKAction.playSoundFileNamed("explosionSound.caf", waitForCompletion: false))
            
        } //End outer if block

    } //End didBegin() method
    
    //Handle gameOver actions
    func gameOver(triggeredByEnemy: Bool) {
        
        //Ensure game has ended
        if !isGameOver {
            return
        }
        
        //Stop all physicsWorld actions and player interactions
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        //Display Game Over image
        let gameOverSprite = SKSpriteNode(imageNamed: "gameOver")
        gameOverSprite.position = CGPoint(x: 512, y: 576)
        gameOverSprite.zPosition = 1
        addChild(gameOverSprite)
        
        //Confugure Game Over alert
        var title: String
        let message = "Your score: \(score)"
        var alertController: UIAlertController
        
        //Game over triggered by enemy
        if triggeredByEnemy == true {
            
            title = "Space Junk destroyed your Ship!"
            
        //Triggered by player stop touching screen
        } else {
            
            title = "You destroyed your ship"
            //Explode spaceShip node
        }
        
        //Create alert
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //Display alert
        self.view?.window?.rootViewController?.present(alertController, animated: true)
    }
}
