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
        
        // Do any additional setup after loading the view.
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
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        initRecipeDropdown()
    }
    
    /* After grabbing all the Recipe objects from the db, we create a button for each recipe with the title being the Recipe's name. We take this button and add it to the stackview for the dropdown: 'recipe_stack'. The new buttons will all be initially hidden and their action listeners/target will be set to the recipeTapped() function.
     */
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
        guard let title = sender?.currentTitle else {
            return
        }
        recipe_button.setTitle(title, for: .normal)
        recipe_click()
        current_recipe = recipes[recipe_name_buttons.firstIndex(of: sender!)!]
        loadIngredients(ingredString: (current_recipe?.ingredients)!)
        prep_time.text = "Prep Time: \((current_recipe?.prep)!) mins"
    }
    
    
    // MARK: - Load data methods

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
    
    func loadIngredients(ingredString: String){
        current_recipe_ingredients = [String]()
        let dummyIngred = ingredString.components(separatedBy: "``")
        for elem in dummyIngred {
            if(elem == "") {
                break
            }
            print(elem)
            current_recipe_ingredients.append(elem)
        }
        ingredient_table.reloadData()
        loadIngredientQuantities()
    }
    
    func loadIngredientQuantities(){
        ingredient_qty = [Double]()
        original_units = [String]()
        for rec in current_recipe_ingredients {
            var arr = rec.components(separatedBy: "`")
            let qty = arr[1]
            var qtyVal = getQtyValue(qtyString: qty)
            if(qtyVal == nil) {
                ingredient_qty.append(-1.0)
            }
            else {
                ingredient_qty.append(qtyVal!)
            }
        }
    }
    
    func getQtyValue(qtyString: String) -> Double? {
        var quant = ""
        var unit = ""
        for char in qtyString {
            if ( (char >= "0" && char <= "9") || char == "." || char == "/" ) {
                quant += [char]
            }
            else {
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
            let ret = Double(divFormat)
            return ret
        }
        else {
            let quantAsDouble = Double(quant)
            let formatted = String(format: "%.2f", quantAsDouble!)
            let ret = Double(formatted)
            return ret
        }
    }
    
    // MARK: - Stepper listener
    @IBAction func clicked_stepper(_ sender: UIStepper) {
        let val = Double(round(10 * sender.value)/10)
        conversion_rate.text = String(val)
        
        convert_rate = val
        adjustIngredients()
        ingredient_table.reloadData()
    }
    
    
    // MARK: - Ingredient Adjust function

    func adjustIngredients() {
        if convert_rate != nil, current_recipe != nil{
            print("test")
            let ingredString = current_recipe!.ingredients
            let ingredArr = ingredString!.components(separatedBy: "``")
            var ingredNameArr = [String]()
            var originalQtyArr = [String]()
            for elem in ingredArr {
                if elem == "" {
                    break
                }
                let splitIngredient = elem.components(separatedBy: "`")
                ingredNameArr.append(splitIngredient[0]) // appends just the name of ingredient to the name arr
                originalQtyArr.append(splitIngredient[1])
            }
            
            var newIngredQty = [Double]()
            for indx in 0...ingredient_qty.count-1 {
                if ingredient_qty[indx] >= 0 {
                    newIngredQty.append(ingredient_qty[indx] * convert_rate!)
                } else {
                    newIngredQty.append(-1.0)
                }
            }
            
            print(original_units)
            current_recipe_ingredients = [String]()
            for indx in 0...ingredNameArr.count-1{
                var recipeString = ""
                if newIngredQty[indx] >= 0 {
                    recipeString += ingredNameArr[indx] + "`" + String(format: "%.2f", newIngredQty[indx]) + original_units[indx]
                    print("New adjusted recipe string \(recipeString)")
                } else {
                    recipeString += ingredNameArr[indx] + "`" + originalQtyArr[indx] + original_units[indx]
                }
                current_recipe_ingredients.append(recipeString)
            }
        }
        ingredient_table.reloadData()
        
    }

}

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        let ingredient = current_recipe_ingredients[indexPath.row].components(separatedBy: "`")
        cell.textLabel?.text = ingredient[0]
        cell.detailTextLabel?.text = ingredient[1]
        return cell
    }
    
    
}

