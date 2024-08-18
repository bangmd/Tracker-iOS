import UIKit

protocol NewHabitViewControllerDelegate: AnyObject{
    func didCreateNewTracker(tracker: Tracker)
}

final class NewHabitViewController: UIViewController, UITextFieldDelegate{
    let tableInformation = ["Категория", "Расписание"]
    var selectedDays: Set<DayOfWeeks> = []
    weak var delegate: NewHabitViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Новая привычка"
        titleLabel.textColor = .blackYP
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        return titleLabel
    }()
    
    private lazy var textField: UITextField = {
        var textField = PaddedTextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundYP
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .grayYP
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .whiteYP
        tableView.isScrollEnabled = false
        tableView.register(TrackerTableCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stackView.axis = .horizontal
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        var saveButton = UIButton(type: .custom)
        saveButton.setTitle("Создать", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.whiteYP, for: .normal)
        saveButton.backgroundColor = .blackYP
        saveButton.layer.cornerRadius = 16
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return saveButton
    }()
    
    @objc
    private func saveButtonTapped(){
        let newTracker = Tracker(id: UUID(),
                                 title: textField.text ?? "",
                                 color: .blueYP,
                                 emoji: "📸",
                                 schedule: selectedDays)
        
        delegate?.didCreateNewTracker(tracker: newTracker)
        
        if let rootViewController = self.view.window?.rootViewController{
            rootViewController.dismiss(animated: true)
        }
        
    }
    
    private lazy var cancelButton: UIButton = {
        var cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.redYP, for: .normal)
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.redYP.cgColor
        cancelButton.layer.cornerRadius = 16
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return cancelButton
    }()
    
    @objc
    private func cancelButtonTapped(){
        if let rootViewController = self.view.window?.rootViewController{
            rootViewController.dismiss(animated: true)
        }
    }
    
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 61),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 174),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}

extension NewHabitViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerTableCell else {
            return TrackerTableCell()
        }
        cell.configCell(text: tableInformation[indexPath.row], image: UIImage(named: "backward"))
        
        return cell
    }
}

extension NewHabitViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let categoryViewController = CategoryViewController()
            present(categoryViewController, animated: true)
        }else if indexPath.row == 1{
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
    }
}

extension NewHabitViewController: ScheduleViewControllerProtocol{
    func didUpdateSelectedDays(_ selectedDays: Set<DayOfWeeks>) {
        self.selectedDays = selectedDays
    }
}
