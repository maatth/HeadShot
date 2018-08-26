//
//  StartupViewController.swift
//  HeadShot
//
//  Created by Maat on 17/06/2018.
//  Copyright © 2018 Maat. All rights reserved.
//

import UIKit

var gameModel = GameModel()

class StartupViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
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
        switch gameModel.gameState {
        case .Starting:
            messageLabel.text = ""
        case .Winner:
            messageLabel.text = "You win :)"
        case .Loser:
            messageLabel.text = "You lose :("
        }
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
