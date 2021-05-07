//
//  CategoryViewController.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 03/05/2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    
    
    @IBAction func showPopover(_ sender: UIBarButtonItem) {
        animateIn(desiredView: blurView)
        animateIn(desiredView: popoverView)
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        animateOut(desiredView: popoverView)
        animateOut(desiredView: blurView)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
    }
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var popoverView: UIView!
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        blurView.bounds = self.view.bounds
        popoverView.bounds = CGRect(x:0,y:0,width: self.view.bounds.width * 0.4, height: self.view.bounds.height * 0.4 )
    }
    
    func animateIn(desiredView: UIView) {
        let backgroundView = self.view!
        backgroundView.addSubview(desiredView)
        
        desiredView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center
        
        
        UIView.animate(withDuration: 0.3) {
            desiredView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            desiredView.alpha = 1
        }
    }

    func animateOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.3) {
            desiredView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            desiredView.alpha = 0
        }
        desiredView.removeFromSuperview()
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
    

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            self.saveCategories()
        }
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            
            /*let vc = EditCategory()
            
            vc.selectedRow = indexPath.row
            vc.isEditingCategory = true
            
            let nav = UINavigationController(rootViewController: EditCategory())
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .coverVertical
            
            self.present(nav, animated: true, completion: nil)
            */
            
            var nameTextField = UITextField()
            var budgetTextField = UITextField()
            var notesTextField = UITextField()
            
            
        
            
            let alert = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Add", style: .default) { (action) in
                let newCategory =  Category(context: self.context)
                newCategory.name = nameTextField.text!
                newCategory.budget = budgetTextField.text!
                newCategory.notes = notesTextField.text!
                
                
                self.categories.insert(newCategory, at: indexPath.row+1)
                self.context.delete(self.categories[indexPath.row])
                self.categories.remove(at: indexPath.row)
                self.saveCategories()
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
          
            
            
            alert.addAction(action)
            alert.addAction(cancel)
         
            
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

            self.present(alert, animated: true, completion: nil)
        }
 
        return UISwipeActionsConfiguration(actions: [deleteAction,editAction])
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
    
    
    //sort
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
    
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadCategories(with: request)
        tableView.reloadData()
         
    }
    
    
    //
    

    
    
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
        
      
        
        
        alert.addAction(action)
        alert.addAction(cancel)
     
        
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
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate : NSPredicate? = nil) {
        
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate])
        } else {
            request.predicate = nil
        }

        
        do {
        categories = try context.fetch(request)
        } catch {
            print("Error loading categories, \(error)")
        }
        
        tableView.reloadData()
    }
}


extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
    
        let predicate = NSPredicate(format: "name CONTAINS %@", searchBar.text!.lowercased())
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadCategories(with: request, predicate: predicate)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


