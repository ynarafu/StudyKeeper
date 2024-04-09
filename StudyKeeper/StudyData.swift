//
//  StudyData.swift
//  StudyKeeper
//
//  Created by FW-ynarafu on 2024/04/09.
//

import Foundation
import SwiftData

@Model
final class StudyData {
    var date: String
    var spentTime: Int
    let goalTime: Int
    let content: String?

    init(spentTime: Int, goalTime: Int, content: String? = nil) {
        self.date = getToday()
        self.spentTime = spentTime
        self.goalTime = goalTime
        self.content = content
    }
    
    func calcAchievementRate() -> Int {
        var achieventRate: Int
        achieventRate = self.spentTime * 10 / self.goalTime
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
