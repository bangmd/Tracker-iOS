import Foundation

struct TrackerCategory{
    var title: String
    var trackers: [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
