import UIKit

protocol AddNewTrackerViewControllerDelegate: AnyObject {
    func didAddNewTracker(_ tracker: Tracker, _ category: String)
}

final class AddNewTrackerViewController: UIViewController, NewHabitViewControllerDelegate, NewIrregularEventViewControllerDelegate{
    
    weak var delegate: AddNewTrackerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addTitle()
        addHabitButton()
        addIrregularEventButton()
    }
    
    func addTitle(){
        let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = .blackYP
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
    }
    
    func addHabitButton(){
        let habitButton = UIButton(type: .custom)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.backgroundColor = .blackYP
        habitButton.layer.cornerRadius = 16
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.setTitleColor(.whiteYP, for: .normal)
        habitButton.titleLabel?.textAlignment = .center
        
        view.addSubview(habitButton)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            habitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 308),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
    }
    
    func didCreateNewTracker(_ tracker: Tracker, _ category: String) {
        delegate?.didAddNewTracker(tracker, category)
    }
    
    func didCreateNewIrregularEvent(_ tracker: Tracker, _ category: String) {
        delegate?.didAddNewTracker(tracker, category)
    }
    
    @objc
    func habitButtonTapped(){
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
        present(newHabitViewController, animated: true)
    }
    
    func addIrregularEventButton(){
        let irregularEventButton = UIButton(type: .custom)
        irregularEventButton.setTitle("Нерегулярные событие", for: .normal)
        irregularEventButton.backgroundColor = .blackYP
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularEventButton.setTitleColor(.whiteYP, for: .normal)
        irregularEventButton.titleLabel?.textAlignment = .center
        
        view.addSubview(irregularEventButton)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            irregularEventButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 384),
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func irregularEventButtonTapped(){
        let newIrregularEventViewController = NewIrregularEventViewController()
        newIrregularEventViewController.delegate = self
        present(newIrregularEventViewController, animated: true)
    }
}
