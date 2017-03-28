//
//  LessonCell.swift
//  lessons
//
//  Created by Fabius Bile on 09.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import UIKit

class LessonCell: UITableViewCell {


    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var lesson: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
