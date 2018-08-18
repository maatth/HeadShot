//
//  GameScene.swift
//  HeadShot
//
//  Created by Maat on 30/08/2017.
//  Copyright © 2017 Maat. All rights reserved.
//

import SpriteKit
import GameplayKit
import QuartzCore

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGVector {
    return CGVector(dx: left.x - right.x, dy: left.y - right.y)
}

func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector {
        return self / length()
    }
}



struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All : UInt32 =  UInt32.max
    static let Tomato : UInt32 = 1
    static let Face : UInt32 = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var canon = SKSpriteNode()
    var spriteFaces = [SKSpriteNode]()
    var gameFaces = gameModel.faces
    var tomatos = [SKSpriteNode]()
    var canonAngle = CGFloat(Double.pi)
    
    override func sceneDidLoad() {
    
        self.backgroundColor = UIColor(red: 0.815686, green: 0.941176, blue: 1.0, alpha: 1.0)
        
        physicsWorld.contactDelegate = self
        
        canon = self.childNode(withName: "canon") as! SKSpriteNode
        
        //Add border
       
        let lowerOrigin = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y - 100)
        let rect = CGRect(origin: lowerOrigin, size: CGSize(width: self.frame.width, height: self.frame.height + 200.0))
        let border = SKPhysicsBody.init(edgeLoopFrom: rect)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        //Add face
        for (index, face) in gameFaces.enumerated() {
            print("created : ", face.name)
            let texture = SKTexture(image: face.photo1!)
            let facesize = CGSize(width: 180, height: 240)
            let faceSprite = SKSpriteNode(texture: texture, size: facesize)
            faceSprite.name = "Face_" + String(index)
            
            faceSprite.physicsBody = SKPhysicsBody(circleOfRadius: faceSprite.size.width/2)
            faceSprite.physicsBody?.isDynamic = false
            faceSprite.physicsBody?.categoryBitMask = PhysicsCategory.Face
            faceSprite.physicsBody?.contactTestBitMask = PhysicsCategory.Tomato
            faceSprite.physicsBody?.collisionBitMask = PhysicsCategory.None
            
            self.addChild(faceSprite)
            spriteFaces.append(faceSprite)
            
            squeezeForever(sprite: faceSprite)
            moveRandomlyForever(sprite: faceSprite, face: face)
            changeFaceForever(sprite: faceSprite, face: face)
        }
    }
    
    func squeezeForever(sprite: SKSpriteNode) {
        let scaleX = SKAction.sequence([
            SKAction.scaleX(to: 0.95, duration: 0.15),
            SKAction.scaleX(to: 1.05, duration: 0.15)
            ])
        
        let scaleY = SKAction.sequence([
            SKAction.scaleY(to: 1.05, duration: 0.15),
            SKAction.scaleY(to: 0.95, duration: 0.15)
            ])
        
        let group = SKAction.repeatForever(SKAction.group([scaleX, scaleY]))
        
        sprite.run(group)
    }
    
    func moveRandomlyForever(sprite: SKSpriteNode, face: Face) {
        let randomDestination:CGPoint = CGPoint(x: randomX(), y: randomY(isEnemy: face.isEnemy))
        let move = SKAction.move(to: randomDestination, duration: 2)
        let sequence = SKAction.sequence([move, SKAction.run({[unowned self] in self.moveRandomlyForever(sprite: sprite, face: face)})])
        sprite.run(sequence)
    }

    
    func changeFaceForever(sprite: SKSpriteNode, face: Face) {
        let texture1 = SKTexture(image: face.photo1!)
        let texture2 = SKTexture(image: face.photo2!)
        let texture3 = SKTexture(image: face.photo3!)
        let changeSequence = SKAction.sequence([
            SKAction.setTexture(texture1),
            SKAction.wait(forDuration: 1),
            SKAction.setTexture(texture2),
            SKAction.wait(forDuration: 1),
            SKAction.setTexture(texture3),
            SKAction.wait(forDuration: 1)
            ])
        let group = SKAction.repeatForever(SKAction.group([changeSequence]))
        sprite.run(group)
    }
    
    func randomX() -> CGFloat {
        let frameWidth = Int(self.frame.size.width/2)
        let rand = GKRandomDistribution(lowestValue: -frameWidth, highestValue: frameWidth)
        return CGFloat(rand.nextInt())
    }
    
    func randomY(isEnemy: Bool) -> CGFloat {
        let highestValue = isEnemy ? Int(self.frame.size.height/2) : Int(self.frame.size.height/8)
        let lowestValue = isEnemy ? Int(self.frame.size.height/8) : 0
        let rand = GKRandomDistribution(lowestValue: lowestValue, highestValue: highestValue)
        return CGFloat(rand.nextInt())
    }
    
    func rotateCanon(to goal:CGPoint) {
        canonAngle = atan2(goal.y - (-self.frame.size.height/2), goal.x)
        canon.run(SKAction.rotate(toAngle: canonAngle, duration: 0.01))
    }
    
    
    func fire(towards goal : CGPoint) {
        let tomato = SKSpriteNode(imageNamed: "tomato")
        tomato.size = CGSize(width: 80, height: 80)
        tomato.name = "tomato"

        let tomatoOrigin = CGPoint(x: 0.0, y: -self.frame.size.height/2)
        let tomatoDirection = (goal - tomatoOrigin).normalized()
        let canonLength = CGFloat(130)
        tomato.position.x = tomatoOrigin.x + tomatoDirection.dx * canonLength
        tomato.position.y = tomatoOrigin.y + tomatoDirection.dy * canonLength
        
        tomato.physicsBody = SKPhysicsBody(circleOfRadius: 20, center: CGPoint(x: 0.0, y: 0.0))
        tomato.physicsBody?.affectedByGravity = false
        tomato.physicsBody?.linearDamping = 0.0
 
        tomatos.append(tomato)
        self.addChild(tomato)

        let tomatoSpeed = CGFloat(80.0)
        tomato.physicsBody?.applyImpulse(tomatoDirection * tomatoSpeed)
        
    }
    
    func touchDown(atPoint pos:CGPoint) {
        rotateCanon(to: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        rotateCanon(to: pos)
    }
    
    func touchUp(atPoint pos:CGPoint) {
        self.physicsWorld.removeAllJoints()
        fire(towards: pos)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))}
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for tomato in tomatos {
            if tomato.position.y > self.frame.height/2 + tomato.size.height/2 {
                tomato.removeFromParent()
            }
        }
        
        for face in spriteFaces {
            if face.position.y < -self.frame.height/2 - face.size.height {
                face.removeFromParent()
                let index = Int(face.name!.replacingOccurrences(of: "Face_", with: ""))
                spriteFaces.remove(at: index!)
                gameFaces.remove(at: index!)
                isGameOver()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode

        //add shockwave
        let shockwave = SKShapeNode(circleOfRadius: 1)
        shockwave.position = contact.contactPoint
        self.addChild(shockwave)
        shockwave.run(shockWaveAction)


        if (firstBody.name?.range(of:"Face") != nil && secondBody.name == "tomato") {
            collision(between: firstBody, and: secondBody)
        } else if (firstBody.name == "tomato" && secondBody.name?.range(of:"Face") != nil) {
            collision(between: secondBody, and: firstBody)
        }
        
    }
    
    func collision(between spriteFace: SKSpriteNode, and tomato: SKSpriteNode) {
        print("collision")
        
        //get the 4e face
        let index = Int(spriteFace.name!.replacingOccurrences(of: "Face_", with: ""))
        let gameFace = gameFaces[index!]
        let texture = SKTexture(image: gameFace.photo4!)
        spriteFace.texture = texture
        
        //add smashed tomato on the face
        let smashedTomato = SKSpriteNode(imageNamed: "smashedTomato")
        smashedTomato.zPosition = 10
        smashedTomato.size = CGSize(width: 120, height: 120)
        spriteFace.addChild(smashedTomato)
        
        //add tomato particules
        let particles = SKEmitterNode(fileNamed: "BloodParticules")!
        particles.position = spriteFace.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
     
        //make the tomato slide slowly along the face
        smashedTomato.run(waitSlideFadeAction)
        tomato.removeFromParent()
        
        //remove one life
        gameFace.life = gameFace.life - 1
        print("life : ", gameFace.life)
        
        //fall down if hit two times by a tomato
        if gameFace.life == 0 {
            print("dead")
            spriteFace.removeAllActions()
            spriteFace.physicsBody?.contactTestBitMask = PhysicsCategory.None
            spriteFace.physicsBody?.isDynamic = true
            spriteFace.physicsBody?.affectedByGravity = true
        }
        
    }
    
    private func isGameOver() {
        let enemiesLeft = gameFaces.filter({$0.isEnemy})
        let friendsLeft = gameFaces.filter({!$0.isEnemy})
      
        if enemiesLeft.count == 0 {
            print("Victory !")
            gameModel.gameState = .Winner
            if let navcon = self.view!.window!.rootViewController as? UINavigationController {
                navcon.popViewController(animated: true)
                //self.view!.window!.rootViewController!.present(StartupViewController(), animated: true, completion: nil) //ca frezze
            }
        }
        if friendsLeft.count == 0 {
            print("Game Over")
            gameModel.gameState = .Loser
            if let navcon = self.view!.window!.rootViewController as? UINavigationController {
                navcon.popViewController(animated: true)
                //self.view!.window!.rootViewController!.present(StartupViewController(), animated: true, completion: nil) //ca frezze
            }
            
        }
        
    }
    
    // MARK: - Helpers
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
        let sequence = SKAction.sequence([growAndFadeAction, SKAction.removeFromParent()])
        return sequence
    }()
    
    let waitSlideFadeAction: SKAction = {
        let wait = SKAction.wait(forDuration: 2.0)
        let slideDownAction = SKAction.moveBy(x: 0, y: -80, duration: 5)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let sequence = SKAction.sequence([wait, slideDownAction, fadeOutAction, SKAction.removeFromParent()])
        return sequence
    }()
    
}

