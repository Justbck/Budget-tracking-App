//
//  ViewController.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 01/05/2021.
//

import UIKit
import CoreData

class ExpencesViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
   
    //tableview datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenceItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        
        cell.textLabel?.text = item.amount
        
        //ternary operator
        cell.accessoryType = item.due ? .checkmark : .none
        
        return cell
    }
    
    
    //tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].due = !itemArray[indexPath.row].due
        saveItems()

 
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveItems()
        }
        
        else if editingStyle == .insert {
            print("x")
            
        }
    }
    

    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var amountTextField = UITextField()

        
        let alert = UIAlertController(title: "Add Expence", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen
            
          
            let newItem = Item(context: self.context)
            newItem.amount = amountTextField.text!
            newItem.due = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Amount: "
            amountTextField = alertTextField
        }
        
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //model manipulation methods
    
    func saveItems(){
         do {
            try context.save()
         } catch {
             print("Error,\(error)")
         }
         self.tableView.reloadData()
    }
    
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
       
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error\(error)")
        }
        
        tableView.reloadData()
    }
}


//search bar methods
extension ExpencesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
    
        let predicate = NSPredicate(format: "amount CONTAINS %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "amount", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
