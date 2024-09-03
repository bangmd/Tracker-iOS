import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!

    init(context: NSManagedObjectContext) {
        self.context = context
        setupFetchedResultsController()
    }

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    func addNewTracker(_ tracker: Tracker) throws {
        let trackerEntity = TrackerCoreData(context: context)
        updateExistingTracker(trackerEntity, with: tracker)
        saveContext()
    }

    func fetchAll() -> [Tracker] {
        // Используем fetchedResultsController для получения всех трекеров
        do {
            try fetchedResultsController.performFetch()
            guard let objects = fetchedResultsController.fetchedObjects else { return [] }
            return convert(entities: objects)
        } catch {
            debugPrint("Fetch trackers error \(error)")
            return []
        }
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSSet
        trackerCoreData.type = tracker.type.rawValue
    }

    // MARK: - Private methods:

    private func convert(entities: [TrackerCoreData]) -> [Tracker] {
        entities.map {
            let scheduleSet = $0.schedule as? Set<DayOfWeeks> ?? []

            return Tracker(id: $0.id ?? UUID(),
                           title: $0.title ?? "",
                           color: uiColorMarshalling.color(from: $0.color ?? "") ?? UIColor.clear,
                           emoji: $0.emoji ?? "",
                           schedule: scheduleSet,
                           type: TrackerType(rawValue: $0.type!) ?? TrackerType.oneTimeEvent)
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        // Note: Мы не устанавливаем делегат в этом примере, чтобы не обрабатывать события обновления.
    }
}
