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
    var dDate: String
    var dSpentTime: Int
    let dGoalTime: Int
    let dContent: String?

    init(spentTime: Int, goalTime: Int, content: String? = nil) {
        self.dDate = getToday()
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


func getToday() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    // 日本の日付表示
    dateFormatter.locale = Locale(identifier: "ja_JP")
    let japaneseDate = dateFormatter.string(from: Date())
    return japaneseDate
}
