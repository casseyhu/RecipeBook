//
//  RecipeItemViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/27/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit

class RecipeItemViewController: UIViewController {

    var recipe: Recipe?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func editRecipe(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "LoadRecipe", sender: self)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
        This gets called in the background when didSelectRowAt gets called in the extension below. Sets up the destination to load, gets the recipe row index, and grabs that recipe from the recipe array class var. Sets the 'currentRecipe' variable of AddViewController to have a reference to the selected recipe.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("TEst")
        if segue.identifier == "LoadRecipe" {
            print("Running segue to load data into new recipe section")
            let addView = segue.destination as? AddViewController
            addView!.currentRecipe = recipe
        }
    }

}
