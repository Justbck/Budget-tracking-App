//
//  EditExpence.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 05/05/2021.
//

import Foundation
import Foundation
import UIKit

class EditExpence: UITableViewController {
    
    let textFieldCellID = "textFieldCellID"
    let placeholders = ["Amount", "due"]
    
    var selectedRow: Int?
    
    var name : String = ""
    var budget: String = ""

    
    var isEditingExpence: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
    }
    
    private func setupNavBar(){
        self.title = "Edit Category"
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.navigationBar.barTintColor = .white
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        tableView.sectionHeaderHeight = 10
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 55
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: textFieldCellID)
        
        
    }
    
    @objc
    func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EditExpence {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellID) as! TextFieldCell
        let row = indexPath.row
        cell.placeholder = placeholders [indexPath.row]
        
        
        if isEditing {
            if row == 0 {
                cell.title = name
            } else {
                cell.title = budget
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
