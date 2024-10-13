import UIKit

final class CategoriesViewController: UIViewController{
    var onSaveCategory: ((String) -> Void)?
    
    // MARK: - Private Properties
    private let viewModel: CategoriesViewModel
    
    private lazy var label: UILabel = {
        var label = UILabel()
        label.text = "Категория"
        label.textColor = .blackYP
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .whiteYP
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var newCategoryButton: UIButton = {
        var newCategoryButton = UIButton(type: .custom)
        newCategoryButton.setTitle("Добавить категорию", for: .normal)
        newCategoryButton.backgroundColor = .blackYP
        newCategoryButton.layer.cornerRadius = 16
        newCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        newCategoryButton.titleLabel?.textAlignment = .center
        newCategoryButton.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        newCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        return newCategoryButton
    }()
    
    private lazy var stubImageView: UIImageView = {
        var stubImageView = UIImageView(image: UIImage(named: "stubImage"))
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    private lazy var stubLabel: UILabel = {
        var stubLabel = UILabel()
        stubLabel.text = "Привычки и события можно объединить по смыслу"
        stubLabel.numberOfLines = 2
        stubLabel.textAlignment = .center
        stubLabel.lineBreakMode = .byWordWrapping
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = .blackYP
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
    // MARK: - Init
    init(viewModel: CategoriesViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindViewModel()
        updateStubUI()
    }
    
    // MARK: - Setup Methods
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addSubviews()
        addConstraints()
        addStubItem()
    }
    
    func addSubviews(){
        view.addSubview(label)
        view.addSubview(tableView)
        view.addSubview(newCategoryButton)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
    }
    
    func addConstraints(){
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
        
        NSLayoutConstraint.activate([
            newCategoryButton.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 680),
            newCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -10)
        ])
    }
    
    func addStubItem(){
        NSLayoutConstraint.activate([
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 232),
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor),
            stubLabel.widthAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    // MARK: - Private methods
    private func removeStubItem() {
        stubImageView.isHidden = true
        stubLabel.isHidden = true
    }
    
    private func showStubItem(){
        stubImageView.isHidden = false
        stubLabel.isHidden = false
    }
    
    private func updateStubUI(){
        if viewModel.numbersOfCategories == 0{
            showStubItem()
        }else{
            removeStubItem()
        }
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc
    private func newCategoryButtonTapped(){
        let addVC = AddNewCategoryViewController()
        show(addVC, sender: nil)
        
        addVC.onSave = { [weak self] newCategory in
            self?.viewModel.addCategory(title: newCategory)
            self?.tableView.reloadData()
            self?.updateStubUI()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryTableViewCell else {
            return CategoryTableViewCell()
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        if tableView.indexPathForSelectedRow == indexPath {
            cell.checkmarkImageView.isHidden = false
        } else {
            cell.checkmarkImageView.isHidden = true
        }
        
        cell.configCell(text: viewModel.categoryTitle(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else { return }
        
        for visibleCell in tableView.visibleCells {
            if let visibleCategoryCell = visibleCell as? CategoryTableViewCell {
                visibleCategoryCell.checkmarkImageView.isHidden = true
            }
        }
        
        cell.selectionStyle = .none
        cell.checkmarkImageView.isHidden = false
        onSaveCategory?(viewModel.categoryTitle(at: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else { return }
        cell.selectionStyle = .none
        cell.checkmarkImageView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == numberOfRows - 1 {
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            return self.makeContextMenu(for: indexPath)
        }
    }
    
    private func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] action in
            self?.editCategory(at: indexPath)
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            self?.showDeleteConfirmation(at: indexPath)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        viewModel.deleteCategory(at: indexPath.row)
        viewModel.numbersOfCategories == 0 ? onSaveCategory?("Выберите категорию") : nil
        NotificationCenter.default.post(name: NSNotification.Name("CategoryUpdated"), object: nil)
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.updateStubUI()
        }
    }
    
    private func showDeleteConfirmation(at indexPath: IndexPath){
        let alert = UIAlertController(title: nil,
                                      message: "Эта категория точно не нужна?",
                                      preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.deleteCategory(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func editCategory(at indexPath: IndexPath) {
        let categoryTitle = viewModel.categoryTitle(at: indexPath.row)
        let editVC = EditCategoryViewController(categoryName: categoryTitle)
        
        editVC.onSave = { [weak self] updatedCategoryName in
            self?.viewModel.updateCategory(at: indexPath.row, with: updatedCategoryName)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        present(editVC, animated: true)
    }
}
