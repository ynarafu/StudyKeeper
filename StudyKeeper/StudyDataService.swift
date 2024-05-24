//
//  StudyDataService.swift
//  StudyKeeper
//
//  Created by 楢府佑 on 2024/05/15.
//

import Foundation
import SwiftData

class Persistance {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StudyData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("error create sharedModelContainer: \(error)")
        }
    }()
    
}

actor PersistanceActor: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    func save() {
        do {
            try modelContext.save()
        }catch {
            print("error save")
        }
    }

    func insert<T:PersistentModel>(_ value:T) {
        do {
            modelContext.insert(value)
            try modelContext.save()
        }catch {
            print("error insert")
        }
    }
    
    func delete<T:PersistentModel>(_ value:T) {
        do {
            modelContext.delete(value)
            try modelContext.save()
        }catch {
            print("error delete")
        }
    }
    
    func get<T:PersistentModel>(_ descriptor:FetchDescriptor<T>)->[T]? {
        var fetched:[T]?
        do {
            fetched = try modelContext.fetch(descriptor)
        }catch {
            print("error get")
        }
        return fetched
    }
    
}

final class StudyDataService {
    static let shared = StudyDataService()
    
    lazy var actor = {
        return PersistanceActor(modelContainer: Persistance.sharedModelContainer)
    }()
    /*
    func createStudyData(inSpentTime: Int, inGoalTime: Int) async -> StudyData {
        let studydata = StudyData(spentTime: inSpentTime, goalTime: inGoalTime)
        await actor.insert(studydata)
        return studydata
    }
     */
    func createStudyData(inSpentTime: Int, inGoalTime: Int) async {
        let studydata = StudyData(spentTime: inSpentTime, goalTime: inGoalTime)
        await actor.insert(studydata)
    }
    
    func searchStudyDatas(keyword: String) async -> [StudyData] {
        let predicate = #Predicate<StudyData> { studydata in
            studydata.dDate == keyword
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        return await actor.get(descriptor) ?? []
    }
    
    func getStudyDataById(id: UUID) async -> StudyData? {
        let predicate = #Predicate<StudyData> { studydata in
            studydata.id == id
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        let studydatas = await actor.get(descriptor)
        guard let studydatas = studydatas,
              let studydata = studydatas.first
        else {
            return nil
        }
        return studydata
    }
    
    func deleteStudyData(id: UUID) async -> Bool {
        guard let studydata = await getStudyDataById(id: id) else { return false }
        await actor.delete(studydata)
        return true
    }
    
    func updateSpentTime(id: UUID, spentTime: Int) async -> StudyData? {
        guard let studydata = await getStudyDataById(id: id) else { return nil }
        studydata.dSpentTime = spentTime
        await actor.save()
        return studydata
    }
    
    func updateContent(id: UUID, content: String?) async -> StudyData? {
        guard let studydata = await getStudyDataById(id: id) else { return nil }
        if let content = content {
                    studydata.dContent = content
               }
        await actor.save()
        return studydata
    }

    
    func getAllStudyDatas() async -> [StudyData] {
        let predicate = #Predicate<StudyData> { studydata in
            return true
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        return await actor.get(descriptor) ?? []
    }
}
