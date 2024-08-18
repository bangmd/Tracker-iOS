import UIKit

final class TrackerViewController: UIViewController, AddNewTrackerViewControllerDelegate{
    var categories: [TrackerCategory] = []
    var completedTrackers = Set<TrackerRecord>()
    var filteredCategories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        addStubItem()
    }
    
    func configView(){
        view.backgroundColor = .whiteYP
        addCollectionViewConstraints()
        addPlusLogo()
        addTitleLabelToView()
        addDatePicker()
    }
    
    private lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .whiteYP
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    func addCollectionViewConstraints(){
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 138),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        return datePicker
    }()
    
    func addDatePicker(){
        view.addSubview(datePicker)
        navigationController?.navigationBar.backgroundColor = .whiteYP
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func filteredTracker(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        guard let dayOfWeek = DayOfWeeks.from(weekday: weekday) else { return }
        
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { $0.schedule.contains(dayOfWeek) }
            
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        
        self.filteredCategories = filteredCategories
        collectionView.reloadData()
    }

    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker){
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        filteredTracker(for: selectedDate)
        collectionView.reloadData()
    }
    
    func addTracker(_ tracker: Tracker, _ categoryName: String){
        var newCategories = categories
        if let index = newCategories.firstIndex(where: { $0.title == categoryName }) {
            newCategories[index].trackers.append(tracker)
        }else{
            let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
            newCategories.append(newCategory)
        }
        categories = newCategories
    }
    
    
    func addPlusLogo(){
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "plusLogo"), for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        
        plusButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 19).isActive = true
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    func didAddNewTracker(tracker: Tracker) {
        addTracker(tracker, "Health")
        filteredTracker(for: datePicker.date)
        collectionView.reloadData()
        updateStubUI()
    }
    
    @objc
    func plusButtonTapped(){
        let newTrackerViewController = AddNewTrackerViewController()
        newTrackerViewController.delegate = self
        present(newTrackerViewController, animated: true, completion: nil)
    }
    
    func addTitleLabelToView(){
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .blackYP
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    }
    
    private lazy var stubImageView: UIImageView = {
        var stubImageView = UIImageView(image: UIImage(named: "stubImage"))
        view.addSubview(stubImageView)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    
    private lazy var stubLabel: UILabel = {
        var stubLabel = UILabel()
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = .blackYP
        view.addSubview(stubLabel)
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
    func addStubItem(){
        NSLayoutConstraint.activate([
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor)
        ])
    }
    
    private func removeStubItem() {
        stubImageView.removeFromSuperview()
        stubLabel.removeFromSuperview()
    }
    
    private func updateStubUI(){
        if filteredCategories.isEmpty{
            addStubItem()
        }else{
            removeStubItem()
        }
    }
}


extension TrackerViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell else {
            return TrackerCollectionViewCell()
        }
        cell.delegate = self
        
        let category = filteredCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        cell.updateCellStatus(with: tracker, for: datePicker.date)
        cell.setValueForCellItems(text: tracker.title, color: tracker.color, emojiText: tracker.emoji)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath) as! TrackerCategoryHeaderView
        
        let category = filteredCategories[indexPath.section]
        headerView.label.text = category.title
        
        return headerView
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 12, right: 0)
    }
    
}

extension TrackerViewController: TrackerCollectionViewCellProtocol{
    func updateCompletedTrackers(_ completedTrackers: Set<TrackerRecord>) {
        self.completedTrackers = completedTrackers
    }
    
    func didRequestDate() -> Date? {
        return datePicker.date
    }
    
    func completedTrackersData() -> Set<TrackerRecord>?{
        return completedTrackers
    }
}


