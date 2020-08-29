//
//  ViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 6/25/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import CoreData
import FirebaseFirestore

/**
    Recipe tab ViewController.
 */
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var recipes = [Recipe]()
    let context = PersistenceService.persistentContainer.viewContext
    var uid:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        let settings = UserDefaults.standard
        settings.set("name", forKey: "SortField")
        settings.set(true, forKey: "SortAscending")
        uid = settings.string(forKey: "uid")!
        loadFromFireStore()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
    }
    
    func loadFromFireStore() {
        let context = PersistenceService.context
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try context.execute(DelAllReqVar) }
        catch { print(error) }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("recipes").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let recipe = Recipe(context: PersistenceService.context)
                        recipe.name = (data["name"] as! String)
                        recipe.type = (data["type"] as! String)
                        recipe.servings = (data["servings"] as! Int16)
                        recipe.prep = (data["prep"] as! Int16)
                        recipe.ingredients = (data["ingredients"] as! String)
                        PersistenceService.saveContext()
                        self.recipes.append(recipe)
                        self.tableView.reloadData()
                    }
                }
        }
        
    }

    
    // MARK: - Load recipes from database
    
    /// Fetches all recipse from core data based on sort settings.
    func loadDataFromDatabase() {
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: "SortField")
        let sortAscending = settings.bool(forKey: "SortAscending")
        let sort = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptors = [sort]
        request.sortDescriptors = sortDescriptors
        do {
            recipes = try context.fetch(request)
        } catch {
            print("Could not fetch")
        }
    }
    
    /// Listener to change the editing status of tableView.
    @IBAction func editList(_ sender: UIBarButtonItem) {
        if(self.tableView.isEditing == true) {
            self.tableView.isEditing = false
            sender.title = "Edit"
        } else {
            self.tableView.isEditing = true
            sender.title = "Done"
        }
    }
}



// MARK: - TableView methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    /*
     Table View Delegate for selecting a row
     Pushes RecipeViewController's view onto the nav stack to display.
     Sets the var 'recipe' of RecipeViewController to hold a reference to the selected Recipe object.
     */
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "add") as! RecipeItemViewController
        vc.title = recipes[indexPath.row].name!
        vc.recipe = recipes[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    Table View Data Source to display recipes
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = recipes[indexPath.row].name!
        let cat = recipes[indexPath.row].type!
        let serving = recipes[indexPath.row].servings
        let prep = recipes[indexPath.row].prep
        
        let item = tableView.dequeueReusableCell(withIdentifier: "recipe_cell", for: indexPath) as! MainRecipeCell

        item.initCustom(nm: name, category: cat, serving_size: serving, prep_time: prep)
        return item
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = PersistenceService.context
            let name = recipes[indexPath.row].name!
            context.delete(recipes[indexPath.row])
            do {
                try context.save()
                let db = Firestore.firestore()
                let uid = UserDefaults.standard.string(forKey: "uid")!
                db.collection("users").document(uid).collection("recipes").document(name).delete()
            } catch {
                print("Error saving context")
            }
            do {
                recipes = try context.fetch(Recipe.fetchRequest())
            } catch {
                print("Fetching Failed")
            }
            loadDataFromDatabase()
            tableView.reloadData()
        }
    }
}

