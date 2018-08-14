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
    
    //    private var label : SKLabelNode?
    //    private var spinnyNode : SKShapeNode?
    var player1Score = SKLabelNode()
    var player2Score = SKLabelNode()
    var canon = SKSpriteNode()
    var face = SKSpriteNode()
    var tomatos = [SKSpriteNode()]
    var angle = CGFloat(Double.pi)
    var score = [0,0]
    
    override func sceneDidLoad() {
    
        self.backgroundColor = UIColor(red: 0.815686, green: 0.941176, blue: 1.0, alpha: 1.0)
        
        physicsWorld.contactDelegate = self
        
        player1Score = self.childNode(withName: "Player1Score") as! SKLabelNode
        player2Score = self.childNode(withName: "Player2Score") as! SKLabelNode
        canon = self.childNode(withName: "canon") as! SKSpriteNode
        //face = self.childNode(withName: "face") as! SKSpriteNode
        
        //Add border
        let rect = CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.width, height: self.frame.height + 40.0))
        let border = SKPhysicsBody.init(edgeLoopFrom: rect)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        //Add face
        for (index, face) in gameModel.faces.enumerated() {
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
            
            squeezeForever(sprite: faceSprite)
            
            moveRandomlyForever(sprite: faceSprite)
            
            changeFaceForever(sprite: faceSprite, face: face)
        }
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
    
    func moveRandomlyForever(sprite: SKSpriteNode) {
        let randomDestination:CGPoint = CGPoint(x: randomX(), y: randomY())
        let move = SKAction.move(to: randomDestination, duration: 2)
        let sequence = SKAction.sequence([move, SKAction.run({[unowned self] in self.moveRandomlyForever(sprite: sprite)})])
        sprite.run(sequence)
    }

    
    func randomX() -> CGFloat {
        let frameWidth = Int(self.frame.size.width/2)
        let rand = GKRandomDistribution(lowestValue: -frameWidth, highestValue: frameWidth)
        return CGFloat(rand.nextInt())
    }
    
    func randomY() -> CGFloat {
        let rand = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.height/2))
        return CGFloat(rand.nextInt())
    }
    
    func rotateCanon(to goal:CGPoint) {
        angle = atan2(goal.y - (-self.frame.size.height/2), goal.x)
        canon.run(SKAction.rotate(toAngle: angle, duration: 0.01))
    }
    
    
    func fire(towards goal : CGPoint) {
        let tomato = SKSpriteNode(imageNamed: "tomato")
        tomato.size = CGSize(width: 80, height: 80)
        tomato.name = "tomato"

        let tomatoOrigin = CGPoint(x: 0.0, y: -self.frame.size.height/2)
        let tomatoDirection = (goal - tomatoOrigin).normalized()
        let canonLength = CGFloat(100)
        tomato.position.x = tomatoOrigin.x + tomatoDirection.dx * canonLength
        tomato.position.y = tomatoOrigin.y + tomatoDirection.dy * canonLength
        
        tomato.physicsBody = SKPhysicsBody(circleOfRadius: 10, center: CGPoint(x: 0.0, y: 0.0))
        tomato.physicsBody?.affectedByGravity = false
        tomato.physicsBody?.linearDamping = 0.0
 
        tomatos.append(tomato)
        self.addChild(tomato)

        let tomatoSpeed = CGFloat(20.0)
        tomato.physicsBody?.applyImpulse(tomatoDirection * tomatoSpeed)
        
    }
    
    func touchDown(atPoint pos:CGPoint) {
        rotateCanon(to: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        rotateCanon(to: pos)
    }
    
    func touchUp(atPoint pos:CGPoint) {
        //        self.physicsWorld.remove(tomatoCanonJoint)
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
    
    func collision(between face: SKSpriteNode, and tomato: SKSpriteNode) {
        print("collision")
        
        let index = Int(face.name!.replacingOccurrences(of: "Face_", with: ""))
        let faceModel = gameModel.faces[index!]
        let texture = SKTexture(image: faceModel.photo4!)
        face.texture = texture
        
        let smashedTomato = SKSpriteNode(imageNamed: "smashedTomato")
        smashedTomato.zPosition = 10
        smashedTomato.size = CGSize(width: 120, height: 120)
        face.addChild(smashedTomato)
     
        smashedTomato.run(waitSlideFadeAction)
        tomato.removeFromParent()
        
        let particles = SKEmitterNode(fileNamed: "BloodParticules")!
        particles.position = face.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
    }
    
    // MARK: - Helpers
    func breakBlock(_ node: SKNode) {
        //run(bambooBreakSound)
        let particles = SKEmitterNode(fileNamed: "BloodParticules")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()
    
    let waitSlideFadeAction: SKAction = {
        let wait = SKAction.wait(forDuration: 2.0)
        let slideDownAction = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        
        let sequence = SKAction.sequence([wait, slideDownAction, fadeOutAction, SKAction.removeFromParent()])
        
        return sequence
    }()
    
    
    
}

