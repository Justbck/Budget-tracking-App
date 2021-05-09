//
//  ExpenseTVC.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 09/05/2021.
//

import UIKit

class ExpenseTVC: UITableViewCell {

    @IBOutlet weak var expName: UILabel!
    @IBOutlet weak var expAmount: UILabel!
    @IBOutlet weak var expOccurance: UILabel!
    @IBOutlet weak var expDue: UILabel!
    @IBOutlet weak var expRemainder: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
