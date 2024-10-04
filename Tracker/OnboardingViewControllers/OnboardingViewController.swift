import UIKit

final class OnboardingViewController: UIViewController{
    // MARK: - Public Properties
    lazy var backgroundImage: UIImageView = {
        var backgroundImage = UIImageView()
        backgroundImage.contentMode = .scaleToFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImage
    }()
    
    lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.textColor = .blackYP
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    // MARK: - Private Properties
    private lazy var actionButton: UIButton = {
        var actionButton = UIButton(type: .system)
        actionButton.setTitle("Вот это технологии!", for: .normal)
        actionButton.setTitleColor(.whiteYP, for: .normal)
        actionButton.backgroundColor = .blackYP
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionButton.layer.cornerRadius = 16
        actionButton.addTarget(self, action: #selector(actionButtonDidTapped), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        return actionButton
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.frame = view.bounds
        addSubview()
        addConstraints()
    }
    
    // MARK: - Public Methods
    func addConstraints(){
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 388),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            actionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 624),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func addSubview(){
        view.addSubview(backgroundImage)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
    }
    
    // MARK: - Private Methods
    @objc
    private func actionButtonDidTapped(){
        UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
        let tabBarVC = TabBarViewController()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true, completion: nil)
    }
}
