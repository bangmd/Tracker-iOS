import UIKit

final class CategoriesViewModel: TrackerCategoryStoreDelegate {
    // MARK: - Bindings
    var onCategoriesChanged: (() -> Void)?
    
    // MARK: - Private Properties
    private let trackerCategoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    
    // MARK: - Initialization
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerCategoryStore.delegate = self
        fetchCategories()
    }
    
    // MARK: - Data Fetching
    func fetchCategories(){
        let fetchedCategories = trackerCategoryStore.fetchAllCategories()
        categories = fetchedCategories.compactMap({  trackerCategoryStore.decodingCategory(from: $0 )})
        onCategoriesChanged?()
    }
    
    // MARK: - Category Handling
    func categoryTitle(at index: Int) -> String {
        return categories[index].title
    }
    
    var numbersOfCategories: Int {
        return categories.count
    }
    
    func addCategory(title: String){
        let newCategory = TrackerCategory(title: title, trackers: [])
        trackerCategoryStore.createCategory(newCategory)
        fetchCategories()
    }
    
    func deleteCategory(at index: Int) {
        let categoryToDelete = categories[index]
        categories.remove(at: index)
        trackerCategoryStore.deleteCategory(categoryToDelete)
        onCategoriesChanged?()
    }
    
    func didUpdateData(in store: TrackerCategoryStore) {
        fetchCategories()
    }
    
    func updateCategory(at index: Int, with newTitle: String) {
        let oldTitle = categories[index].title
        categories[index].title = newTitle
        trackerCategoryStore.updateCategory(oldTitle: oldTitle, with: newTitle)
        onCategoriesChanged?()
    }
    
    // MARK: - TrackerCategoryStoreDelegate
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
}
