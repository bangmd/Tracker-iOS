import UIKit

// MARK: - Protocols
protocol NewHabitViewControllerDelegate: AnyObject{
    func didCreateNewTracker(_ tracker: Tracker, _ category: String)
}

protocol ViewSetupProtocol {
    func addSubviews()
    func addConstraints()
}

final class NewHabitViewController: UIViewController, UITextFieldDelegate, ViewSetupProtocol{
    // MARK: - Public Properties
    let tableInformation = ["Категория", "Расписание"]
    var selectedDays: Set<DayOfWeeks> = []
    weak var delegate: NewHabitViewControllerDelegate?
    let emojis = ["😊", "😍", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    let colors: [UIColor] = [._1, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, ._10, ._11, ._12, ._13, ._14, ._15, ._16, ._17, ._18]
    
    // MARK: - Private Properties
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategory: TrackerCategory?
    private var selectedDaysString: String = ""
    
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
        textField.textColor = .blackYP
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
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
    
    private lazy var collectionStackView: UIStackView = {
        let collectionStackView = UIStackView(arrangedSubviews: [emojiCollectionView, colorCollectionView])
        collectionStackView.axis = .vertical
        view.addSubview(collectionStackView)
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false
        collectionStackView.distribution = .fillEqually
        collectionStackView.spacing = 0
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        var saveButton = UIButton(type: .system)
        saveButton.setTitle("Создать", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.setTitleColor(.whiteYP, for: .normal)
        saveButton.isEnabled = false
        saveButton.backgroundColor = saveButton.isEnabled ? .blackYP : .grayYP
        saveButton.layer.cornerRadius = 16
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return saveButton
    }()
    
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
    
    private lazy var emojiCollectionView: UICollectionView = {
        var emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        emojiCollectionView.isScrollEnabled = false
        emojiCollectionView.backgroundColor = .none
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollectionView.register(EmojiHeaderCollectionView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: "header")
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return emojiCollectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        colorCollectionView.isScrollEnabled = false
        colorCollectionView.backgroundColor = .none
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        colorCollectionView.register(EmojiHeaderCollectionView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: "header")
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return colorCollectionView
    }()
    
    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        var contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    // MARK: - Public methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkDataForButton()
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(stackView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 34),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),

            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 20),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addSubviews()
        addConstraints()
    }
    
    func checkDataForButton(){
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let areDaysSelected = !selectedDays.isEmpty
        let isTextFieldFilled = !(textField.text?.isEmpty ?? true)
        let isCategoryFilled = !(selectedCategory?.title.isEmpty ?? true)
        
        let allFieldsValid = isEmojiSelected && isColorSelected && areDaysSelected && isTextFieldFilled && isCategoryFilled
        if allFieldsValid {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .blackYP
        }else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .grayYP
        }
    }
    
    // MARK: - Private Methods
    @objc
    private func saveButtonTapped(){
        let newTracker = Tracker(id: UUID(),
                                 title: textField.text ?? "",
                                 color: selectedColor ?? .whiteYP,
                                 emoji: selectedEmoji ?? "",
                                 schedule: selectedDays,
                                 type: .habit)
    
        delegate?.didCreateNewTracker(newTracker, selectedCategory?.title ?? "")
        
        if let rootViewController = self.view.window?.rootViewController{
            rootViewController.dismiss(animated: true)
        }
    }
    
    @objc
    private func cancelButtonTapped(){
        if let rootViewController = self.view.window?.rootViewController{
            rootViewController.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerTableCell else {
            return TrackerTableCell()
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.configCell(text: tableInformation[indexPath.row], image: UIImage(named: "backward"))
        
        if /*cell.secondLabel.isHidden == true &&*/ indexPath.row == 0{
            cell.selectionStyle = .none
            
            let secondText = selectedCategory?.title ?? "Выберите категорию"
            cell.configCell(text: tableInformation[indexPath.row], secondText: secondText, image: UIImage(named: "backward"))
        } else if indexPath.row == 1{
            cell.selectionStyle = .none
            
            let sortedSelectedDays = selectedDays.sorted {
                guard let firstIndex = DayOfWeeks.allCases.firstIndex(of: $0),
                      let secondIndex = DayOfWeeks.allCases.firstIndex(of: $1) else {
                    return false
                }
                return firstIndex < secondIndex
            }
            
            var secondText = ""
            
            if sortedSelectedDays.count >= 7{
                secondText = "Каждый день"
            } else {
                secondText  = sortedSelectedDays.map({ $0.shortName }).joined(separator: ", ")
            }
            
            cell.configCell(text: tableInformation[indexPath.row], secondText: secondText, image: UIImage(named: "backward"))
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let categoryViewController = CategoriesViewController(viewModel: CategoriesViewModel())
            present(categoryViewController, animated: true)
            
            categoryViewController.onSaveCategory = {[weak self] newCategory in
                guard let self = self else { return }
                self.selectedCategory = TrackerCategory(title: newCategory, trackers: [])
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TrackerTableCell
                cell?.showSecondLabel()
                tableView.reloadData()
                checkDataForButton()
            }
        }else if indexPath.row == 1{
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TrackerTableCell else { return }
            cell.selectionStyle = .none
            
            let sortedSelectedDays = selectedDays.sorted {
                guard let firstIndex = DayOfWeeks.allCases.firstIndex(of: $0),
                      let secondIndex = DayOfWeeks.allCases.firstIndex(of: $1) else {
                    return false
                }
                return firstIndex < secondIndex
            }
            
            var secondText = ""
            
            if sortedSelectedDays.count >= 7{
                secondText = "Каждый день"
            } else {
                secondText  = sortedSelectedDays.map({ $0.shortName }).joined(separator: ", ")
            }
            
            cell.configCell(text: tableInformation[indexPath.row], secondText: secondText, image: UIImage(named: "backward"))
        }
    }
}

// MARK: - ScheduleViewControllerProtocol
extension NewHabitViewController: ScheduleViewControllerProtocol{
    func didUpdateSelectedDays(_ selectedDays: Set<DayOfWeeks>) {
        self.selectedDays = selectedDays
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TrackerTableCell
        cell?.showSecondLabel()
        tableView.reloadData()
        checkDataForButton()
    }
}

//MARK: EmojiCollectionView DataSource
extension NewHabitViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView{
            return emojis.count
        } else if collectionView == colorCollectionView{
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionViewCell else {
                return EmojiCollectionViewCell()
            }
            cell.configureCell(emoji: emojis[indexPath.row])
            return cell
        }else if collectionView == colorCollectionView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCollectionViewCell else {
                return ColorCollectionViewCell()
            }
            cell.setColorToCell(color: colors[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojiCollectionView{
            guard kind == UICollectionView.elementKindSectionHeader else {
                fatalError("Unexpected element kind")
            }
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? EmojiHeaderCollectionView else {
                return EmojiHeaderCollectionView()
            }
            headerView.label.text = "Emoji"
            
            return headerView
        }else if collectionView == colorCollectionView{
            guard kind == UICollectionView.elementKindSectionHeader else {
                fatalError("Unexpected element kind")
            }
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? EmojiHeaderCollectionView else {
                return EmojiHeaderCollectionView()
            }
            headerView.label.text = "Цвет"
            
            return headerView
        }
        return UICollectionReusableView()
    }
}

//MARK: EmojiCollectionView UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 19, bottom: 0, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 52, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath) {
                selectedEmoji = emojis[indexPath.item]
                cell.layer.cornerRadius = 16
                cell.backgroundColor = .backgroundYP
                checkDataForButton()
            }
        }else if collectionView == colorCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath){
                selectedColor = colors[indexPath.item]
                cell.layer.borderWidth = 3
                cell.layer.cornerRadius = 8
                cell.layer.borderColor = selectedColor?.withAlphaComponent(0.3).cgColor
                checkDataForButton()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath){
                cell.layer.cornerRadius = 0
                cell.backgroundColor = .clear
            }
        }else if collectionView == colorCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath){
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 0
                cell.layer.borderColor = .none
            }
        }
    }
}
