//
//  FaceTableViewCell.swift
//  HeadShot
//
//  Created by Maat on 22/06/2018.
//  Copyright © 2018 Maat. All rights reserved.
//

import UIKit

class FaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var faceImage1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isEnemyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
