import Foundation

struct TrackerRecord: Hashable{
    let idTracker: UUID
    let date: Date
    
    init(idTracker: UUID, date: Date) {
        self.idTracker = idTracker
        self.date = date
    }
}
