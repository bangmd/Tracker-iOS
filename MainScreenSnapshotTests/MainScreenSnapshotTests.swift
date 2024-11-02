import XCTest
import SnapshotTesting
@testable import Tracker


final class MainScreenSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
    }
    
    func testMainScreenSnapshot() {
        let mainScreenVC = TrackerViewController()
        mainScreenVC.loadViewIfNeeded()

        mainScreenVC.view.backgroundColor = .blackYP
        
        assertSnapshot(matching: mainScreenVC, as: .image)
    }
}
