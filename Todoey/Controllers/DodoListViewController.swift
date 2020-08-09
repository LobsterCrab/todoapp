

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: SwipeTableViewController{
    
    
    //Core Data
    //var itemArray = [Item]()
    
    let realm = try! Realm()
    
    //Legacy naming convention for clarity
    //With the use of Realm it is no longer an array of items
    var itemArray: Results<Item>?
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
            print("done it")
        }
    }
    
    let defaults = UserDefaults.standard
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    // Realm Context not needed
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        // User defaults
//        if let items = defaults.array(forKey: "TodoListArray") as? [String]{
//            itemArray = items
//        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if item.done == true {
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }else{
            cell.textLabel?.text = "There are no items here"
        }

        
        
        return cell
    }
    
    //MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Can delete items on click
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        //ticks item as completed with Core Data
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                    //realm.delete(item)
                }
            }catch {
                print("error ticking box \(error)")
            }
        }
        
        //saveItem()
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var holderBitch = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title:"Add Item", style: .default) { (action) in
            
            /* Item addition using Core Data
            let newItem = Item(context: self.context)
            newItem.title = holderBitch.text!
            newItem.done = false
            newItem.parent = self.selectedCategory

            self.itemArray.append(newItem)
            */
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = holderBitch.text!
                        newItem.done = false
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("cant write \(error)")
                }
                
            }
            
            self.tableView.reloadData()
            
            //Save item with Core Data
            //self.saveItem()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            holderBitch = alertTextField
        }
        
        alert.addAction(action)
        present(alert,animated:true,completion:nil)
    }
    
    func saveItem(){
        /* for saving with plist
        let encoder = PropertyListEncoder()
        
        do{
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch{
            print("error encoding item array")
        }
         */
        /* for saving with core data
        do {
            try context.save()
        } catch{
            print("errorr saving context")
        }
        
        */
        self.tableView.reloadData()

    }
    
    func loadItems(
        //Core data
        //with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil
            ){

        itemArray = selectedCategory?.items.sorted(byKeyPath:"title",ascending:true)
        
        //Core Data method for loading data
//         let categoryPredicate = NSPredicate(format: "parent.name MATCHES %@",selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
//        }else{
//            request.predicate = categoryPredicate
//        }
//
//        do{
//        itemArray = try context.fetch(request)
//        }catch{
//            print("Cant get data because \(error)")
//        }

        tableView.reloadData()
        // This is for saving to plist using encodable and decodable -> codable
//        if let data = try? Data(contentsOf:dataFilePath!){
//            let decoder = PropertyListDecoder()
//            do{
//            itemArray = try decoder.decode([Item].self, from: data)
//            }catch{
//                print("Po pizde poshlo")
//            }
//        }

    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row]{
            do{
            try realm.write{
                realm.delete(item)
                }
            }catch{
                print("error with deleting \(error)")
            }
        }
    }
}

//MARK: - UI Search Bar delegate methoids

// Core Data query our Items list
//extension TodoListViewController: UISearchBarDelegate{
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        let request :NSFetchRequest<Item> = Item.fetchRequest()
//
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key:"title",ascending: true)]
//
//        loadItems(with:request)
//        tableView.reloadData()
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//
//            tableView.reloadData()
//        }
//    }
//
//}

extension TodoListViewController: UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArray = itemArray?.filter("title CONTAINS[cd] %@",searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
                loadItems()
    
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
    
                tableView.reloadData()
            }
        }
    
}
