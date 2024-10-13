import Foundation
import CoreData

@objc(ScheduleTransformer)
final class ScheduleTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let daysSet = value as? Set<DayOfWeeks> else { return nil }
        return try? PropertyListEncoder().encode(daysSet)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? PropertyListDecoder().decode(Set<DayOfWeeks>.self, from: data)
    }
}

