import UIKit

protocol TrackerCollectionViewCellProtocol: AnyObject{
    func didTapPlusButton(in cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell{
    weak var delegate: TrackerCollectionViewCellProtocol?
    var tracker: Tracker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
    }
    
    private lazy var backCellView: UIView = {
        var backCellView = UIView()
        contentView.addSubview(backCellView)
        backCellView.translatesAutoresizingMaskIntoConstraints = false
        backCellView.layer.cornerRadius = 16
        return backCellView
    }()
    
    private lazy var cellTitle: UILabel = {
        var cellTitle = UILabel()
        cellTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cellTitle.textColor = .whiteYP
        contentView.addSubview(cellTitle)
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        return cellTitle
    }()
    
    private lazy var backView: UIView = {
        var backView = UIView()
        backView.backgroundColor = .whiteYP.withAlphaComponent(0.3)
        backView.layer.cornerRadius = 11
        contentView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        return backView
    }()
    
    private lazy var emoji: UILabel = {
        var emoji = UILabel()
        emoji.font = UIFont.systemFont(ofSize: 16)
        backView.addSubview(emoji)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        return emoji
    }()
    
    private var counter: UInt8 = 0
    private lazy var dayCounter: UILabel = {
        var dayCounter = UILabel()
        dayCounter.text = "\(counter) дней"
        dayCounter.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayCounter.textColor = .blackYP
        contentView.addSubview(dayCounter)
        dayCounter.translatesAutoresizingMaskIntoConstraints = false
        return dayCounter
    }()
    
    private lazy var plusButton: UIButton = {
        var plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "plusButton"), for: .normal)
        contentView.addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return plusButton
    }()
    
    func updateCellStatus(isDone: Bool) {
        if isDone {
            plusButton.setImage(UIImage(named: "checkMark")?.withRenderingMode(.alwaysTemplate), for: .normal)
            plusButton.tintColor = plusButton.tintColor.withAlphaComponent(0.6)
        } else {
            plusButton.setImage(UIImage(named: "plusButton"), for: .normal)
            plusButton.tintColor = backCellView.backgroundColor
        }
    }
    
    func updateDayCounter(totalCompletedCount: Int){
        dayCounter.text = "\(totalCompletedCount) дней"
    }
    
    @objc
    private func plusButtonTapped() {
        delegate?.didTapPlusButton(in: self)
    }
    
    private func configCell(){
        contentView.backgroundColor = .whiteYP
        
        NSLayoutConstraint.activate([
            backCellView.widthAnchor.constraint(equalToConstant: 167),
            backCellView.heightAnchor.constraint(equalToConstant: 90),
            cellTitle.bottomAnchor.constraint(equalTo: backCellView.bottomAnchor, constant: -12),
            cellTitle.leadingAnchor.constraint(equalTo: backCellView.leadingAnchor, constant: 12),
            cellTitle.trailingAnchor.constraint(equalTo: backCellView.trailingAnchor, constant: -12),
            backView.widthAnchor.constraint(equalToConstant: 24),
            backView.heightAnchor.constraint(equalToConstant: 24),
            backView.topAnchor.constraint(equalTo: backCellView.topAnchor, constant: 12),
            backView.leadingAnchor.constraint(equalTo: backCellView.leadingAnchor, constant: 12),
            emoji.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            emoji.centerXAnchor.constraint(equalTo: backView.centerXAnchor),
            dayCounter.leadingAnchor.constraint(equalTo: backCellView.leadingAnchor, constant: 12),
            dayCounter.topAnchor.constraint(equalTo: backCellView.bottomAnchor, constant: 16),
            plusButton.trailingAnchor.constraint(equalTo: backCellView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: backCellView.bottomAnchor, constant: 8)
        ])
    }
    
    func setValueForCellItems(text: String, color: UIColor, emojiText: String){
        backCellView.backgroundColor = color
        cellTitle.text = text
        emoji.text = emojiText
        plusButton.tintColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
