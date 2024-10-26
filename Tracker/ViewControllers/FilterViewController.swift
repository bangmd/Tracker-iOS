import UIKit

enum TrackerFilter: String {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completedTrackers = "Завершённые"
    case incompleteTrackers = "Незавершённые"
}

// MARK: - FilterViewControllerDelegateProtocol
protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

class FilterViewController: UIViewController {
    // MARK: - Public Properties
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilterIndex: Int?

    // MARK: - Private Properties
    private let filters = ["Все трекеры", "Трекеры на сегодня", "Завершённые", "Незавершённые"]
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Filters", comment: "")
        titleLabel.textColor = .blackYP
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        return titleLabel
    }()
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundYP
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK: - Life View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteYP
        setUpViewController()
        showCheckMark()
    }

    // MARK: - UI Setup
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        setupConstraints()
    }
    
    // MARK: - Private methods
    private func showCheckMark() {
        if let selectedFilterIndex = selectedFilterIndex {
            let indexPath = IndexPath(row: selectedFilterIndex, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
                cell.checkmarkImageView.isHidden = false
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryTableViewCell else {
            return CategoryTableViewCell()
        }
        let filter = filters[indexPath.row]
        cell.configCell(text: filter)
        
        cell.selectionStyle = .none
        
        if indexPath.row == selectedFilterIndex {
            cell.checkmarkImageView.isHidden = false
        } else {
            cell.checkmarkImageView.isHidden = true
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilterIndex = indexPath.row
        guard let selectedFilter = TrackerFilter(rawValue: filters[indexPath.row]) else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else { return }
        cell.selectionStyle = .none
        cell.checkmarkImageView.isHidden = false
    
        dismiss(animated: true) {
            self.delegate?.didSelectFilter(selectedFilter)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else { return }
        cell.selectionStyle = .none
        cell.checkmarkImageView.isHidden = true
    }
}
