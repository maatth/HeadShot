import UIKit

struct Face: Codable {
    
    // MARK: Properties
    var name: String
    var photo1: UIImage?
    var photo2: UIImage?
    var photo3: UIImage?
    var photo4: UIImage?
    var isEnemy: Bool
    var life: Int
    
   
    // MARK: Initialization
    
    init?(name: String, photo1: UIImage?, photo2: UIImage?, photo3: UIImage?, photo4: UIImage?, isEnemy: Bool, life: Int) {
        print("init of \(name)")
        self.name = name
        self.photo1 = photo1
        self.photo2 = photo2
        self.photo3 = photo3
        self.photo4 = photo4
        self.isEnemy = isEnemy
        self.life = life

        //super.init()

        // Initialization should fail if there is no name or if the rating is negative
        if name.isEmpty {
            return nil
        }
    }
    
    //MARK: Persistance
    
    enum CodingKeys: String, CodingKey {
        case name
        case photo1
        case photo2
        case photo3
        case photo4
        case isEnemy
        case life
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
        if let photo1Data: Data = UIImagePNGRepresentation(photo1!) {
            let photo1DataStrBase64 = photo1Data.base64EncodedString(options: .lineLength64Characters)
            try container.encode(photo1DataStrBase64, forKey: .photo1)
        }
        if let photo2Data: Data = UIImagePNGRepresentation(photo2!) {
            let photo2DataStrBase64 = photo2Data.base64EncodedString(options: .lineLength64Characters)
            try container.encode(photo2DataStrBase64, forKey: .photo2)
        }
        if let photo3Data: Data = UIImagePNGRepresentation(photo3!) {
            let photo3DataStrBase64 = photo3Data.base64EncodedString(options: .lineLength64Characters)
            try container.encode(photo3DataStrBase64, forKey: .photo3)
        }
        if let photo4Data: Data = UIImagePNGRepresentation(photo4!) {
            let photo4DataStrBase64 = photo4Data.base64EncodedString(options: .lineLength64Characters)
            try container.encode(photo4DataStrBase64, forKey: .photo4)
        }
        
        try container.encode(isEnemy, forKey: .isEnemy)
        try container.encode(life, forKey: .life)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        print("name from init : \(name)")
        
        let photo1StrBase64: String = try values.decode(String.self, forKey: .photo1)
        let photo1dataDecoded: Data = Data(base64Encoded: photo1StrBase64, options: .ignoreUnknownCharacters)!
        photo1 = UIImage(data: photo1dataDecoded)
        
        let photo2StrBase64: String = try values.decode(String.self, forKey: .photo2)
        let photo2dataDecoded: Data = Data(base64Encoded: photo2StrBase64, options: .ignoreUnknownCharacters)!
        photo2 = UIImage(data: photo2dataDecoded)
        
        let photo3StrBase64: String = try values.decode(String.self, forKey: .photo3)
        let photo3dataDecoded: Data = Data(base64Encoded: photo3StrBase64, options: .ignoreUnknownCharacters)!
        photo3 = UIImage(data: photo3dataDecoded)
        
        let photo4StrBase64: String = try values.decode(String.self, forKey: .photo4)
        let photo4dataDecoded: Data = Data(base64Encoded: photo4StrBase64, options: .ignoreUnknownCharacters)!
        photo4 = UIImage(data: photo4dataDecoded)
        
        isEnemy = try values.decode(Bool.self, forKey: .isEnemy)
        life = try values.decode(Int.self, forKey: .life)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("faces")
    
}

