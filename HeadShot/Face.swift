import UIKit

struct Face {
    
    // MARK: Properties
    var name: String
    var photo1: UIImage?
    var photo2: UIImage?
    var photo3: UIImage?
    var photo4: UIImage?
    var isEnemy: Bool
    var life: Int
    
    // MARK: Archiving Paths
    
    /*static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")*/
 
    
    // MARK: Types
    
    /*struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
    }*/
    
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
    
    // MARK: NSCoding
    /*
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)
    }
     */
}

