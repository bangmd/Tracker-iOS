import Foundation

struct DaySelection{
    var selectedDays: Set<DayOfWeeks> = []
    
    mutating func toggleSelection(for day: DayOfWeeks){
        if selectedDays.contains(day){
            selectedDays.remove(day)
        }else{
            selectedDays.insert(day)
        }
    }
    
    func isSelected(day: DayOfWeeks)->Bool{
        return selectedDays.contains(day)
    }
}
