//
//  StartupViewController.swift
//  HeadShot
//
//  Created by Maat on 17/06/2018.
//  Copyright © 2018 Maat. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

var gameModel = GameModel()
var musicPlayer: AVAudioPlayer?

func playSound(withFileNamed filename: String, isLoop: Bool, withVolume volume: Float) {
    let path = Bundle.main.path(forResource: filename, ofType:nil)!
    let url = URL(fileURLWithPath: path)
    do {
        musicPlayer = try AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = isLoop ? -1 : 0
        musicPlayer?.play()
        musicPlayer?.volume = volume
    } catch let error {
        print(error.localizedDescription)
    }
}


class StartupViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var nightmareButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addClouds(numberOfClouds: 4)

        self.view.bringSubview(toFront: easyButton)
        self.view.bringSubview(toFront: mediumButton)
        self.view.bringSubview(toFront: hardButton)
        self.view.bringSubview(toFront: nightmareButton)
        self.view.bringSubview(toFront: settingsButton)
        
        // Load any saved faces, otherwise load sample data.
        if let loadedGameModel = loadFaces() {
            gameModel = loadedGameModel
        }
        else {
            loadSampleFaces()
        }
        
    }
    
    
    func loadFaces() -> GameModel? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: Face.ArchiveURL.path) as? Data else { return nil }
        do {
            let faces = try PropertyListDecoder().decode(GameModel.self, from: data)
            print("loadFaces sucess")
            return faces
        } catch {
            print(error)
            print("loadFaces failed")
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        switch gameModel.gameState {
        case .Starting:
            messageLabel.text = ""
            playSound(withFileNamed: "startupMusic.mp3", isLoop: true, withVolume: 1.0)
        case .Winner:
            messageLabel.text = "You win :)"
            messageLabel.textColor = UIColor.red
            playSound(withFileNamed: "game-won.mp3", isLoop: false, withVolume: 1.0)
        case .Loser:
            messageLabel.text = "You lose :("
            messageLabel.textColor = UIColor.black
            playSound(withFileNamed: "game-over.mp3", isLoop: false, withVolume: 1.0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        musicPlayer?.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSampleFaces() {
        let cochon = UIImage(named: "cochon")!
        let cochon2 = UIImage(named: "cochon2")!
        let cochon3 = UIImage(named: "cochon3")!
        let cochon4 = UIImage(named: "cochon4")!
        let face1 = Face(name: "Cochon", photo1: cochon, photo2: cochon2, photo3: cochon3, photo4: cochon4, isEnemy: true, life: 2)!
        let Longface = UIImage(named: "Longfaceold")!
        let face2 = Face(name: "Long", photo1: Longface, photo2: Longface, photo3: Longface, photo4: Longface, isEnemy: false, life: 2)!
        
        gameModel.faces += [face1, face2]
    }
    
    func addClouds(numberOfClouds:Int) {
        let imageView = SKView()
        imageView.frame = view.frame
        let scene = SKScene(size: imageView.frame.size)
        scene.backgroundColor = UIColor(red: 0.815686, green: 0.941176, blue: 1.0, alpha: 1.0)
        
        
        for index in 1...numberOfClouds {
            print("creating : cloud " + String(index))
            let cloud = SKSpriteNode(imageNamed: "Cloud")
            cloud.name = "cloud" + String(index)
            cloud.zPosition = 0
            scene.addChild(cloud)
            moveRandomlyAndFadeForever(sprite: cloud)
        }
        
        imageView.presentScene(scene)
        imageView.layer.zPosition = -1
        view.addSubview(imageView)
        
    }
    
    func moveRandomlyAndFadeForever(sprite: SKSpriteNode) {
        sprite.size = CGSize(width: random(from: 200, to: 800), height: random(from: 100, to: 300))
        
        let randomOrigin:CGPoint = CGPoint(x: random(from: Int(-view.frame.width), to: Int(view.frame.width)), y: random(from: Int(-view.frame.height) + 200, to: Int(view.frame.height)))
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

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                case "easy": gameModel.difficulty = .Easy
                case "medium": gameModel.difficulty = .Medium
                case "hard": gameModel.difficulty = .Hard
                case "nightmare": gameModel.difficulty = .Nightmare
                default: gameModel.difficulty = .Medium
            }
        }
        
    }

}
