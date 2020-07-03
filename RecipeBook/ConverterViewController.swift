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
    Converter Tab View Controller. Enables users to convert recipe ingredients based on new serving size
 */
class ConverterViewController: UIViewController {

    @IBOutlet weak var conversion_rate: UITextField!
    @IBOutlet weak var recipe_stack: UIStackView!
    @IBOutlet weak var recipe_button: UIButton!
    @IBOutlet weak var ingredient_table: UITableView!
    @IBOutlet weak var prep_time: UILabel!
    
    var recipes = [Recipe]()
    var recipe_name_buttons = [UIButton]()
    var current_recipe:Recipe?
    var convert_rate:Double?
    var current_recipe_ingredients = [String]()
    var ingredient_qty = [Double]()
    var original_units = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient_table.delegate = self
        ingredient_table.dataSource = self
        loadDataFromDatabase()
        initRecipeDropdown()
        let footer = UIView(frame: .zero)
        footer.backgroundColor = UIColor.clear
        ingredient_table.tableFooterView = footer
        
        if current_recipe != nil {
            recipe_button.setTitle(current_recipe?.name!, for: .normal)
            loadIngredients(ingredString: (current_recipe?.ingredients)!)
            prep_time.text = "Prep Time: \((current_recipe?.prep)!) mins"
            conversion_rate.placeholder = "\((current_recipe?.servings)!) servings"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        initRecipeDropdown()
    }
    
    // MARK: - Handle Recipe Selection
    
    /// Sets up the stackview dropdown menu for selecting a recipe.
    ///
    /// After grabbing all the Recipe objects from the db, we create a button for each recipe with the title being the Recipe's name.
    /// We take this button and add it to the stackview for the dropdown: 'recipe_stack'. The new buttons will all be initially hidden
    /// and their action listeners/target will be set to the recipeTapped() function.
    func initRecipeDropdown() {
        recipe_name_buttons = [UIButton]()
        recipe_stack.alignment = .fill
        recipe_stack.distribution = .fillEqually
        recipe_stack.spacing = 0
        for rec in recipes {
            let button = UIButton()
            button.setTitle(rec.name!, for: .normal)
            button.titleLabel?.font = UIFont(name: "Courier", size: 18)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.6665995121, green: 0.666713655, blue: 0.6665844917, alpha: 1)
            button.addTarget(self, action: #selector(recipeTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isHidden = true
            recipe_stack.addArrangedSubview(button)
            recipe_name_buttons.append(button)
        }
    }
    
    /// Handles the choose a recipe button being clicked.
    ///
    /// - Parameters:
    ///     - sender: UIButton for the stackview dropdown.
    @IBAction func handleRecipeSelection(_ sender: Any) {
        recipe_click()
    }
    
    /// Animates the dropdown of the recipes to choose from by showing/hiding dropdown menu.
    func recipe_click(){
        recipe_name_buttons.forEach{ (button) in
            UIView.animate(withDuration: 0.3, animations: {
            button.isHidden = !button.isHidden
            self.view.layoutIfNeeded()
            })
        }
    }
    
    /// Searches for which recipe was clicked and set the title of the recipe_button (initial dropdown button) to the name of the recipe chosen.
    ///
    /// - Parameters:
    ///     - sender: UIButton of the recipe from the menu dropdown.
    @objc func recipeTapped(_ sender: UIButton?){
        guard let title = sender?.currentTitle else {
            return
        }
        recipe_button.setTitle(title, for: .normal)
        recipe_click()
        current_recipe = recipes[recipe_name_buttons.firstIndex(of: sender!)!]
        loadIngredients(ingredString: (current_recipe?.ingredients)!)
        prep_time.text = "Prep Time: \((current_recipe?.prep)!) mins"
        conversion_rate.placeholder = "\((current_recipe?.servings)!) servings"
    }
    
    
    // MARK: - Load data methods

    /// Loads recipe(s) from SQLite database using Core Data.
    func loadDataFromDatabase() {
        recipes = [Recipe]()
        let context = PersistenceService.persistentContainer.viewContext
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        do {
            recipes = try context.fetch(request)
        } catch {
            print("Could not fetch")
        }
    }
    
    /// Loads ingredients of the current selected recipe into screen's UITableView.
    func loadIngredients(ingredString: String){
        current_recipe_ingredients = [String]()
        let dummyIngred = ingredString.components(separatedBy: "``")
        for elem in dummyIngred {
            if(elem == "") {
                break
            }
            current_recipe_ingredients.append(elem)
        }
        ingredient_table.reloadData()
        loadIngredientQuantities()
    }
    
    /// Loads the ingredient quantities (i.e.: Eggs    2x) for conversion parsing.
    func loadIngredientQuantities(){
        ingredient_qty = [Double]()
        original_units = [String]()
        for rec in current_recipe_ingredients {
            let qty = rec.components(separatedBy: "`")[1]
            let qtyVal = getQtyValue(qtyString: qty)
            ingredient_qty.append(qtyVal ?? -1.0)
        }
    }
    
    /// Gets the respective Double of the String quantities loaded in by loadIngredientQuantities and their respective units.
    func getQtyValue(qtyString: String) -> Double? {
        var quant = ""
        var unit = ""
        for char in qtyString {
            if ( (char >= "0" && char <= "9") || char == "." || char == "/" ) {
                quant += [char]
            } else {
                unit += [char]
            }
        }
        if quant.count == 0 {
            // for example, ingredient with all chars/just a string
            original_units.append("")
            return nil
        }
        original_units.append(unit)
        if quant.contains("/"){
            let split = quant.components(separatedBy: "/")
            let div = Double( Double(split[0])! / Double(split[1])! )
            let divFormat = String(format: "%.2f", div)
            return Double(divFormat)
        } else {
            let formatted = String(format: "%.2f", Double(quant)!)
            return Double(formatted)
        }
    }
    
    // MARK: - Conversion listener
    
    /// Listener for the convert button. Updates ingredient quantities based on new serving size.
    @IBAction func clickedConvert(_ sender: UIButton) {
        sender.pulsate()
        if recipe_button.titleLabel!.text! != "Choose a recipe" {
            if let convert = Double(conversion_rate.text!) {
                conversion_rate.layer.borderColor = UIColor.black.cgColor
                conversion_rate.layer.borderWidth = 1.0
                convert_rate = convert / Double((current_recipe?.servings)!)
                adjustIngredients()
                ingredient_table.reloadData()
                return
            }
        }
        errorShake(textField: conversion_rate)
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
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    
    // MARK: - Ingredient Adjust function

    /// Adjusts ingredient quantities and updates UITableView data source. 
    func adjustIngredients() {
        if convert_rate != nil, current_recipe != nil{
            let ingredString = current_recipe!.ingredients
            let ingredArr = ingredString!.components(separatedBy: "``")
            var ingredNameArr = [String]()
            var originalQtyArr = [String]()
            for elem in ingredArr {
                if elem == "" {
                    break
                }
                let splitIngredient = elem.components(separatedBy: "`")
                ingredNameArr.append(splitIngredient[0])
                originalQtyArr.append(splitIngredient[1])
            }
            
            current_recipe_ingredients = [String]()
            for indx in 0...ingredNameArr.count-1{
                var recipeString = ""
                let newQty = ingredient_qty[indx] * convert_rate!
                if newQty >= 0 {
                    recipeString += ingredNameArr[indx] + "`" + String(format: "%.2f", newQty) + original_units[indx]
                } else {
                    recipeString += ingredNameArr[indx] + "`" + originalQtyArr[indx] + original_units[indx]
                }
                current_recipe_ingredients.append(recipeString)
            }
        }
        ingredient_table.reloadData()
    }

}

// MARK: - TableView methods
extension ConverterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return current_recipe_ingredients.count
    }
    
    /// Updates tableview cell with ingredient name and quantity
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        let ingredient = current_recipe_ingredients[indexPath.row].components(separatedBy: "`")
        cell.textLabel?.text = ingredient[0]
        cell.detailTextLabel?.text = ingredient[1]
        return cell
    }
    
}

