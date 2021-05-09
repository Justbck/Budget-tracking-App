//
//  ViewController.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 01/05/2021.
//

import UIKit
import CoreData
import SwiftUICharts


class ExpencesViewController: UITableViewController {
    
    
    @IBOutlet weak var expenceLabel: UILabel!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var selectedDate: UIDatePicker!
    @IBOutlet weak var notesText: UITextField!
    @IBOutlet weak var addToCalendar: UISwitch!
    @IBOutlet weak var occurance: UISegmentedControl!
    
    
    
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var popoverView: UIView!
  
   
    var isEditingExp: Bool!
    var selectedExpRow :Int!
    
    
    
    @IBAction func showAction(_ sender: UIBarButtonItem) {
        isEditingExp = false
        expenceLabel.text = "Add Expense"
        nameText.text = ""
        amountText.text = ""
        
        animateIn(desiredView: blurView)
        animateIn(desiredView: popoverView)
        
        
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        let selectedSegment = occurance.selectedSegmentIndex
        
        let newItem = Item(context: self.context)
        newItem.name = nameText.text!
        newItem.amount = amountText.text!
        newItem.notes = notesText.text!
        newItem.date = selectedDate.date
        newItem.occurance = occurance.titleForSegment(at:selectedSegment)
        
        
        
        if addToCalendar.isOn == true {
            newItem.added = true
        } else {
            newItem.added = false
        }
        

        newItem.due = false
        newItem.parentCategory = self.selectedCategory

        if isEditingExp == false {
            self.itemArray.append(newItem)
            self.saveItems()
            animateOut(desiredView: popoverView)
            animateOut(desiredView: blurView)
            
        } else {
            
            self.itemArray.insert(newItem, at: selectedExpRow + 1)
            self.context.delete(self.itemArray[selectedExpRow])
            self.itemArray.remove(at: selectedExpRow)
            self.saveItems()
            animateOut(desiredView: popoverView)
            animateOut(desiredView: blurView)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        animateOut(desiredView: popoverView)
        animateOut(desiredView: blurView)
    }
    
    
    
    
    
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
    
    
    //tableview datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenceItemCell") as! ExpenseTVC
        cell.expName.text = self.itemArray[indexPath.row].name
        
        
        let budget = self.itemArray[indexPath.row].amount! + "£"
        if (self.itemArray[indexPath.row].amount!.isEmpty) {
            cell.expAmount.text = "0 £"
        } else{
            cell.expAmount.text = budget
        }
        cell.expOccurance.text = self.itemArray[indexPath.row].occurance
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        cell.expDue.text = self.itemArray[indexPath.row].date?.asString()
        
        
        if self.itemArray[indexPath.row].added == true {
            cell.expRemainder.text = "remainder set"
        } else {
            cell.expRemainder.text = " "
        }
        

        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
        }
        
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in

            
            self.expenceLabel.text = "Edit Expense"
            self.animateIn(desiredView: self.blurView)
            self.animateIn(desiredView: self.popoverView)
            
            self.nameText.text = self.itemArray[indexPath.row].name
            self.amountText.text = self.itemArray[indexPath.row].amount
            self.notesText.text = self.itemArray[indexPath.row].notes
            
            //self.selectedDate.date = self.itemArray[indexPath.row].date
            
            if self.itemArray[indexPath.row].added == true {
                self.addToCalendar.isOn = true
            } else {
                self.addToCalendar.isOn = false
            }
            
            self.isEditingExp = true
            self.selectedExpRow = indexPath.row
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction,editAction])
    }
    
    
    //tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].due = !itemArray[indexPath.row].due
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    


    //sort expences
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
    
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector:  #selector(NSString.caseInsensitiveCompare(_:)))]
        
        loadItems(with: request)
        tableView.reloadData()
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
    
        let predicate = NSPredicate(format: "name CONTAINS %@",searchBar.text!.lowercased())
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector:  #selector(NSString.caseInsensitiveCompare(_:)))]
        
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



