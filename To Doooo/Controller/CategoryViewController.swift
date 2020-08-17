//
//  CategoryViewController.swift
//  To Doooo
//
//  Created by Fahim Shahriar on 15/8/20.
//  Copyright © 2020 Fahim Shahriar. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        tableView.rowHeight = 80.0
    }
    
    // MARK: - tableview datasource methods
    // counts the number of items that needs to be shown in the tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    // this function display an item for each of the items in the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        let item = categoryArray?[indexPath.row]
        cell.textLabel?.text = item?.name ?? "No categories added yet"
        cell.delegate = self
        
        return cell
    }
    // MARK: - tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    // MARK: - add button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        // creates an action button
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what will happen when we click add item
            let newCategory = Category()
            newCategory.name = textField.text!
            
            // stores the array into new property list as an array
            self.saveData(category: newCategory)
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
    
    func saveData(category: Category) {
       
       do {
        try realm.write {
            realm.add(category)
        }
       }
       catch {
           print("error occured while saving context \(error)")
       }
       tableView.reloadData()
   }
   
   // loads the existing data from database
   func loadItems(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
   }

}

// MARK: - SwipeTableViewCellDelegate extension

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let categoryForDeletion = self.categoryArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(categoryForDeletion)
                    }
                }
                catch {
                    print("Error occured while deleting the category\(error)")
                }
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
