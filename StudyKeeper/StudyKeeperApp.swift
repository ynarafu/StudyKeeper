//
//  StudyKeeperApp.swift
//  StudyKeeper
//
//  Created by ynarafu on 2024/04/04.
//

import SwiftUI

@main
struct StudyKeeperApp: App {
    var body: some Scene {
        WindowGroup {
            TimerView()
                .modelContainer(for: StudyData.self)
        }
    }
}
