//
//  PlayerNameTableViewCell.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 05/03/23.
//

import UIKit

class PlayerNameTableViewCell: UITableViewCell {

    @IBOutlet weak var playerNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
