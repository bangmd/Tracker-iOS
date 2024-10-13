import Foundation

final class ScheduleMarshalling{
    func scheduleAsString(_ schedule: Set<DayOfWeeks>) -> String{
        return schedule.map { $0.rawValue }.joined(separator: ",")
    }
    
    func scheduleFromString(_ scheduleString: String) -> Set<DayOfWeeks> {
        let scheduleArray = scheduleString.split(separator: ",").map{ String($0)}
        return Set(scheduleArray.compactMap { DayOfWeeks(rawValue: $0) } )
    }
}
