import CoreData
import UIKit

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func deleteAllDataForAllEntities() {
        let entities = ["TrackerCoreData", "TrackerCategoryCoreData", "TrackerRecordCoreData"]
        entities.forEach { entity in
            deleteAllData(entity: entity)
        }
    }

    func deleteAllData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.includesPropertyValues = false

        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
            try context.save()
        } catch let error {
            print("Failed to delete all data in \(entity): \(error)")
        }
    }
    
    func addNewTracker(from tracker: Tracker) -> TrackerCoreData? {
        guard let trackerCoreData = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else { return nil }
        let newTracker = TrackerCoreData(entity: trackerCoreData, insertInto: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.color = uiColorMarshalling.hexString(from: tracker.color)
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule as NSSet
        newTracker.type = tracker.type.rawValue
        newTracker.isPinned = tracker.isPinned
        return newTracker
    }
    
    func fetchTracker() -> [Tracker] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackerCoreDataArray = try! managedContext.fetch(fetchRequest)
        let trackers = trackerCoreDataArray.map { trackerCoreData in
            return Tracker(
                id: trackerCoreData.id ?? UUID(),
                title: trackerCoreData.title ?? "",
                color: uiColorMarshalling.color(from: trackerCoreData.color ?? "") ?? UIColor.clear,
                emoji: trackerCoreData.emoji ?? "",
                schedule: trackerCoreData.schedule as? Set<DayOfWeeks> ?? [],
                type: TrackerType(rawValue: trackerCoreData.type ?? "") ?? TrackerType.oneTimeEvent,
                isPinned: trackerCoreData.isPinned
            )
        }
        return trackers
    }
    
    func decodingTracker(from trackersCoreData: TrackerCoreData) -> Tracker?{
        guard let id = trackersCoreData.id, let title = trackersCoreData.title,
              let color = trackersCoreData.color, let emoji = trackersCoreData.emoji, let type = trackersCoreData.type
        else { return nil }
        
        return Tracker(id: id, title: title, color: uiColorMarshalling.color(from: color) ?? UIColor.clear, emoji: emoji, schedule:
                        (trackersCoreData.schedule as? Set<DayOfWeeks>) ?? [], type: TrackerType(rawValue: type) ?? TrackerType.oneTimeEvent, isPinned: trackersCoreData.isPinned)
    }
    
    func fetchCoreDataTracker(by id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch tracker with id \(id): \(error)")
            return nil
        }
    }

    func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }
    
    func saveContext(){
        do{
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func savePinnedState(for tracker: Tracker) {
        if let coreDataTracker = fetchCoreDataTracker(by: tracker.id) {
            coreDataTracker.isPinned = tracker.isPinned
            saveContext()
        }
    }

    func updateTracker(_ tracker: Tracker, newCategory: String) {
        guard let coreDataTracker = fetchCoreDataTracker(by: tracker.id) else {
            print("Трекер с ID \(tracker.id) не найден.")
            return
        }

        var newCategoryCoreData: TrackerCategoryCoreData?

        if !newCategory.isEmpty && newCategory != "Закрепленные" {
            newCategoryCoreData = TrackerCategoryStore().fetchCategory(with: newCategory)
        } else {
            newCategoryCoreData = coreDataTracker.category
        }

        guard let categoryCoreData = newCategoryCoreData else {
            print("Категория не найдена.")
            return
        }

        coreDataTracker.title = tracker.title
        coreDataTracker.color = UIColorMarshalling().hexString(from: tracker.color)
        coreDataTracker.emoji = tracker.emoji
        coreDataTracker.schedule = tracker.schedule as NSSet
        coreDataTracker.isPinned = tracker.isPinned
        coreDataTracker.datePinned = tracker.datePinned

        if coreDataTracker.category != categoryCoreData {
            coreDataTracker.category = categoryCoreData
        }

        saveContext()
    }
}

