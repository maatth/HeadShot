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

func random(from lowestValue:Int, to highestValue:Int) -> CGFloat {
    let rand = GKRandomDistribution(lowestValue: lowestValue, highestValue: highestValue)
    return CGFloat(rand.nextInt())
}

struct PhysicsCategory {
    static let None : UInt32 = 0
    static let Tomato : UInt32 = 1
    static let Face : UInt32 = 2
    static let Border : UInt32 = 4
    static let All : UInt32 =  UInt32.max
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var canon = SKSpriteNode()
    //var spriteFaces = [SKSpriteNode]()
    var currentGameModel = gameModel
    
    //var currentGameModel.faces = currentGameModel.faces
    var tomatos = [SKSpriteNode]()
    var canonAngle = CGFloat(Double.pi)
    
    var frameWidth = 0
    var frameHeight = 0
    
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
        self.physicsBody!.categoryBitMask = PhysicsCategory.Border
        self.physicsBody!.contactTestBitMask = PhysicsCategory.None
        self.physicsBody!.collisionBitMask = PhysicsCategory.Tomato
        
        
        frameWidth = Int(self.frame.size.width/2)
        frameHeight = Int(self.frame.size.height/2)
        
        //Add clouds
        addClouds(numberOfClouds: 4)
        
        //Add face
        for (index, face) in currentGameModel.faces.enumerated() {
            print("created : ", face.name)
            let texture = SKTexture(image: face.photo1!)
            let facesize = CGSize(width: 180, height: 240)
            let faceSprite = SKSpriteNode(texture: texture, size: facesize)
            faceSprite.name = "Face_" + String(index)
            faceSprite.zPosition = 1
            
            faceSprite.physicsBody = SKPhysicsBody(circleOfRadius: faceSprite.size.width/2)
            faceSprite.physicsBody?.isDynamic = false
            faceSprite.physicsBody?.categoryBitMask = PhysicsCategory.Face //faceSprite belongs to Face category
            faceSprite.physicsBody?.contactTestBitMask = PhysicsCategory.Tomato //we are notified when touching Tomato
            faceSprite.physicsBody?.collisionBitMask = PhysicsCategory.None //won't bounce
            
            self.addChild(faceSprite)
            //spriteFaces.append(faceSprite)
            
            squeezeForever(sprite: faceSprite)
            moveRandomlyForever(sprite: faceSprite, face: face, difficulty: currentGameModel.difficulty)
            changeFaceForever(sprite: faceSprite, face: face)
        }
        

    }
    
    func addClouds(numberOfClouds:Int) {
        for index in 1...numberOfClouds {
            print("creating : cloud " + String(index))
            let cloud = SKSpriteNode(imageNamed: "Cloud")
            cloud.name = "cloud" + String(index)
            cloud.zPosition = 0
            self.addChild(cloud)
            moveRandomlyAndFadeForever(sprite: cloud)
        }
       
    }
    
    func moveRandomlyAndFadeForever(sprite: SKSpriteNode) {
        sprite.size = CGSize(width: random(from: 200, to: 800), height: random(from: 100, to: 300))
        
        let randomOrigin:CGPoint = CGPoint(x: random(from: -frameWidth, to: frameWidth), y: random(from: -frameHeight + 200, to: frameHeight))
        let goToStartPositionAction = SKAction.move(to: randomOrigin, duration: 0)
        
        let randomTime = TimeInterval(random(from: 3, to: 6))
        let slideAction = SKAction.moveBy(x: random(from: -200, to: 200), y: 0, duration: randomTime)
        let fadeInAction = SKAction.fadeIn(withDuration: randomTime)
        let slideAndFadeInAction = SKAction.group([slideAction, fadeInAction])
        
        let fadeOutAction = SKAction.fadeOut(withDuration: randomTime)
        let slideAndFadeOutAction = SKAction.group([slideAction, fadeOutAction])
    
        let sequence = SKAction.sequence([goToStartPositionAction,slideAndFadeInAction, slideAndFadeOutAction, SKAction.run({[unowned self] in self.moveRandomlyAndFadeForever(sprite: sprite)})])
        sprite.run(sequence)
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
    
    func moveRandomlyForever(sprite: SKSpriteNode, face: Face, difficulty: Difficulty) {
        var duration = 0.0
        switch difficulty {
            case .Easy: duration = 4.0
            case .Medium: duration = 2.0
            case .Hard: duration = 1.0
            case .Nightmare: duration = 0.5
        }
        
        let randomDestination:CGPoint
        if face.isEnemy {
            randomDestination = CGPoint(x: random(from: -frameWidth, to: frameWidth), y: random(from: Int(self.frame.size.height/8), to: Int(self.frame.size.height/2)))
        } else {
            randomDestination = CGPoint(x: random(from: -frameWidth, to: frameWidth), y: random(from: 0, to: Int(self.frame.size.height/8)))
        }
        
        let move = SKAction.move(to: randomDestination, duration: duration)
        let sequence = SKAction.sequence([move, SKAction.run({[unowned self] in self.moveRandomlyForever(sprite: sprite, face: face, difficulty: difficulty)})])
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
    
    
    func rotateCanon(to goal:CGPoint) {
        canonAngle = atan2(goal.y - (-self.frame.size.height/2), goal.x)
        canon.run(SKAction.rotate(toAngle: canonAngle, duration: 0.01))
    }
    
    
    func fire(towards goal : CGPoint) {
        run(SKAction.playSoundFileNamed("cannonShot", waitForCompletion: false))
        let tomato = SKSpriteNode(imageNamed: "tomato")
        tomato.size = CGSize(width: 80, height: 80)
        tomato.name = "tomato"
        tomato.zPosition = 2

        let tomatoOrigin = CGPoint(x: 0.0, y: -self.frame.size.height/2)
        let tomatoDirection = (goal - tomatoOrigin).normalized()
        let canonLength = CGFloat(130)
        tomato.position.x = tomatoOrigin.x + tomatoDirection.dx * canonLength
        tomato.position.y = tomatoOrigin.y + tomatoDirection.dy * canonLength
        
        tomato.physicsBody = SKPhysicsBody(circleOfRadius: 20, center: CGPoint(x: 0.0, y: 0.0))
        tomato.physicsBody?.affectedByGravity = false
        tomato.physicsBody?.linearDamping = 0.0
        tomato.physicsBody?.categoryBitMask = PhysicsCategory.Tomato //tomato belongs to Tomato category
        tomato.physicsBody?.contactTestBitMask = PhysicsCategory.Face //we are notified when touching Tomato
        tomato.physicsBody?.collisionBitMask = PhysicsCategory.Border //won't bounce ???????
 
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
        
//        for face in spriteFaces {
//            if face.position.y < -self.frame.height/2 - face.size.height {
//                face.removeFromParent()
//                let index = Int(face.name!.replacingOccurrences(of: "Face_", with: ""))
//                //print(index!)
//                spriteFaces.remove(at: index!)
//                currentGameModel.faces.remove(at: index!)
//                isGameOver()
//            }
//        }
    }
    
    //Is called when a collision is notified by a contactTestBitMask
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode

        if (firstBody.name?.range(of:"Face") != nil && secondBody.name == "tomato") {
            collision(between: firstBody, and: secondBody, like:contact.contactNormal)
        } else if (firstBody.name == "tomato" && secondBody.name?.range(of:"Face") != nil) {
            collision(between: secondBody, and: firstBody, like:contact.contactNormal)
        }
        
    }
    
    func collision(between spriteFace: SKSpriteNode, and tomato: SKSpriteNode, like contactNormal: CGVector) {
        //get the 4e face
        let index = Int(spriteFace.name!.replacingOccurrences(of: "Face_", with: ""))
        let texture = SKTexture(image: gameModel.faces[index!].photo4!)
        spriteFace.texture = texture
        
        //add smashed tomato on the face
        let smashedTomato = SKSpriteNode(imageNamed: "smashedTomato")
        smashedTomato.zPosition = 10
        smashedTomato.size = CGSize(width: 120, height: 120)
        smashedTomato.position.x = contactNormal.dx * spriteFace.size.width/3.7
        smashedTomato.position.y = contactNormal.dy * spriteFace.size.width/3.7
        spriteFace.addChild(smashedTomato)
        
        //add tomato particules
        let particles = SKEmitterNode(fileNamed: "BloodParticules")!
        particles.position = spriteFace.position
        particles.zPosition = 3
        particles.emissionAngle = atan2(-contactNormal.dy,-contactNormal.dx)//inverser les particules 
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
     
        run(SKAction.playSoundFileNamed("splash", waitForCompletion: false))
        tomato.removeFromParent()
        
        //remove one life
        currentGameModel.faces[index!].life = currentGameModel.faces[index!].life - 1
        print("remaining life of face ", index!, " : ", currentGameModel.faces[index!].life)
        
        //fall down if hit two times by a tomato
        if currentGameModel.faces[index!].life == 0 {
            spriteFace.removeAllActions()
            spriteFace.physicsBody?.collisionBitMask = PhysicsCategory.None //will not bounce anymore
            
            spriteFace.physicsBody?.isDynamic = true //autorize applyForce works on it
           
            let fallDownAndDisappear: SKAction = {
                let fallDown = SKAction.applyForce(CGVector(dx: 0, dy: -10), duration: 2)
                let isGameOverAction = SKAction.run {isGameOver()}
                let sequence = SKAction.sequence([fallDown, SKAction.removeFromParent(), isGameOverAction])
                return sequence
            }()
            
            spriteFace.run(fallDownAndDisappear)
        }
        
        func isGameOver() {
            let enemiesAliveLeft = currentGameModel.faces.filter({$0.isEnemy && $0.life > 0})
            let friendsAliveLeft = currentGameModel.faces.filter({!$0.isEnemy && $0.life > 0})
            
            if enemiesAliveLeft.count == 0 {
                print("Victory")
                gameModel.gameState = .Winner
            }
            if friendsAliveLeft.count == 0 {
                print("Game Over")
                gameModel.gameState = .Loser
            }
            let navcon = self.view!.window!.rootViewController! as! UINavigationController
            navcon.popViewController(animated: true)
            
        }
    }
 
}

