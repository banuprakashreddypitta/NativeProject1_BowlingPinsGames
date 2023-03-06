//
//  GameDetailsTableViewCell.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 25/02/23.
//

import UIKit

class GameDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var playerNameLbl: UILabel!
    @IBOutlet weak var gamedTypeLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var gameStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
