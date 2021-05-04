//
//  NewCategory.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 04/05/2021.
//

import Foundation
import UIKit

class EditCategory: UITableViewController {
    let textFieldCellID = "textFieldCellID"
    let placeholders = ["Name", "Headline"]
    
    var selectedRow: Int?
    
    var isEditingCategory: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
    }
    
    private func setupNavBar(){
        self.title = "Edit Category"
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        
    }
    
    @objc
    func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
