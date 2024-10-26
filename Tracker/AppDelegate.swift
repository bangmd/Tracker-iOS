import UIKit
import CoreData
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "0b0a3637-e3ff-4dec-9ca7-cf0dce9cba91") else {
            return true
        }
        
        YMMYandexMetrica.activate(with: configuration)
        
        let transformerName = NSValueTransformerName("ScheduleTransformer")
        ValueTransformer.setValueTransformer(ScheduleTransformer(), forName: transformerName)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenOnboarding)
        window = UIWindow()
        
        if hasSeenOnboarding {
            window?.rootViewController = TabBarViewController()
        } else {
            let onboardingVC = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            window?.rootViewController = onboardingVC
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

