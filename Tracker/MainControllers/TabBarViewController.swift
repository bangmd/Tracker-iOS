import UIKit

final class TabBarViewController: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .whiteYP
        generateTabBar()
    }
   
    private func generateTabBar(){
        viewControllers = [
            generateVC(
                viewController: UINavigationController(rootViewController:TrackerViewController()),
                title: NSLocalizedString("trackerTitle", comment: ""),
                image: UIImage(named: "trackerTabBarImage")),
            generateVC(
                viewController: UINavigationController(rootViewController:StatisticViewController()),
                title: NSLocalizedString("statisticTitle", comment: ""),
                image: UIImage(named: "statisticTabBarImage"))
        ]
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 10, weight: .medium)]
        appearance.setTitleTextAttributes(attributes, for: .normal)
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController{
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
}
