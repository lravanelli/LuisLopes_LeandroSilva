//
//  StatesTableViewCell.swift
//  ComprasUSA
//
//  Created by Luis Fernando Ravanelli Lopes on 21/04/2018.
//  Copyright © 2018 Luis Fernando Ravanelli Lopes. All rights reserved.
//

import UIKit

class StatesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var lbState: UILabel!
    @IBOutlet weak var lbTax: UILabel!
    
    //MARK: - Super Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
