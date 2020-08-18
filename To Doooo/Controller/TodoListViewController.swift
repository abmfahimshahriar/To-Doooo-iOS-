//
//  ViewController.swift
//  To Doooo
//
//  Created by Fahim Shahriar on 14/8/20.
//  Copyright © 2020 Fahim Shahriar. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.bcColor {
            
            title = selectedCategory?.name
//            navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navigationController?.navigationBar.backgroundColor = navBarColor
                navigationController?.navigationBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.backgroundColor = UIColor.white
            }
            
        }
    }
    // MARK: - tableview data source methods
    // counts the number of items that needs to be shown in the tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // this function display an item for each of the items in the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory!.bcColor)?.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(todoItems!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    // MARK: - tableview delegate methods
    // this function selects a cell in the tableview and performs any operation you code up
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("error occured while saving done status \(error)")
            }
        }
        tableView.reloadData()
        
        // deselects a cell after touching it
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - add button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        
        // creates an action button
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen when we click add item
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch {
                    print("error occured while saving item \(error)")
                }
            }
            self.tableView.reloadData()
        }
        // adds a text field into the alert window
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - model manipulation methods
    
    // loads the existing data from database
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    // delete items
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            }
            catch {
                print("Error occured while deleting the item\(error)")
            }
        }
    }
    
}

// MARK: - search bar methods

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
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

