//
//  StudyData.swift
//  StudyKeeper
//
//  Created by ynarafu on 2024/04/09.
//

import Foundation
import SwiftData

@Model
final class StudyData {
    var id: UUID
    var dDate: String
    var dSpentTime: Int
    var dGoalTime: Int
    var dContent: String?

    init(spentTime: Int, goalTime: Int, content: String? = nil) {
        self.id = UUID()
        self.dDate = dateToString(date: Date())
        self.dSpentTime = spentTime
        self.dGoalTime = goalTime
        self.dContent = content
    }
    
    func calcAchievementRate() -> Int {
        var achieventRate: Int
        achieventRate = self.dSpentTime * 10 / self.dGoalTime
        return achieventRate * 10 //パーセントで返す
    }
    
}

func dateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()

    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    // 日本の日付表示
    dateFormatter.locale = Locale(identifier: "ja_JP")
    guard let japaneseDate = dateFormatter.string(for: date) else {
        return ""
    }
    return japaneseDate
}
