import UIKit

final class AddNewCategoryViewController: UIViewController, UITextFieldDelegate{
    // MARK: - Public Properties
    var onSave: ((String) -> Void)?
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Новая категория"
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
    private func saveButtonTapped(){
        guard let categoryName = textField.text, !categoryName.isEmpty else {
            presentAlert(title: "Ошибка", message: "Название категории не может быть пустым.")
            return
        }
        
        onSave?(categoryName)
        dismiss(animated: true)
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

