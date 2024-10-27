import UIKit

// MARK: - ScheduleViewControllerProtocol
protocol ScheduleViewControllerProtocol: AnyObject{
    func didUpdateSelectedDays(_ selectedDays: Set<DayOfWeeks>)
}

final class ScheduleViewController: UIViewController, UITableViewDelegate{
    // MARK: - Private Properties
    private let weekDays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье",]
    private var daySelection = DaySelection()
    weak var delegate: ScheduleViewControllerProtocol?
    
    private lazy var label: UILabel = {
        var label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundYP
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    // MARK: - UI Setup
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addTitle()
        addDoneButton()
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
    }
    
    func addTitle(){
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
    }
    
    func addDoneButton(){
        let doneButton = UIButton(type: .custom)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .blackYP
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.titleLabel?.textAlignment = .center
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -157),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 47),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        doneButton.addTarget(self, action: #selector(DoneButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func DoneButtonTapped(){
        let newHabitViewController = NewHabitViewController()
        dismiss(animated: true)
        delegate?.didUpdateSelectedDays(daySelection.selectedDays)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfWeeks.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ScheduleTableViewCell else {
            return ScheduleTableViewCell()
        }
        let day = DayOfWeeks.allCases[indexPath.row]
        
        cell.selectionStyle = .none
        cell.configCell(text: day.rawValue)
        cell.switchView.tag = indexPath.row
        cell.switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc
    private func switchChanged(_ sender: UISwitch){
        let day = DayOfWeeks.allCases[sender.tag]
        daySelection.toggleSelection(for: day)
    }
}
