import UIKit

final class EditCategoryViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Public Properties
    var onSave: ((String) -> Void)?
    private var currentCategoryName: String 
    
    // MARK: - Инициализация с передачей текущего названия категории
    init(categoryName: String) {
        self.currentCategoryName = categoryName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Редактирование категории"
        titleLabel.textColor = .blackYP
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        return titleLabel
    }()
    
    private lazy var textField: UITextField = {
        var textField = PaddedTextField()
        textField.placeholder = "Введите название категории"
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
    
    private lazy var saveButton: UIButton = {
        var saveButton = UIButton(type: .system)
        saveButton.setTitle("Готово", for: .normal)
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
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        textField.text = currentCategoryName
        checkDataForButton()
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
        view.addSubview(titleLabel)
        view.addSubview(textField)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 34),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 489),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addSubviews()
        addConstraints()
    }
    
    func checkDataForButton(){
        let isTextFieldFilled = !(textField.text?.isEmpty ?? true)
        
        let allFieldsValid = isTextFieldFilled
        if allFieldsValid {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .blackYP
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .grayYP
        }
    }
    
    // MARK: - Private Methods
    @objc
    private func saveButtonTapped() {
        guard let updatedCategoryName = textField.text, !updatedCategoryName.isEmpty else {
            presentAlert(title: "Ошибка", message: "Название категории не может быть пустым.")
            return
        }
        onSave?(updatedCategoryName)
        NotificationCenter.default.post(name: NSNotification.Name("CategoryUpdated"), object: nil)
        dismiss(animated: true)
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
