//
//  CountryTableViewCell.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/11/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {
    @IBOutlet weak var countryTagLabel: UILabel!
    @IBOutlet weak var countryTagDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countryTagLabel.text = ""
        countryTagDetailLabel.text = ""
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
