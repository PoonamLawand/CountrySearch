//
//  SearchTableViewCell.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import UIKit
import SVGKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var flagView: AsyncImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    // @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagView.layer.backgroundColor = UIColor.clear.cgColor
        flagView.layer.cornerRadius = 10
        flagView.layer.borderWidth =   0.3
        flagView.layer.masksToBounds = true
        flagView.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    override func prepareForReuse() {
        flagView.cancelDownload()
        super.prepareForReuse()
        countryNameLabel.text = ""
        flagView.image = nil
        
    }
    
    
    //concurrent Async function to download flag images
    func downloadAndSetflagViewImageWithURL(_ withURL: URL){
        
        self.flagView.setImageURL(withURL)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

