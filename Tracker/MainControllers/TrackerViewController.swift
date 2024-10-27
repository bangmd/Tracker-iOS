import UIKit

final class TrackerViewController: UIViewController, AddNewTrackerViewControllerDelegate{
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers = Set<TrackerRecord>()
    var filteredCategories: [TrackerCategory] = []
    var currentDate = Date()
    let trackerStore = TrackerStore()
    let trackerCategoryStore = TrackerCategoryStore()
    let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Private Properties
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
    
    private var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        return datePicker
    }()
    
    private var stubImageView: UIImageView = {
        var stubImageView = UIImageView(image: UIImage(named: "stubImage"))
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    private var stubLabel: UILabel = {
        var stubLabel = UILabel()
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = .blackYP
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        fetchCategory()
        fetchCompletedTrackers()
        filteredTracker(for: currentDate)
        updateStubUI()
        collectionView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategories), name: NSNotification.Name("CategoryUpdated"), object: nil)
    }
    
    // MARK: - Public Methods
    func configView(){
        view.backgroundColor = .whiteYP
        addCollectionViewConstraints()
        addPlusLogo()
        addTitleLabelToView()
        addDatePicker()
    }
    
    func addCollectionViewConstraints(){
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 153),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
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
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackers {
                switch tracker.type {
                case .habit:
                    if tracker.schedule.contains(dayOfWeek) == true {
                        filteredTrackers.append(tracker)
                    }
                case .oneTimeEvent:
                    if calendar.isDate(date, inSameDayAs: currentDate) {
                        let record = TrackerRecord(idTracker: tracker.id, date: date)
                        
                        if !completedTrackers.contains(record) {
                            filteredTrackers.append(tracker)
                        }
                    }
                }
            }
            
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        self.filteredCategories = filteredCategories
        collectionView.reloadData()
    }
    
    func didAddNewTracker(_ tracker: Tracker, _ category: String) {
        if trackerCategoryStore.fetchAllCategories().filter({ $0.title == category}).count == 0 {
            let newCategory = TrackerCategory(title: category, trackers: [])
            trackerCategoryStore.createCategory(newCategory)
        }
        
        createCategoryAndTracker(tracker: tracker, with: category)
        fetchCategory()
    
        filteredTracker(for: datePicker.date)
        collectionView.reloadData()
        updateStubUI()
    }
    
    func addStubItem(){
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        
        NSLayoutConstraint.activate([
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor)
        ])
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Private Methods
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker){
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        filteredTracker(for: selectedDate)
        collectionView.reloadData()
        updateStubUI()
    }
    
    private func addTracker(_ tracker: Tracker, _ categoryName: String){
        var newCategories = categories
        if let index = newCategories.firstIndex(where: { $0.title == categoryName }) {
            newCategories[index].trackers.append(tracker)
        }else{
            let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
            newCategories.append(newCategory)
        }
        categories = newCategories
    }
    
    private func addPlusLogo(){
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "plusLogo"), for: .normal)
        plusButton.tintColor = .blackYP
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        
        plusButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 19).isActive = true
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    private func fetchCategory() {
        let coreDataCategories = trackerCategoryStore.fetchAllCategories()
        categories = coreDataCategories.compactMap { coreDataCategory in
            let decodedCategory = trackerCategoryStore.decodingCategory(from: coreDataCategory)
            return decodedCategory
        }
    }

    private func fetchCompletedTrackers(){
        completedTrackers = trackerRecordStore.fetchAllCompletedTrackers()
    }
    
    private func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: titleCategory)
    }
    
    @objc
    private func plusButtonTapped(){
        let newTrackerViewController = AddNewTrackerViewController()
        newTrackerViewController.delegate = self
        present(newTrackerViewController, animated: true, completion: nil)
    }
    
    private func addTitleLabelToView(){
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .blackYP
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
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
    
    @objc
    private func updateCategories() {
        fetchCategory()
        fetchCompletedTrackers()
        filteredTracker(for: currentDate)
        updateStubUI()
        collectionView.reloadData()
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CategoryUpdated"), object: nil)
    }
}

// MARK: - UICollectionViewDataSource
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
        let record = TrackerRecord(idTracker: tracker.id, date: datePicker.date)
        
        let isDone = completedTrackers.contains { completedRecord in
            completedRecord.idTracker == tracker.id && Calendar.current.isDate(completedRecord.date, inSameDayAs: datePicker.date)
        }

        let totalCompletedCount = completedTrackers.filter { $0.idTracker == tracker.id }.count
        
        cell.updateDayCounter(totalCompletedCount: totalCompletedCount)
        cell.updateCellStatus(isDone: isDone)
        cell.setValueForCellItems(text: tracker.title, color: tracker.color, emojiText: tracker.emoji)
        
        if filteredCategories.isEmpty{
            
        }
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

// MARK: - UICollectionViewDelegateFlowLayout
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

// MARK: - TrackerCollectionViewCellProtocol
extension TrackerViewController: TrackerCollectionViewCellProtocol{
    func didTapPlusButton(in cell: TrackerCollectionViewCell) {
        let selectedDate = datePicker.date
        let formattedSelectedDate = formatDate(selectedDate)
        let formattedCurrentDate = formatDate(currentDate)
        
        guard let indexPath = collectionView.indexPath(for: cell), formattedSelectedDate <= formattedCurrentDate else { return }
        
        var category = filteredCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        let trackerID = tracker.id
        let record = TrackerRecord(idTracker: trackerID, date: selectedDate)
        let calendar = Calendar.current
        
        if let existingRecord = completedTrackers.first(where: { $0.idTracker == trackerID && calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            completedTrackers.remove(existingRecord)
            trackerRecordStore.removeRecord(for: existingRecord)
        } else {
            completedTrackers.insert(record)
            trackerRecordStore.addNewRecord(from: record)
            
            if tracker.type == .oneTimeEvent && calendar.isDate(selectedDate, inSameDayAs: currentDate) {
                category.trackers.remove(at: indexPath.row)
                
                if category.trackers.isEmpty {
                    filteredCategories.remove(at: indexPath.section)
                    collectionView.deleteSections(IndexSet(integer: indexPath.section))
                } else {
                    filteredCategories[indexPath.section] = category
                    collectionView.deleteItems(at: [indexPath])
                }
                
                if let coreDataTracker = trackerStore.fetchCoreDataTracker(by: tracker.id) {
                    trackerStore.deleteTracker(coreDataTracker)
                }
                
                if let originalCategoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
                    categories[originalCategoryIndex].trackers.removeAll(where: { $0.id == tracker.id })
                    
                    if categories[originalCategoryIndex].trackers.isEmpty {
                        categories.remove(at: originalCategoryIndex)
                    }
                }
                            
                return
            }
        }
        
        let isDone = completedTrackers.contains { $0.idTracker == trackerID && calendar.isDate($0.date, inSameDayAs: selectedDate) }
        let totalCompletedCount = completedTrackers.filter { $0.idTracker == tracker.id }.count
        
        cell.updateDayCounter(totalCompletedCount: totalCompletedCount)
        cell.updateCellStatus(isDone: isDone)
    }
}

