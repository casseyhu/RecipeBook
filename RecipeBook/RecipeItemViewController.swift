//
//  RecipeItemViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/27/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import CoreData

class RecipeItemViewController: UIViewController {

    @IBOutlet weak var recipe_name: UILabel!
    @IBOutlet weak var servings: UILabel!
    @IBOutlet weak var prep_time: UILabel!
    @IBOutlet weak var recipe_img: UIImageView!
    @IBOutlet weak var ingredient_table: UITableView!
    
    var recipe: Recipe?
    var ingredients = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient_table.delegate = self
        ingredient_table.dataSource = self
        let footer = UIView(frame: .zero)
        footer.backgroundColor = UIColor.clear
        ingredient_table.tableFooterView = footer
    
        setupRecipe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRecipe()
    }
    
    // Setup Recipe Display on screen
    func setupRecipe() {
        ingredients = [String]()
        if fetchRecipe(name: (recipe?.name)!) {
            recipe_name.text = recipe?.name
            servings.text = "Serving Size: \(String(describing: recipe!.servings))"
            prep_time.text = "Prep Time: \(String(describing: recipe!.prep)) mins"
            setImage()
        }
        loadIngredients(ingredString: (recipe?.ingredients)!)
        ingredient_table.reloadData()
    }
    
    // Fetch recipe from database to stay up to date
    func fetchRecipe(name:String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        do {
            let results = try PersistenceService.context.fetch(fetchRequest)
            if results.count != 0 {
                recipe = results[0] as? Recipe
                return true
            }
        } catch {
            print("Error Fetching Recipe")
        }
        return false
    }
    
    func setImage() {
        let category = recipe?.type
        switch category {
        case "Desserts":
            recipe_img.image = UIImage(named: "dessert")
            break
        case "Drinks":
            recipe_img.image = UIImage(named: "drink")
            break
        case "Breakfast/Brunch":
            recipe_img.image = UIImage(named: "breakfast")
            break
        case "Dinner":
            recipe_img.image = UIImage(named: "dinner")
            break
        default:
            recipe_img.image = UIImage(named: "other")
        }
    }
    
    // Formats the ingredients from X`Y`` into the 'ingredients' class var to load into view.
    func loadIngredients(ingredString: String){
        let dummyIngred = ingredString.components(separatedBy: "``")
        for elem in dummyIngred {
            if(elem == "") {
                break
            }
            print(elem)
            ingredients.append(elem)
        }
    }
    
    // Performs segue when user wants to edit the current recipe
    @IBAction func editRecipe(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "LoadRecipe", sender: self)
    }
    
    
    
    // MARK: - Navigation
    
    /*
        This gets called in the background when didSelectRowAt gets called in the extension below. Sets up the destination to load, gets the recipe row index, and grabs that recipe from the recipe array class var. Sets the 'currentRecipe' variable of AddViewController to have a reference to the selected recipe.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoadRecipe" {
            print("Running segue to load data into recipe display view")
            let addView = segue.destination as? AddViewController
            addView!.currentRecipe = recipe
        }
    }

}

extension RecipeItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        let ingredient = ingredients[indexPath.row].components(separatedBy: "`")
        cell.textLabel?.text = ingredient[0]
        cell.detailTextLabel?.text = ingredient[1]
        return cell
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let context = PersistenceService.context
//            ingredients.remove(at: indexPath.row)
//            
//            do {
//                try context.save()
//            } catch {
//                print("Error saving context: Deleting ingredient")
//            }
//            tableView.reloadData()
//        }
//    }
//    
//    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
}
