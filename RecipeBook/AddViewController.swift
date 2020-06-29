//
//  AddViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import CoreData

/**
    Add recipe ViewController. This class controls the events that happen when the user presses the add (+) button in the Recipes tab.
    Adds new recipe to database.
 */

class AddViewController: UIViewController {

    
    @IBOutlet weak var recipe_name: UITextField!
    @IBOutlet weak var serving_size: UITextField!
    @IBOutlet weak var prep_time: UITextField!
    @IBOutlet weak var titleTopbar: UINavigationItem!
    
    @IBOutlet weak var ingredient_name: UITextField!
    @IBOutlet weak var ingredient_qty: UITextField!
  
    
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

    // Class var to hold a reference to a recipe that can be clicked in the main recipe tab bar.
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
            }
            if let prep = currentRecipe?.prep {
                prep_time.text = String(prep)
            }
            typeButton.setTitle(currentRecipe!.type, for: .normal)
            loadIngredients(ingredString: (currentRecipe?.ingredients)!)
        }
    }
    
    // Formats the ingredients from X`Y`` into the 'ingredients' class var to load into view.
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
    
    // '+' Button listener in adding a new ingredient to a recipe.
    @IBAction func addIngredient(_ sender: Any) {
        print("Adding ingredient")
        let validIngredients = checkIngredientInput()
        if validIngredients {
            ingredients.append(ingredient_name.text! + "`" + ingredient_qty.text!)
            tableView.reloadData()
            ingredient_name.text = ""
            ingredient_qty.text = ""
        }
    }
    
    // Checks if there's a provided ingredient name and quantity. If either is missing, shake the UITextFields to indicate a missing element.
    func checkIngredientInput() -> Bool {
        var valid:Bool = true
        if ingredient_name.text == "" {
            errorShake(textField: ingredient_name)
            ingredient_name.layer.borderColor = UIColor.red.cgColor
            ingredient_name.layer.borderWidth = 1.0
            valid = false
        }
        else {
            ingredient_name.layer.borderColor = UIColor.black.cgColor
            ingredient_name.layer.borderWidth = 0
        }
        if ingredient_qty.text == "" {
            ingredient_qty.layer.borderColor = UIColor.red.cgColor
            ingredient_qty.layer.borderWidth = 1.0
            errorShake(textField: ingredient_qty)
            valid = false
        }
        else {
            ingredient_qty.layer.borderColor = UIColor.black.cgColor
            ingredient_qty.layer.borderWidth = 0
        }
        return valid
        
    }
    
    // Shake animation on a UITextField and highlights the borders red.
    func errorShake(textField: UITextField){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 8, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 8, y: textField.center.y))
        textField.layer.add(animation, forKey: "position")
    }
    
    // Handles selection for recipe type
    @IBAction func handleTypeSelection(_ sender: UIButton) {
        type_click()
    }
    
    func type_click() {
        typeButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func typeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let type = RecipeType(rawValue: title) else {
            return
        }
        typeButton.setTitle(type.rawValue, for: .normal)
        type_click()
    }
    
    @IBAction func clickedStepper(_ sender: UIStepper) {
        if sender.restorationIdentifier! == "serving_stepper" {
            serving_size.text = String(sender.value)
        }
        else {
            prep_time.text = String(sender.value)
        }
    }
    
    // Saves a recipe into database or update if recipe name already exists
    @IBAction func saveRecipe(_ sender: Any) {
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
    
    // Compresses the ingredients class array into a string with '``' as the delimiter.
    func compress_ingredient() -> String {
        print(ingredients.count)
        var ingredients_str = ""
        for ingred in ingredients {
            ingredients_str += ingred + "``"
        }
        print(ingredients_str)
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
            //context.delete(ingredients[indexPath.row])
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
