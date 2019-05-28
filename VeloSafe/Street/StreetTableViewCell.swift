//
//  StreetTableViewCell.swift
//  VeloSafe
//
//  Created by Polina on 28/05/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import UIKit

class StreetTableViewCell: UITableViewCell {

    @IBOutlet weak var streetName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with text: String) {
        streetName.text = text
    }

}
