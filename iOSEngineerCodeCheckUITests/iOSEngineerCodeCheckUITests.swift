//
//  iOSEngineerCodeCheckUITests.swift
//  iOSEngineerCodeCheckUITests
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest

final class iOSEngineerCodeCheckUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 検索 → 一覧表示 → 詳細画面遷移までの一連の流れを検証する
    /// ※ 実際に GitHub API と通信するため、ネットワーク接続が必要
    func test_検索して一覧から詳細画面へ遷移できる() throws {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("swift\n")

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "検索結果が表示されること")
        firstCell.tap()

        let starsLabel = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "stars")
        ).firstMatch
        XCTAssertTrue(starsLabel.waitForExistence(timeout: 5), "詳細画面に Star 数が表示されること")
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
