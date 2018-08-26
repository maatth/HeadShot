//
//  Faces.swift
//  HeadShot
//
//  Created by Maat on 05/07/2018.
//  Copyright © 2018 Maat. All rights reserved.
//

import Foundation

struct GameModel: Codable {
    var faces = [Face]()
    var difficulty = Difficulty.Medium
    var gameState = GameState.Starting
    
    //MARK: Persistance
    //CodingKeys prevents difficulty and gameState to be saved
    enum CodingKeys: String, CodingKey {
        case faces
    }

}
