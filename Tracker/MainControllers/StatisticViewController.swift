import UIKit

final class StatisticViewController: UIViewController {
    // MARK: - Private Properties
    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: Set<TrackerRecord> = []

    private lazy var stubImageView: UIImageView = {
        var stubImageView = UIImageView(image: UIImage(named: "statisticStub"))
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    private lazy var stubLabel: UILabel = {
        var stubLabel = UILabel()
        stubLabel.text = NSLocalizedString("statisticStubLabel", comment: "")
        stubLabel.numberOfLines = 2
        stubLabel.textAlignment = .center
        stubLabel.lineBreakMode = .byWordWrapping
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = .blackYP
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
    private lazy var completedTrackersCard: StatCardView = {
        let card = StatCardView(number: 0, title: NSLocalizedString("trackersEnd", comment: ""))
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    // MARK: - Life View Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatistics), name: .didUpdateStatistics, object: nil)
        updateStatistics()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .didUpdateStatistics, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        loadStatistics()
    }
    
    // MARK: - Setup Methods
    @objc
    private func updateStatistics() {
        completedTrackers = trackerRecordStore.fetchAllCompletedTrackers()
        
        if completedTrackers.isEmpty {
            showStubItem()
        } else {
            removeStubItem()
            completedTrackersCard.configValue(value: completedTrackers.count)
        }
    }
    
    private func setUpViewController() {
        view.backgroundColor = .whiteYP
        self.title = NSLocalizedString("statisticTitle", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(completedTrackersCard)
        
        addConstraints()
        showStubItem()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            completedTrackersCard.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            completedTrackersCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completedTrackersCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completedTrackersCard.heightAnchor.constraint(equalToConstant: 100),
            
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor),
            stubLabel.widthAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    private func showStubItem() {
        stubImageView.isHidden = false
        stubLabel.isHidden = false
        completedTrackersCard.isHidden = true
    }
    
    private func removeStubItem() {
        stubImageView.isHidden = true
        stubLabel.isHidden = true
        completedTrackersCard.isHidden = false
    }
    
    // MARK: - Data Processing
    private func loadStatistics() {
        updateStatistics()
    }
}

