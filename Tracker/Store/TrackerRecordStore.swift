import UIKit
import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewRecord(from trackerRecord: TrackerRecord) {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else { return }
        let newRecord = TrackerRecordCoreData(entity: entity, insertInto: context)
        newRecord.id = trackerRecord.idTracker
        newRecord.date = trackerRecord.date
        saveContext()
    }
    
    func removeRecord(for trackerRecord: TrackerRecord) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.idTracker as CVarArg, trackerRecord.date as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            saveContext()
        } catch {
            print("Failed to fetch or delete records: \(error)")
        }
    }
    
    func fetchAllCompletedTrackers() -> Set<TrackerRecord> {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let trackerRecordsCoreData = try context.fetch(fetchRequest)
            let trackerRecords = trackerRecordsCoreData.compactMap { coreDataRecord in
                return TrackerRecord(idTracker: coreDataRecord.id ?? UUID(), date: coreDataRecord.date ?? Date())
            }
            return Set(trackerRecords)
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return []
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

