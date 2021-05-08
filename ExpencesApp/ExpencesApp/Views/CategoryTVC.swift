//
//  CategoryTVC.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 08/05/2021.
//

import UIKit

class CategoryTVC: UITableViewCell {

  
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var catNameLabel: UILabel!
    
    @IBOutlet weak var catBudgetLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }
    



}
