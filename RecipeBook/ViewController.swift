//
//  ViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import CoreData

/**
    Recipe tab ViewController.
 */
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var recipes = [Recipe]()
    let context = PersistenceService.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)

        let settings = UserDefaults.standard
        settings.set("name", forKey: "SortField")
        settings.set(true, forKey: "SortAscending")
        
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    func loadDataFromDatabase() {
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: "SortField")
        let sortAscending = settings.bool(forKey: "SortAscending")
        let sort = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptors = [sort]
        request.sortDescriptors = sortDescriptors
        do {
            recipes = try context.fetch(request)
        } catch {
            print("Could not fetch")
        }
    }
    
    @IBAction func editList(_ sender: UIBarButtonItem) {
        if(self.tableView.isEditing == true) {
            self.tableView.isEditing = false
            sender.title = "Edit"
        } else {
            self.tableView.isEditing = true
            sender.title = "Done"
        }
    }
}



/*
 Table View Delegate for selecting a row
 Pushes RecipeViewController's view onto the nav stack to display.
 Sets the var 'recipe' of RecipeViewController to hold a reference to the selected Recipe object.
 */
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "add") as! RecipeItemViewController
        vc.title = recipes[indexPath.row].name!
        vc.recipe = recipes[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

/*
 Table View Data Source to display recipes
 */
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = recipes[indexPath.row].name!
        let cat = recipes[indexPath.row].type!
        let serving = recipes[indexPath.row].servings
        let prep = recipes[indexPath.row].prep
        
        let item = tableView.dequeueReusableCell(withIdentifier: "recipe_cell", for: indexPath) as! MainRecipeCell

        item.initCustom(nm: name, category: cat, serving_size: serving, prep_time: prep)
        return item
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = PersistenceService.context
            context.delete(recipes[indexPath.row])
            do {
                try context.save()
            } catch {
                print("Error saving context")
            }
            do {
                recipes = try context.fetch(Recipe.fetchRequest())
            } catch {
                print("Fetching Failed")
            }
            loadDataFromDatabase()
            tableView.reloadData()
        }
    }
}

