//
//  MainRecipeCell.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/26/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit

/**
    Class that updates the recipe cell based on the recipe details.
 */
class MainRecipeCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var servings: UILabel!
    @IBOutlet weak var prep: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    /*
     Set label texts of the cell
     */
    func initCustom(nm:String, category:String, serving_size:Int16, prep_time:Int16) {
        name.text = nm
        servings.text = "Servings: \(serving_size)"
        prep.text = "Prep Time: \(prep_time) mins"

        switch category {
        case "Desserts":
            imgView.image = UIImage(named: "dessert")
            break
        case "Drinks":
            imgView.image = UIImage(named: "drink")
            break
        case "Breakfast/Brunch":
            imgView.image = UIImage(named: "breakfast")
            break
        case "Dinner":
            imgView.image = UIImage(named: "dinner")
            break
        default:
            imgView.image = UIImage(named: "other")
        }
    }

}
