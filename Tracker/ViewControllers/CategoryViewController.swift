import UIKit

final class CategoryViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addTitle()
        addCreateNewCategoryButton()
        addStubItem()
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .blackYP
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func addTitle(){
       
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
    }
    
    func addCreateNewCategoryButton(){
        let newCategoryButton = UIButton(type: .custom)
        newCategoryButton.setTitle("Добавить категорию", for: .normal)
        newCategoryButton.backgroundColor = .blackYP
        newCategoryButton.layer.cornerRadius = 16
        newCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        newCategoryButton.titleLabel?.textAlignment = .center
        
        view.addSubview(newCategoryButton)
        newCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newCategoryButton.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 680),
            newCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        newCategoryButton.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
    }
    
    private lazy var stubImageView: UIImageView = {
        var stubImageView = UIImageView(image: UIImage(named: "stubImage"))
        view.addSubview(stubImageView)
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
        view.addSubview(stubLabel)
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
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
    
    private func removeStubItem() {
        stubImageView.removeFromSuperview()
        stubLabel.removeFromSuperview()
    }
    
//    private func updateStubUI(){
//        if categories.isEmpty{
//            addStubItem()
//        }else{
//            removeStubItem()
//        }
//    }
    
    @objc
    private func newCategoryButtonTapped(){
        //let newHabitViewController = NewHabitViewController()
       //newHabitViewController.delegate = self
        //present(newHabitViewController, animated: true)
    }
}
