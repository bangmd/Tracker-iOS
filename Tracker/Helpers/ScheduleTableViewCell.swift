import UIKit

final class ScheduleTableViewCell: UITableViewCell{
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackYP
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let switchView: UISwitch = {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .blueYP
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .backgroundYP
        contentView.addSubview(label)
        contentView.addSubview(switchView)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(text: String){
        label.text = text
    }
}
