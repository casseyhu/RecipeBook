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
        
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    func loadDataFromDatabase() {
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        do {
            recipes = try context.fetch(request)
        } catch {
            print("Could not fetch")
        }
        
        print("testing 123")
    }
    
    // MARK: - Navigation
    
    /*
        This gets called in the background when didSelectRowAt gets called in the extension below. Sets up the destination to load, gets the recipe row index, and grabs that recipe from the recipe array class var. Sets the 'currentRecipe' variable of AddViewController to have a reference to the selected recipe. 
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("TEst")
        if segue.identifier == "LoadRecipe" {
            print("Running segue to load data into new recipe section")
            let addView = segue.destination as? AddViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedRecipe = recipes[selectedRow!]
            addView!.currentRecipe = selectedRecipe
        }
    }

}



/*
 Table View Delegate for selecting a row
 */
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        self.performSegue(withIdentifier: "LoadRecipe", sender: tableView.cellForRow(at: indexPath))
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

