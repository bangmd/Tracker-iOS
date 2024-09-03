import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell{
    
    private lazy var title: UILabel = {
        var title = UILabel()
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 32)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(emoji: String){
        title.text = emoji
    }
}
