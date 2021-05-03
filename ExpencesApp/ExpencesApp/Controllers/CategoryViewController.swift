//
//  CategoryViewController.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 03/05/2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
     
    }

    //tableView datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
      
        return cell
    }
    
    
    //tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToExpences", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ExpencesViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }

    
    //data manipulation methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category,\(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //add new categories
  
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var nameTextField = UITextField()
        var budgetTextField = UITextField()
        var notesTextField = UITextField()
    
        
        
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory =  Category(context: self.context)
            newCategory.name = nameTextField.text!
            newCategory.budget = budgetTextField.text!
            newCategory.notes = notesTextField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let color = UIAlertController()
        
        
        alert.addAction(action)
        alert.addAction(cancel)
        alert.addChild(color)
        
        alert.addTextField { (field) in
            nameTextField = field
            nameTextField.placeholder = "Category name: "
        }
        
        alert.addTextField { (budgetField) in
            budgetTextField = budgetField
            budgetTextField.placeholder = "Budget £:"
        }
        
        alert.addTextField { (notesField) in
            notesTextField = notesField
            notesTextField.placeholder = "Notes: "
        }
        
        
        
        
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
        categories = try context.fetch(request)
        } catch {
            print("Error loading categories, \(error)")
        }
        
        tableView.reloadData()
    }
  

 
    
    

}
