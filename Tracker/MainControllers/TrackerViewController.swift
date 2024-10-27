import UIKit

final class TrackerViewController: UIViewController, AddNewTrackerViewControllerDelegate, NewHabitViewControllerDelegate, NewIrregularEventViewControllerDelegate{
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers = Set<TrackerRecord>()
    var filteredCategories: [TrackerCategory] = []
    var currentDate = Date()
    let trackerStore = TrackerStore()
    let trackerCategoryStore = TrackerCategoryStore()
    let trackerRecordStore = TrackerRecordStore()
    var pinnedTrackers: Set<UUID> = []
    
    
    // MARK: - Private Properties
    private let analyticsService = Analytics()
    private var currentFilter: TrackerFilter = .allTrackers
    private let filters: [TrackerFilter] = [.allTrackers, .todayTrackers, .completedTrackers, .incompleteTrackers]

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("trackerTitle", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .blackYP
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        return titleLabel
    }()
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "plusLogo"), for: .normal)
        plusButton.tintColor = .blackYP
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        return plusButton
    }()
    
    private lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .whiteYP
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
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
    
    private lazy var filterButton: UIButton = {
        var filterButton = UIButton(type: .system)
        filterButton.setTitle(NSLocalizedString("Filters", comment: ""), for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.backgroundColor = .blueYP
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filterButton.layer.cornerRadius = 16
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return filterButton
    }()
    
    private lazy var searchController: UISearchBar = {
        var searchController = UISearchBar()
        searchController.placeholder = NSLocalizedString("search", comment: "")
        searchController.backgroundImage = UIImage()
        searchController.delegate = self
        searchController.showsCancelButton = false
        view.addSubview(searchController)
        searchController.translatesAutoresizingMaskIntoConstraints = false
        return searchController
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
        stubLabel.text = NSLocalizedString("stubLabelText", comment: "")
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = .blackYP
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
    private var stubImageViewForSearch: UIImageView = {
        var stubImageView = UIImageView(image: UIImage(named: "stubImageSearch"))
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    private var stubLabelForSearch: UILabel = {
        var stubLabel = UILabel()
        stubLabel.text = NSLocalizedString("stubLabelTextSearch", comment: "")
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
        analyticsService.report(event: "open", params:  ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    // MARK: - Public Methods
    func configView(){
        view.backgroundColor = .whiteYP
        addConstraints()
        addDatePicker()
    }
    
    func addConstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plusButton.heightAnchor.constraint(equalToConstant: 18),
            plusButton.widthAnchor.constraint(equalToConstant: 19),
            
            searchController.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchController.bottomAnchor, constant: 34),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -131),
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
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
        
        let pinnedTrackersList = categories.flatMap { category in
            category.trackers.filter { tracker in
                tracker.isPinned && tracker.schedule.contains(dayOfWeek)
            }
        }

        if !pinnedTrackersList.isEmpty {
            filteredCategories.append(TrackerCategory(title: "Закрепленные", trackers: pinnedTrackersList))
        }
        
        for category in categories {
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackers {
                if !tracker.isPinned {
                    switch tracker.type {
                    case .habit:
                        if tracker.schedule.contains(dayOfWeek) {
                            filteredTrackers.append(tracker)
                        }
                    case .oneTimeEvent:
                        if calendar.isDate(date, inSameDayAs: Date()) {
                            let record = TrackerRecord(idTracker: tracker.id, date: date)
                            if !completedTrackers.contains(record) {
                                filteredTrackers.append(tracker)
                            }
                        }
                    }
                }
            }
            
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        
        self.filteredCategories = filteredCategories
        updateStubUI()
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
    
    func didCreateNewIrregularEvent(_ tracker: Tracker, _ category: String) {
        trackerStore.updateTracker(tracker, newCategory: category)
        fetchCategory()
        filteredTracker(for: datePicker.date)
        collectionView.reloadData()
        updateStubUI()
    }
        
    func didCreateNewTracker(_ tracker: Tracker, _ newCategory: String) {
        trackerStore.updateTracker(tracker, newCategory: newCategory)
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
    
    func addStubItemForSearch(){
        view.addSubview(stubImageViewForSearch)
        view.addSubview(stubLabelForSearch)
        
        NSLayoutConstraint.activate([
            stubImageViewForSearch.widthAnchor.constraint(equalToConstant: 80),
            stubImageViewForSearch.heightAnchor.constraint(equalToConstant: 80),
            stubImageViewForSearch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageViewForSearch.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubLabelForSearch.topAnchor.constraint(equalTo: stubImageViewForSearch.bottomAnchor, constant: 8),
            stubLabelForSearch.centerXAnchor.constraint(equalTo: stubImageViewForSearch.centerXAnchor)
        ])
    }
    
    func removeStubItemForSearch() {
        stubImageViewForSearch.removeFromSuperview()
        stubLabelForSearch.removeFromSuperview()
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
        currentDate = selectedDate
        applyFilter(currentFilter, for: selectedDate)
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
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        let newTrackerViewController = AddNewTrackerViewController()
        newTrackerViewController.delegate = self
        present(newTrackerViewController, animated: true, completion: nil)
    }
    
    @objc
    private func filterButtonTapped(){
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        if let index = filters.firstIndex(of: currentFilter) {
            filterViewController.selectedFilterIndex = index
        }
        present(filterViewController, animated: true, completion: nil)
    }
    
    private func removeStubItem() {
        stubImageView.removeFromSuperview()
        stubLabel.removeFromSuperview()
    }

    private func updateStubUI() {
        let hasAnyTrackers = hasTrackers(for: currentDate)
        let hasFilteredTrackers = !filteredCategories.isEmpty

        if !hasAnyTrackers {
            filterButton.isHidden = true
            addStubItem()
            removeStubItemForSearch()
        } else {
            filterButton.isHidden = false
            
            if !hasFilteredTrackers {
                addStubItemForSearch()
                removeStubItem()
            } else {
                removeStubItemForSearch()
                removeStubItem()
            }
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
        
        let isDone = completedTrackers.contains { completedRecord in
            completedRecord.idTracker == tracker.id && Calendar.current.isDate(completedRecord.date, inSameDayAs: datePicker.date)
        }
        let totalCompletedCount = completedTrackers.filter { $0.idTracker == tracker.id }.count
        
        cell.updateDayCounter(totalCompletedCount: totalCompletedCount)
        cell.updateCellStatus(isDone: isDone)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let isPinned = trackerStore.fetchCoreDataTracker(by: tracker.id)?.isPinned ?? false
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pinAction = UIAction(
                title: isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: ""),
                image: UIImage(systemName: isPinned ? "pin.slash" : "pin")) { action in
                    self.togglePinTracker(at: indexPath)
                }
            
            let editAction = UIAction(title: NSLocalizedString("editAction", comment: ""), image: UIImage(systemName: "pencil")) { action in
                self.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("deleteActionTitle", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.deleteTrackerConfirmation(by: tracker.id)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    private func togglePinTracker(at indexPath: IndexPath) {
        var tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

        if tracker.isPinned {
            tracker.isPinned = false
            tracker.datePinned = nil
        } else {
            tracker.isPinned = true
            tracker.datePinned = currentDate
        }

        if let coreDataTracker = trackerStore.fetchCoreDataTracker(by: tracker.id) {
            coreDataTracker.isPinned = tracker.isPinned
            coreDataTracker.datePinned = tracker.datePinned
            trackerStore.saveContext()
        }

        fetchCategory()
        filteredTracker(for: currentDate)
        collectionView.reloadData()
    }

    func editTracker(at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        if tracker.type == .habit {
            let editViewController = NewHabitViewController(trackerToEdit: tracker)
            editViewController.delegate = self
            present(editViewController, animated: true, completion: nil)
        } else if tracker.type == .oneTimeEvent {
            let editViewController = NewIrregularEventViewController(trackerToEdit: tracker)
            editViewController.delegate = self
            present(editViewController, animated: true, completion: nil)
        }
    }

    private func deleteTrackerConfirmation(by id: UUID) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        let alertController = UIAlertController(title: NSLocalizedString("deleteTrackerAction", comment: ""), message: NSLocalizedString("deleteTrackerTextAction", comment: ""), preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("deleteActionTitle", comment: ""), style: .destructive) { [weak self] _ in
            self?.deleteTracker(by: id)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .cancel)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func deleteTracker(by id: UUID) {
        guard let trackerCoreData = trackerStore.fetchCoreDataTracker(by: id) else {
            print("Трекер с ID \(id) не найден")
            return
        }
        trackerStore.deleteTracker(trackerCoreData)
        pinnedTrackers.remove(id)
        
        if let indexPath = getIndexPathForTracker(id: id) {
            let categoryTitle = filteredCategories[indexPath.section].title
            if let originalCategoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
                categories[originalCategoryIndex].trackers.removeAll(where: { $0.id == id })
                if categories[originalCategoryIndex].trackers.isEmpty {
                    categories.remove(at: originalCategoryIndex)
                }
            }
            filteredCategories[indexPath.section].trackers.remove(at: indexPath.row)
            if filteredCategories[indexPath.section].trackers.isEmpty {
                filteredCategories.remove(at: indexPath.section)
                collectionView.deleteSections(IndexSet(integer: indexPath.section))
            } else {
                collectionView.deleteItems(at: [indexPath])
            }
        }
        collectionView.reloadData()
        updateStubUI()
    }
    
    private func getIndexPathForTracker(id: UUID) -> IndexPath? {
        for section in 0..<filteredCategories.count {
            if let row = filteredCategories[section].trackers.firstIndex(where: { $0.id == id }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
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
            NotificationCenter.default.post(name: .didUpdateStatistics, object: nil)
        } else {
            completedTrackers.insert(record)
            trackerRecordStore.addNewRecord(from: record)
            NotificationCenter.default.post(name: .didUpdateStatistics, object: nil)
            
            if tracker.type == .oneTimeEvent && calendar.isDate(selectedDate, inSameDayAs: currentDate) {
                category.trackers.remove(at: indexPath.row)
                updateStubUI()
                
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

extension TrackerViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        removeStubItem()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTracker(for: currentDate)
        } else {
            filteredCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(searchText.lowercased())
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        filteredCategories.isEmpty ? addStubItemForSearch() : removeStubItemForSearch()
        collectionView.reloadData()
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredTracker(for: datePicker.date)
        collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        removeStubItemForSearch()
    }
}

// MARK: - Filter processing
extension TrackerViewController{
    func filterCompletedTrackers(for date: Date) {
        let calendar = Calendar.current
        var completedCategories: [TrackerCategory] = []
        for category in categories {
            let completedTrackersInCategory = category.trackers.filter { tracker in
                completedTrackers.contains { (record: TrackerRecord) in
                    record.idTracker == tracker.id && calendar.isDate(record.date, inSameDayAs: date)
                }
            }
            if !completedTrackersInCategory.isEmpty {
                completedCategories.append(TrackerCategory(title: category.title, trackers: completedTrackersInCategory))
            }
        }
        self.filteredCategories = completedCategories
        updateStubUI()
        collectionView.reloadData()
    }
    
    func filterIncompleteTrackers(for date: Date) {
        let calendar = Calendar.current
        var incompleteCategories: [TrackerCategory] = []
        for category in categories {
            let incompleteTrackers = category.trackers.filter { tracker in
                let isCompleted = completedTrackers.contains { completedRecord in
                    completedRecord.idTracker == tracker.id && calendar.isDate(completedRecord.date, inSameDayAs: date)
                }
                
                let shouldDisplay = tracker.type == .habit
                    ? tracker.schedule.contains(DayOfWeeks.from(weekday: calendar.component(.weekday, from: date))!)
                    : true
                return !isCompleted && shouldDisplay
            }
            if !incompleteTrackers.isEmpty {
                incompleteCategories.append(TrackerCategory(title: category.title, trackers: incompleteTrackers))
            }
        }

        self.filteredCategories = incompleteCategories
        updateStubUI()
        collectionView.reloadData()
    }
    
    private func hasTrackers(for date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        guard let dayOfWeek = DayOfWeeks.from(weekday: weekday) else { return false }

        return categories.contains { category in
            category.trackers.contains { tracker in
                if tracker.type == .habit {
                    return tracker.schedule.contains(dayOfWeek)
                } else if tracker.type == .oneTimeEvent {
                    return calendar.isDate(currentDate, inSameDayAs: date)
                }
                return false
            }
        }
    }
    
    private func applyTodayFilter() {
        let today = Date()
        currentDate = today
        datePicker.date = today
        filteredTracker(for: today)
        updateStubUI()
    }

    private func applyFilter(_ filter: TrackerFilter?, for date: Date) {
        guard let filter = filter else {
            filteredTracker(for: date)
            updateStubUI()
            return
        }

        switch filter {
        case .allTrackers:
            filteredTracker(for: date)
        case .todayTrackers:
            if Calendar.current.isDate(currentDate, inSameDayAs: Date()) {
                filteredTracker(for: currentDate)
                currentFilter = .allTrackers
                updateStubUI()
            } else {
                applyTodayFilter()
                currentFilter = .allTrackers
            }
        case .completedTrackers:
            filterCompletedTrackers(for: date)
        case .incompleteTrackers:
            filterIncompleteTrackers(for: date)
        }
        updateStubUI()
    }
}

// MARK: - FilterViewControllerDelegate
extension TrackerViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        applyFilter(currentFilter, for: datePicker.date)
    }
}

extension Notification.Name {
    static let didUpdateStatistics = Notification.Name("didUpdateStatistics")
}


