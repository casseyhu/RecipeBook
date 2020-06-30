//
//  ConverterViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import CoreData

/**
    Converter tab ViewController. 
 */
class ConverterViewController: UIViewController {

    
    @IBOutlet weak var conversion_rate: UITextField!
    @IBOutlet weak var conversion_stepper: UIStepper!
    @IBOutlet weak var recipe_stack: UIStackView!
    @IBOutlet weak var recipe_button: UIButton!
    
    
    
    var recipes = [Recipe]()
    var recipe_name_buttons = [UIButton]()
//    var current_recipe:Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        loadDataFromDatabase()
        initRecipeDropdown()
    }
    
    
    /* After grabbing all the Recipe objects from the db, we create a button for each recipe with the title being the Recipe's name. We take this button and add it to the stackview for the dropdown: 'recipe_stack'. The new buttons will all be initially hidden and their action listeners/target will be set to the recipeTapped() function.
     */
    func initRecipeDropdown() {
        recipe_stack.alignment = .fill
        recipe_stack.distribution = .fillEqually
        recipe_stack.spacing = 0
        for rec in recipes {
            let button = UIButton()
            button.setTitle(rec.name!, for: .normal)
            button.titleLabel?.font = UIFont(name: "Courier", size: 18)
            button.backgroundColor = #colorLiteral(red: 0.8956311605, green: 0.9496255409, blue: 0.973573151, alpha: 1)
            button.addTarget(self, action: #selector(recipeTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isHidden = true
            recipe_stack.addArrangedSubview(button)
            recipe_name_buttons.append(button)
        }
        
    }
    
    /*
        Handles the choose a recipe button being clicked.
     */
    @IBAction func handleRecipeSelection(_ sender: Any) {
        print("Clicked choose recipe")
        recipe_click()
    }
    
    /*
        Animates the dropdown of the recipes to choose from.
     */
    func recipe_click(){
        recipe_name_buttons.forEach{ (button) in
            UIView.animate(withDuration: 0.3, animations: {
            button.isHidden = !button.isHidden
            self.view.layoutIfNeeded()
            })
        }
    }
    
    /*
        If a recipe is tapped, search for which recipe was clicked and set the title of the recipe_button (initial dropdown button) to the name of the recipe chosen.
     */
    @objc func recipeTapped(_ sender: UIButton?){
        for button in recipe_name_buttons {
            if button == sender {
//                print((button.titleLabel?.text)!)
//                print(recipes[indx].name!)
                recipe_button.titleLabel!.text = button.titleLabel?.text
                print("Set button title: \(recipe_button.titleLabel!.text)")
                recipe_click()
                return
            }
        }
    }
    
    /*
     Load tasks from the Recipe database
     */
    func loadDataFromDatabase() {
        let context = PersistenceService.persistentContainer.viewContext
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        do {
            recipes = try context.fetch(request)
        } catch {
            print("Could not fetch")
        }
    }
    
    @IBAction func clicked_stepper(_ sender: UIStepper) {
        conversion_rate.text = String(sender.value)
    }
    

}
