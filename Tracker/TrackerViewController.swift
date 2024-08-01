import UIKit

final class TrackerViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func configView(){
        view.backgroundColor = .white
        addPlusLogo()
        addTitleLabelToView()
        addStubItem()
    }
    
    func addPlusLogo(){
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "plusLogo"), for: .normal)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        
        plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13).isActive = true
        plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 19).isActive = true
    }
    
    func addTitleLabelToView(){
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .blackYP
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    }
    
    func addStubItem(){
        let imageView = UIImageView(image: UIImage(named: "stubImage"))
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let stubLabel = UILabel()
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        view.addSubview(stubLabel)
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stubLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        stubLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
    }
}
