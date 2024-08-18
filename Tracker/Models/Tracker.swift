import UIKit

enum DayOfWeeks: String, CaseIterable{
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
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
    
    init(id: UUID, title: String, color: UIColor, emoji: String, schedule: Set<DayOfWeeks>) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
