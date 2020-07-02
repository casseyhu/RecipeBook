//
//  AddViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import CoreData

/// Add recipe ViewController. Controls the events that happen when the user presses the add (+) button in the Recipes tab.
/// Adds new recipe to database.

class AddViewController: UIViewController {

    @IBOutlet weak var recipe_name: UITextField!
    @IBOutlet weak var serving_size: UITextField!
    @IBOutlet weak var prep_time: UITextField!
    @IBOutlet weak var titleTopbar: UINavigationItem!
    
    @IBOutlet weak var ingredient_name: UITextField!
    @IBOutlet weak var ingredient_qty: UITextField!
  
    @IBOutlet weak var serving_stepper: UIStepper!
    @IBOutlet weak var prep_stepper: UIStepper!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet weak var typeButton: UIButton!
    
    enum RecipeType: String {
        case dessert = "Desserts"
        case drink = "Drinks"
        case breakfast = "Breakfast/Brunch"
        case dinner = "Dinner"
        case other = "Other"
    }
    
    var currentRecipe: Recipe?
    var ingredients = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let footer = UIView(frame: .zero)
        footer.backgroundColor = UIColor.clear
        tableView.tableFooterView = footer
        
        if currentRecipe != nil {
            titleTopbar.title = "Edit Recipe"
            recipe_name.text = currentRecipe?.name
            if let servings = currentRecipe?.servings {
                serving_size.text = String(servings)
                serving_stepper.value = Double(servings)
            }
            if let prep = currentRecipe?.prep {
                prep_time.text = String(prep)
                prep_stepper.value = Double(prep)
            }
            typeButton.setTitle(currentRecipe!.type, for: .normal)
            loadIngredients(ingredString: (currentRecipe?.ingredients)!)
        }
    }
    
    /// Formats the ingredients from X`Y`` into the 'ingredients' class var to load into UITableView.
    ///
    /// - Parameters:
    ///      - ingredString: Ingredients for the recipe in the format of Eggs`2x`` with '`' and '``' as delimiters.
    
    func loadIngredients(ingredString: String){
        let dummyIngred = ingredString.components(separatedBy: "``")
        for elem in dummyIngred {
            if(elem == "") {
                // This accounts for the last element.
                // Ex: Egg`1x``Milk`50mL``
                // -> [Egg`1x, Milk`50mL, ] <- Has extra elem.
                break
            }
            ingredients.append(elem)
        }
        tableView.reloadData()
    }
    
    /// Listener to add a new recipe.
    @IBAction func addIngredient(_ sender: Any) {
        print("Adding ingredient")
        if checkTextInput([ingredient_name, ingredient_qty]) {
            ingredients.append(ingredient_name.text! + "`" + ingredient_qty.text!)
            tableView.reloadData()
            ingredient_name.text = ""
            ingredient_qty.text = ""
        }
    }
    
    /// Checks for valid user input for text fields in adding/editing recipies.
    /// - Parameters:
    ///     - txtFields: Array of the UITextField elements on the UI.
    /// - Returns: Bool indicating if the inputs were well formatted, false otherwise.
    func checkTextInput(_ txtFields:[UITextField]) -> Bool {
        var valid:Bool = true
        for txtField in txtFields {
            if txtField.text == "" {
                errorShake(textField: txtField)
                txtField.layer.borderColor = UIColor.red.cgColor
                txtField.layer.borderWidth = 1.0
                valid = false
            }
            else {
                txtField.layer.borderColor = UIColor.black.cgColor
                txtField.layer.borderWidth = 0
            }
        }
        return valid
    }
    
    /// Shake animation on a UITextField. Highlights the borders red.
    ///
    /// - Parameters:
    ///     - textField: Textfield to shake.
    func errorShake(textField: UITextField){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 8, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 8, y: textField.center.y))
        textField.layer.add(animation, forKey: "position")
    }
    
    /// Handles selection for recipe type
    @IBAction func handleTypeSelection(_ sender: UIButton) {
        type_click()
    }
    
    /// Animates the dropdown of the recipes to choose from by showing/hiding dropdown menu.
    func type_click() {
        typeButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /// Sets the title of the stackview dropdown menu upon user choice.
    ///
    /// - Parameters:
    ///     - sender: UIButton of the dropdown menu for category of recipe.
    @IBAction func typeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let type = RecipeType(rawValue: title) else {
            return
        }
        typeButton.setTitle(type.rawValue, for: .normal)
        type_click()
    }
    
    /// Stepper listener. Increments/decrements by 1.
    ///
    /// - Parameters:
    ///     - sender: UIStepper widget to listen to.
    @IBAction func clickedStepper(_ sender: UIStepper) {
        if sender.restorationIdentifier! == "serving_stepper" {
            serving_size.text = String(sender.value)
        }
        else {
            prep_time.text = String(sender.value)
        }
    }
    
    /// Saves a recipe into database or updates if recipe name already exists.
    ///
    /// - Parameters:
    ///     - sender: Save widget to listen on.
    @IBAction func saveRecipe(_ sender: Any) {
        if !checkTextInput([recipe_name, serving_size, prep_time]) {
            return
        }
        var name:String!, type:String!
        var servings:Int16!, prep:Int16!
        
        if let n = recipe_name.text {
            name = n
        }
        if let cat = typeButton.titleLabel?.text {
            type = cat
        }
        if let serving = Double(serving_size.text!) {
            servings = Int16(serving)
        }
        if let p = Double(prep_time.text!) {
            prep = Int16(p)
        }
        let ingred = compress_ingredient()
        print("Saving recipe- ingredints: \(ingred)")
        if !fetchEvent(name: name, type: type, ingr: ingred, servings: servings, prep: prep) {
            let recipe = Recipe(context: PersistenceService.context)
            recipe.name = name
            recipe.type = type
            recipe.servings = servings
            recipe.prep = prep
            recipe.ingredients = ingred
            PersistenceService.saveContext()
        }
        let _ = navigationController?.popViewController(animated: true)
    }
    
    /// Checks database for a specific recipe name and updates the recipe in the database if it exists
    ///
    /// - Parameters:
    ///     - name: Name of the recipe.
    ///     - type: Type of the ingredient.
    ///     - ingr: Ingredients of the recipe.
    ///     - servings: Servings of the recipe
    ///     - prep: Preparation time of the recipe.
    /// - Returns: true if the recipe exists in the database, false if otherwise.
    func fetchEvent(name:String, type:String, ingr:String, servings:Int16, prep:Int16) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        do {
            let results = try PersistenceService.context.fetch(fetchRequest)
            if results.count != 0 {
                let managedObject = results[0] as! Recipe
                managedObject.setValue(name, forKey: "name")
                managedObject.setValue(type, forKey: "type")
                managedObject.setValue(servings, forKey: "servings")
                managedObject.setValue(prep, forKey: "prep")
                managedObject.setValue(ingr, forKey: "ingredients")
                PersistenceService.saveContext()
                return true
            }
        } catch {
            return false
        }
        return false
    }
    
    /// Compresses the ingredients class array into a string with '``' as the delimiter.
    func compress_ingredient() -> String {
        print(ingredients.count)
        var ingredients_str = ""
        for ingred in ingredients {
            ingredients_str += ingred + "``"
        }
        return ingredients_str
    }
    
    
}


extension AddViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = PersistenceService.context
            ingredients.remove(at: indexPath.row)
            do {
                try context.save()
            } catch {
                print("Error saving context: Deleting ingredient")
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
