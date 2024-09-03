import CoreData
import UIKit

final class TrackerCategoryStore{
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory){
        let trackerCategoryEntity = TrackerCategoryCoreData(context: context)
        trackerCategoryEntity.title = trackerCategory.title
        
        for tracker in trackerCategory.trackers {
            let trackerEntity = TrackerCoreData(context: context)
            trackerEntity.id = tracker.id
            trackerEntity.title = tracker.title
            trackerEntity.color = uiColorMarshalling.hexString(from: tracker.color)
            trackerEntity.emoji = tracker.emoji
            trackerEntity.schedule = tracker.schedule as NSSet
            trackerEntity.type = tracker.type.rawValue
            
            trackerCategoryEntity.addToTrackers(trackerEntity)
        }
        saveContext()
    }
    
    func fetchAll() /*-> [TrackerCategory]*/ {
        // Используем fetchedResultsController для получения всех трекеров
        let request = TrackerCategoryCoreData.fetchRequest()
        do {
            let objects = try context.fetch(request)
            return convert(entities: objects)
        } catch {
            debugPrint("Fetch trackers error \(error)")
            //return []
        }
    }
    
    private func convert(entities: [TrackerCategoryCoreData]) /*-> [TrackerCategory]*/ {
        entities.map {
            print($0)
        }
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
