//
//  CategoryViewController.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 03/05/2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    
    @IBOutlet weak var categoryColor: UISegmentedControl!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryName: UITextField!
    @IBOutlet weak var categoryBudget: UITextField!
    @IBOutlet weak var categoryNotes: UITextField!
    
    
    let screenSize: CGRect = UIScreen.main.bounds
 
    
    var colorPicker = UIColorPickerViewController()
    var selectedColor =  UIColor.white
    
    var isEditingCat: Bool!
    var selectedCatRow :Int!
    
    @IBAction func openPickerView(_ sender: UIButton) {
        colorPicker.supportsAlpha = true
        colorPicker.selectedColor = selectedColor
        present(colorPicker, animated: true)
        
    }
    
    
    @IBAction func showPopover(_ sender: UIBarButtonItem) {
        isEditingCat = false
        categoryLabel.text = "Add Category"
        categoryName.text = ""
        categoryBudget.text = ""
        categoryNotes.text = ""
        animateIn(desiredView: blurView)
        animateIn(desiredView: popoverView)
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        animateOut(desiredView: popoverView)
        animateOut(desiredView: blurView)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        let newCategory =  Category(context: self.context)
        newCategory.name = categoryName.text!
        newCategory.budget = categoryBudget.text!
        let budgetDbl = (categoryBudget.text! as NSString).doubleValue
        newCategory.budgetDbl = budgetDbl
        newCategory.notes = categoryNotes.text!
        
        let selectedCategoryColor = categoryColor.selectedSegmentIndex
        newCategory.colour = categoryColor.titleForSegment(at:selectedCategoryColor)
        

        if isEditingCat == false {
            self.categories.append(newCategory)
            self.saveCategories()
            animateOut(desiredView: popoverView)
            animateOut(desiredView: blurView)
            
        } else {
            
            //self.categories.insert(newCategory, at: selectedCatRow + 1)
            //self.context.delete(self.categories[selectedCatRow])
            //self.categories.remove(at: selectedCatRow)
            
            self.categories[selectedCatRow].name =   categoryName.text!
            self.categories[selectedCatRow].budget = categoryBudget.text!
            let budgetDbl = (categoryBudget.text! as NSString).doubleValue
            self.categories[selectedCatRow].budgetDbl = budgetDbl
            self.categories[selectedCatRow].notes = categoryNotes.text
            let selectedCategoryColor = categoryColor.selectedSegmentIndex
            self.categories[selectedCatRow].colour = categoryColor.titleForSegment(at:selectedCategoryColor)
            
            
            self.saveCategories()
            animateOut(desiredView: popoverView)
            animateOut(desiredView: blurView)
        }
        
        self.saveCategories()
        
        
    }
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var popoverView: UIView!
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        colorPicker.delegate = self
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryTVC
        cell.catNameLabel.text = self.categories[indexPath.row].name
        let budget = self.categories[indexPath.row].budget! + " £"
        //let budgetString = String(format: "%f", budget)
        
        
        if (self.categories[indexPath.row].budget?.isEmpty == true) {
            cell.catBudgetLabel.text = "0 £"
        } else{
            cell.catBudgetLabel.text = budget
        }
        
       
        cell.catNotesLabel.text = self.categories[indexPath.row].notes
        cell.categoryView.frame.size.width = screenSize.width * 0.95
        
        if self.categories[indexPath.row].colour == "Green" {
            cell.categoryView.backgroundColor = UIColor.init(hex: "c8e6c9")
        } else if self.categories[indexPath.row].colour == "Black"{
            cell.categoryView.backgroundColor = .lightGray
        } else if self.categories[indexPath.row].colour == "Blue"{
            cell.categoryView.backgroundColor = UIColor.init(hex: "b3e5fc")
        } else if self.categories[indexPath.row].colour == "Yellow" {
            cell.categoryView.backgroundColor = UIColor.init(hex: "ffffcf")
        } else if self.categories[indexPath.row].colour == "Red" {
            cell.categoryView.backgroundColor = UIColor.init(hex: "#ff867c")
        } else {
            cell.categoryView.backgroundColor = .white
        }
        
        
      
        
        return cell
        
    }
    

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            self.saveCategories()
        }
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            
            self.categoryLabel.text = "Edit Category"
            self.animateIn(desiredView: self.blurView)
            self.animateIn(desiredView: self.popoverView)
            
            self.categoryName.text = self.categories[indexPath.row].name
            let budget = self.categories[indexPath.row].budget
            self.categoryBudget.text = budget
            self.categoryNotes.text = self.categories[indexPath.row].notes
           
 
           
            self.isEditingCat = true
            self.selectedCatRow = indexPath.row
            
            
           
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
    
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector:  #selector(NSString.caseInsensitiveCompare(_:)) )]
     
        loadCategories(with: request)
        tableView.reloadData()
         
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
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector:  #selector(NSString.caseInsensitiveCompare(_:)))]
        
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


extension CategoryViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print("")
    }
    
}
























