//
//  GroupCell.swift
//  lessons
//
//  Created by Fabius Bile on 19.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    var delegate: FavChanged!
    @IBAction func favPressed(_ sender: Any) {
        self.favBtn.isSelected = !self.favBtn.isSelected
        delegate.favChanged(self, isFav: self.favBtn.isSelected)
    }
    @IBOutlet weak var favBtn: UIButton!
    
    @IBOutlet weak var groupName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        favBtn.isSelected = false
        groupName.text = ""
    }
    

}
