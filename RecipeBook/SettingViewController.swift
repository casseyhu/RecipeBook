//
//  SettingViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit

/**
    Settings tab ViewController. This class sorts data of the recipes according to user input. 
 */
class SettingViewController: UIViewController {
    
    @IBOutlet var sortButtons: [UIButton]!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sortAscending: UISwitch!
    
    enum SortOrder: String {
        case name = "Recipe Name"
        case servings = "Serving Size"
        case prep = "Prep Time"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let settings = UserDefaults.standard
        sortAscending.setOn(settings.bool(forKey:
            "SortAscending"), animated: true)
    }
    
    // MARK: - Sort Handlers
    
    /// Handles selection for sort order
    @IBAction func handleSortSelection(_ sender: UIButton) {
        sort_click()
    }
    
    /// Show/hide dropdown buttons when sort order button is clicked
    func sort_click() {
        sortButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /// Handles selection of sort type and updates sort order
    @IBAction func sortOrderTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let type = SortOrder(rawValue: title) else {
            return
        }
        sortButton.setTitle(type.rawValue, for: .normal)
        let settings = UserDefaults.standard
        let sort_dict = ["Recipe Name":"name", "Serving Size":"servings", "Prep Time":"prep"]
        settings.set(sort_dict[type.rawValue], forKey: "SortField")
        settings.synchronize()
        sort_click()
    }
    
    /// Handles toggle for sort ascending/descending.
    @IBAction func sortAscendingToggle(_ sender: UISwitch) {
        let settings = UserDefaults.standard
        settings.set(sender.isOn, forKey: "SortAscending")
        settings.synchronize()
    }
    
}
