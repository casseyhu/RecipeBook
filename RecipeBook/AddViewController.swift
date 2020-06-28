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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // If the current recipe != nil, that means it was set in ViewController by a recipe cell being clicked. Load this information into the fields to display.
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
            // COME BACK TO SETTING INGREDIENTS ONCE IMPLEMENTED
        }
        
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
    
    @IBAction func serving_stepper(_ sender: UIStepper) {
        serving_size.text = String(sender.value)
    }
    
    @IBAction func prep_stepper(_ sender: UIStepper) {
        prep_time.text = String(sender.value)
    }
    
    
    //  BUG: repeat save, needs to update
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
        
        if !fetchEvent(name: name, type: type, ingr: "", servings: servings, prep: prep) {
            let recipe = Recipe(context: PersistenceService.context)
            recipe.name = name
            recipe.type = type
            recipe.servings = servings
            recipe.prep = prep
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
                print(managedObject.name! + "---")
                return true
            }
        } catch {
            print("bad")
        }
        return false
    }
    
    
}
