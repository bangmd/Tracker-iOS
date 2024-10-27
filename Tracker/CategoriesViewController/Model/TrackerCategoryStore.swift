import CoreData
import UIKit

// MARK: - Protocol
protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateData(in store: TrackerCategoryStore)
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    
    // MARK: - Initializers
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Public Methods
extension TrackerCategoryStore {
    func createCategory(_ category: TrackerCategory){
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context)
        else { return }
        let categoryEntity = TrackerCategoryCoreData(entity: entity, insertInto: context)
        categoryEntity.title = category.title
        categoryEntity.trackers = NSSet(array: [])
        saveContext()
    }
    
    func deleteCategory(_ category: TrackerCategory){
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let result = try context.fetch(request)
            if let categoryToDelete = result.first {
                context.delete(categoryToDelete)
                saveContext()
            }
        } catch {
            print("Ошибка при удалении категории: \(error)")
        }
    }
    
    func updateCategory(oldTitle: String, with newTitle: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)
        
        do {
            let result = try context.fetch(request)
            if let categoryToUpdate = result.first {
                categoryToUpdate.title = newTitle
                saveContext()
            } else {
                print("Категория для обновления не найдена")
            }
        } catch {
            print("Ошибка при обновлении категории: \(error)")
        }
    }
    
    func fetchAllCategories() -> [TrackerCategoryCoreData]{
        return try! context.fetch(NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData"))
    }
    
    func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else { return nil }
        guard let trackers = trackerCategoryCoreData.trackers else { return nil }
        
        return TrackerCategory(title: title, trackers: trackers.compactMap { coreDataTracker -> Tracker? in
            if let coreDataTracker = coreDataTracker as? TrackerCoreData {
                return trackerStore.decodingTracker(from: coreDataTracker)
            }
            return nil
        })
    }
    
    func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        guard let trackerCoreData = trackerStore.addNewTracker(from: tracker) else { return }
        guard let existingCategory = fetchCategory(with: titleCategory) else { return }
        var existingTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
        existingTrackers.append(trackerCoreData)
        existingCategory.trackers = NSSet(array: existingTrackers)
        saveContext()
    }
    
    // MARK: - Private Methods
    private func fetchCategory(with title: String) -> TrackerCategoryCoreData? {
        return fetchAllCategories().filter({$0.title == title}).first ?? nil
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateData(in: self)
    }
}
