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

    
    @IBOutlet weak var recipe_name: UITextField!
    @IBOutlet weak var conversion_rate: UITextField!
    @IBOutlet weak var conversion_stepper: UIStepper!
    
    
    
    var recipes = [Recipe]()
    var current_recipe:Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if current_recipe == nil {
            initRecipeDropdown()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func initRecipeDropdown() {
        loadDataFromDatabase()
        
    }
    
    /*
     Load tasks from the Planner database based on sort fields
     */
    func loadDataFromDatabase() {
        let context = PersistenceService.persistentContainer.viewContext
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
//
//        let settings = UserDefaults.standard
//        let sortField = settings.string(forKey: "SortField")
//        let sortAscending = settings.bool(forKey: "SortAscending")
//
//        let sort = NSSortDescriptor(key: sortField, ascending: sortAscending)
//        let sortDescriptors = [sort]
//        request.sortDescriptors = sortDescriptors
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
