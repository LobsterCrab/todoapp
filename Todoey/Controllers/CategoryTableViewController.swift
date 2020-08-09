
import UIKit
// import CoreData
import RealmSwift


class CategoryTableViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    // Context used for Core Data not needed for Realm
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        

    }
    
    //MARK: - TablieView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "Nothing here yet chief"
        
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Add Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Using Core Daata
            //let newCategory = Category(context: self.context)
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            
            // Realm auto updates value no need for appending like in Core Data
            //self.categories.append(newCategory)
            
            self.saveCategories(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert,animated: true,completion: nil)
        
      }
      
    
    //MARK: - Data Manipulation
    
    func saveCategories(category: Category){
        do{
        // Using Core Data
        //try context.save()
        
            try realm.write{
                realm.add(category)
            }
            
        }catch{
            print("Category not fucking saving ")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        // Core Data object loading
//        let request : NSFetchRequest<Category> = Category.fetchRequest()
//
//        do{
//            categories = try context.fetch(request)
//        }catch {
//            print("cant load shit in categories")
//        }
//
        tableView.reloadData()
        
    }
    
    //MARK: - Delete data at path
    override func updateModel(at indexPath: IndexPath) {
            if let categoryForDelete = self.categories?[indexPath.row]{

        do{
            try self.realm.write{
                self.realm.delete(categoryForDelete)
                }
            }catch{
                print("Does want to delete this shit because \(error)")
                }
        }
    }
    
  
}

