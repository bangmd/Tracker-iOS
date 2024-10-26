import UIKit

final class StatisticViewController: UIViewController{
    // MARK: - Private Properties
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
    
    // MARK: - Life View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        
        // Создаем UIStackView для карточек
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 16
                stackView.distribution = .fillEqually
                stackView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(stackView)
                
                // Данные для карточек
                let data = [
                    (number: 6, title: "Лучший период"),
                    (number: 2, title: "Идеальные дни"),
                    (number: 5, title: "Трекеров завершено"),
                    (number: 4, title: "Среднее значение")
                ]
                
                // Создаем и добавляем карточки в стек
                for item in data {
                    let statCard = StatCardView(number: item.number, title: item.title)
                    statCard.translatesAutoresizingMaskIntoConstraints = false
                    statCard.heightAnchor.constraint(equalToConstant: 100).isActive = true
                    stackView.addArrangedSubview(statCard)
                }
                
                // Устанавливаем констрейнты для стека
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                    stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
                ])
    }
    
    // MARK: - Setup Methods
    func setUpViewController(){
        view.backgroundColor = .whiteYP
        addSubviews()
        addConstraints()
        addStubItem()
        self.title = NSLocalizedString("statisticTitle", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func addSubviews(){
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
    }
    
    func addConstraints(){
//        NSLayoutConstraint.activate([
//            gradientBorderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            gradientBorderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            gradientBorderView.widthAnchor.constraint(equalToConstant: 343),
//            gradientBorderView.heightAnchor.constraint(equalToConstant: 90)
//        ])
    }
    
    func addStubItem(){
        NSLayoutConstraint.activate([
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
    
//    private func updateStubUI(){
//        if viewModel.numbersOfCategories == 0{
//            showStubItem()
//        }else{
//            removeStubItem()
//        }
//    }
    
    
}
