//
//  AddViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit

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
    
    
    // fixed bug owo
    @IBAction func saveRecipe(_ sender: Any) {
        let recipe = Recipe(context: PersistenceService.context)
        if let name = recipe_name.text {
            recipe.name = name
            print(name)
        }
        if let cat = typeButton.titleLabel?.text {
            recipe.type = cat
            print(cat)
        }
        if let serving = Double(serving_size.text!) {
            recipe.servings = Int16(serving)
            print(serving)
        }
        if let prep = Double(prep_time.text!) {
            recipe.prep = Int16(prep)
            print(prep)
        }
        
        PersistenceService.saveContext()
        let _ = navigationController?.popViewController(animated: true)
    }
    
    
}
