import UIKit

enum TrackerType: String{
    case habit = "Habit"
    case oneTimeEvent = "OneTimeEvent"
}

enum DayOfWeeks: String, Codable, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var fullName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var shortName: String {
        return NSLocalizedString("\(self.rawValue)_short", comment: "")
    }
}

extension DayOfWeeks {
    static func from(weekday: Int) -> DayOfWeeks? {
        switch weekday {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }
}


struct Tracker{
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<DayOfWeeks>
    let type: TrackerType
    var isPinned: Bool
    var datePinned: Date?
    
    init(id: UUID, title: String, color: UIColor, emoji: String, schedule: Set<DayOfWeeks>, type: TrackerType, isPinned: Bool, datePinned: Date? = nil) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
        self.isPinned = isPinned
        self.datePinned = datePinned
    }
}
