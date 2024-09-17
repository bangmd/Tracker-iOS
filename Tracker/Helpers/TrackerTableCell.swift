import UIKit

final class TrackerTableCell: UITableViewCell{
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackYP
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var secondLabel: UILabel = {
        var secondLabel = UILabel()
        secondLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        secondLabel.textColor = .grayYP
        secondLabel.isHidden = true
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        return secondLabel
    }()
    
    let backward: UIImageView = {
        let backward = UIImageView()
        backward.translatesAutoresizingMaskIntoConstraints = false
        return backward
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .backgroundYP
        contentView.addSubview(label)
        contentView.addSubview(secondLabel)
        contentView.addSubview(backward)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            
            backward.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backward.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26)
        ])
    }
    
    func showSecondLabel(){
        secondLabel.isHidden = false
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            secondLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            secondLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            
            backward.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backward.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(text: String, image: UIImage?){
        label.text = text
        backward.image = image
    }
    
    func configCell(text: String, secondText: String, image: UIImage?){
        label.text = text
        secondLabel.text = secondText
        backward.image = image
    }
}
