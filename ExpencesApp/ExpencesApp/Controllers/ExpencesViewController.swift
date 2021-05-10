//
//  ViewController.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 01/05/2021.
//

import UIKit
import CoreData
import Charts
import TinyConstraints
import EventKitUI
import EventKit

class ExpencesViewController: UITableViewController, EKEventViewDelegate, ChartViewDelegate  {
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        controller.dismiss(animated: true, completion: nil)
        if controller.isBeingDismissed == true {
            self.addToCalendar.isOn = false
        }
    }

    
    func eventViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    let store = EKEventStore()

    
    var pieChart = PieChartView()

    
    @IBOutlet weak var expenceLabel: UILabel!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var selectedDate: UIDatePicker!
    @IBOutlet weak var notesText: UITextField!
    @IBOutlet weak var addToCalendar: UISwitch!
    @IBOutlet weak var occurance: UISegmentedControl!
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var popoverView: UIView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var footerView: UIView!
    
    
    @IBOutlet weak var totalBudgetLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var headerTitile: UILabel!
    
   
    var isEditingExp: Bool!
    var selectedExpRow :Int!
    
    
    @objc func didTapSwitch(sender: UISwitch){
        
   
        store.requestAccess(to: .event) { [weak self ] success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    guard let store = self?.store else { return }
                    let newEvent = EKEvent(eventStore: store)
                    newEvent.title = self!.nameText.text
                    newEvent.startDate =  self!.selectedDate.date
                    newEvent.endDate =  self!.selectedDate.date
                    
                    
                    let calendarVC = EKEventViewController()
                    calendarVC.delegate = self
                    calendarVC.event = newEvent
                    let navVC = UINavigationController(rootViewController: calendarVC)
                    
                    self?.present(navVC, animated: true)
                }
                }
        }
    }
    
    @objc func didTapSwitchEdit(sender: UISwitch){
        
        store.requestAccess(to: .event) { [weak self ] success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    guard let store = self?.store else { return }
                    let newEvent = EKEvent(eventStore: store)
                    newEvent.title = self!.nameText.text
                    newEvent.startDate =  self!.selectedDate.date
                    newEvent.endDate =  self!.selectedDate.date
                    
                    
                   let editVC = EKEventEditViewController()
                    editVC.eventStore = store
                    editVC.event = newEvent
                    self?.present(editVC, animated: true, completion: nil)
                }
            }
        }
        
        
    }
 
    
    @IBAction func showAction(_ sender: UIBarButtonItem) {
        isEditingExp = false
        expenceLabel.text = "Add Expense"
        nameText.text = ""
        amountText.text = ""
        selectedDate.date = Date()
        addToCalendar.isOn = false
        addToCalendar.addTarget(self, action:  #selector (self.didTapSwitch), for: .valueChanged)
        animateIn(desiredView: blurView)
        animateIn(desiredView: popoverView)
    }
    
    
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        let selectedSegment = occurance.selectedSegmentIndex
        
        
        let newItem = Item(context: self.context)
        newItem.name = nameText.text!
        newItem.amount = amountText.text!
        let amountDbl = (amountText.text! as NSString).doubleValue
        newItem.amountDbl = amountDbl
        
        selectedCategory?.totalExpences = selectedCategory!.totalExpences + newItem.amountDbl
        
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
        
        headerView.bounds = CGRect(x:0,y:0,width: self.view.bounds.width, height: self.view.bounds.height * 0.3)
        
        headerTitile.text = selectedCategory?.name
      
        self.updateCategoryDetails()
        self.updateTableHeader()
        
    }
    
    func updateCategoryDetails(){
       
        footerView.frame = CGRect(x: 0, y: 200, width: self.view.bounds.width, height: self.view.bounds.height * 0.2)
        
        tableView.tableFooterView = footerView
        
        if self.selectedCategory?.budget?.isEmpty == true {
            let budgetTotal = "0 £"
            self.totalBudgetLabel.text = budgetTotal
        } else {
            let budgetTotal = self.selectedCategory!.budget! + " £"
            self.totalBudgetLabel.text = budgetTotal
        }
        
        let expNumber =  self.itemArray.count
        var spentTotal: Double = 0.0
        
    
        for x in 0..<expNumber   {
            spentTotal = spentTotal + Double(self.itemArray[x].amountDbl)
        }
        
        let spentString = String(spentTotal) + "£"
        self.spentLabel.text = spentString
        
      
        var remainingNumber: Double = 0.0
        let bugetDbl = self.selectedCategory!.budgetDbl
        remainingNumber = Double(bugetDbl - spentTotal)
        let remainingNumberString = String(remainingNumber) + "£"
        
        self.remainingLabel.text = remainingNumberString
        
    }
    
    
    func updateTableHeader(){
        headerView.addSubview(pieChart)
        pieChart.centerInSuperview()
        pieChart.width(to: headerView)
        pieChart.height(to:headerView )
 
        var entries = [ChartDataEntry]()
        let expNumber =  self.itemArray.count
    
        for x in 0..<expNumber   {
            entries.append(ChartDataEntry(x : Double(x), y: Double( self.itemArray[x].amountDbl)))
        }
        
        var spentTotal: Double = 0.0
        for x in 0..<expNumber   {
            spentTotal = spentTotal + Double(self.itemArray[x].amountDbl)
        }
        var remainingNumber: Double = 0.0
        let bugetDbl = self.selectedCategory!.budgetDbl
        remainingNumber = Double(bugetDbl - spentTotal)
        
        if remainingNumber > 0.0 {
            entries.append(ChartDataEntry(x : Double(expNumber + 1), y: remainingNumber))
        }
        else{
            print("no money left")
        }
        
        
        
        let set = PieChartDataSet(entries:entries)
        set.colors = ChartColorTemplates.joyful()
               
        let data = PieChartData(dataSet: set)
        pieChart.data = data
    
        tableView.tableHeaderView = headerView
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
        //let totalToString = selectedCategory?.totalExpences
        //let totalExp = String(totalToString!)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        cell.expDue.text = self.itemArray[indexPath.row].date?.asString()
        
        
        if self.itemArray[indexPath.row].added == true {
            cell.expRemainder.text = "remainder set"
        } else {
            cell.expRemainder.text = " "
        }
            
        self.updateCategoryDetails()
        self.updateTableHeader()
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
            
      
            
            
            if self.itemArray[indexPath.row].added == true {
                self.addToCalendar.isOn = true
            } else {
                self.addToCalendar.isOn = false
                self.addToCalendar.addTarget(self, action:  #selector (self.didTapSwitch), for: .valueChanged)
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



