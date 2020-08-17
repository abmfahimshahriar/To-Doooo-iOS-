//
//  CategoryViewController.swift
//  To Doooo
//
//  Created by Fahim Shahriar on 15/8/20.
//  Copyright © 2020 Fahim Shahriar. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    // MARK: - tableview datasource methods
    // counts the number of items that needs to be shown in the tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // this function display an item for each of the items in the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let item = categoryArray[indexPath.row]
        cell.textLabel?.text = item.name
        
        return cell
    }
    // MARK: - tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    // MARK: - add button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        // creates an action button
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what will happen when we click add item
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)
            // stores the array into new property list as an array
            self.saveData()
        }
        // adds a text field into the alert window
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - data manipulation methods
    
   func saveData() {
       
       do {
           try context.save()
       }
       catch {
           print("error occured while saving context \(error)")
       }
       tableView.reloadData()
   }
   
   // loads the existing data from database
   func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()){
       
       do {
           categoryArray = try context.fetch(request)
       }
       catch {
           print("error occured while fetching data from context \(error)")
       }
       tableView.reloadData()
   }

}
