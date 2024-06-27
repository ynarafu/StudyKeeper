//
//  ContentView.swift
//  StudyKeeper
//
//  Created by ynarafu on 2024/04/04.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @State var timerHandler : Timer?
    @State var path = NavigationPath()
    @State private var value: CGFloat = 1.0
    @State var isPresented = false
    @State var isCounwtDown = false
    @State var isWorking = true
    @State var isShowSetting = false
    @State var status: Array = ["working", "resting"]
    @State var content = ""
    @State var spentTime = 0  //second
    @State var counter = 0 //second
    @State var time: String = "00:00:00"
    
    @AppStorage("workTime") var workTime: Int = 25 * 60   //second
    @AppStorage("restTime") var restTime: Int = 5 * 60   //second
    @AppStorage("goalTime") var goalTime: Int = 1// * 60 * 60 //second
    
    @AppStorage("lastDay") var lastDay = "1800/1/1"
    @Environment(\.modelContext) private var context
    @Query private var studyDatas: [StudyData]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path){
                VStack(spacing: 40) {
                    VStack(spacing: 90){
                        Button(action: {
                            isPresented = true
                        }, label: {
                            VStack(spacing: 0) {
                                Image("Calender")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Text("Calender")
                                    .foregroundColor(.green)
                            }
                        })
                        .frame(width: geometry.size.width*4/5, alignment: .trailing)
                        
                        TimerGauge($value, status: self.status[isWorking ? 0:1], time: self.time, parentSize: geometry.size)
                            .onTapGesture {
                                self.isShowSetting = true
                            }
                            .sheet(isPresented: $isShowSetting) {
                                SettingView()
                                    .presentationDetents([.medium])
                            }
                            .onAppear() {
                                self.time = self.calcRemainTime()
                            }
                            .onChange(of: isShowSetting) {
                                self.time = self.calcRemainTime()
                            }
                    }
                    
                    HStack(spacing: geometry.size.width/5) {
                        Button(action: {
                            Task {
                                await finishTimer()
                            }
                        }, label: {
                            Text("FINISH")
                                .circleButton(.mint.opacity(0.5))
                        })
                        Button(action: {
                            if !self.isCounwtDown {
                                startTimer()
                            }
                            else {
                                stopTimer()
                            }
                        }, label: {
                            if !self.isCounwtDown {
                                Text("START")
                                    .circleButton(.mint.opacity(0.5))
                            }
                            else {
                                Text("STOP")
                                    .circleButton(.orange.opacity(0.5))
                            }
                        })
                    }
                    Spacer()
                }
                .navigationTitle("Pomodoro")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $isPresented) {
                    CalendarView().modelContainer(for: StudyData.self)
                }
            }
        }
    }
    func calcProgress() {
        if self.isWorking {
            self.value = Double(self.workTime - self.counter) / Double(self.workTime)
        }
        else {
            self.value = Double(self.restTime - self.counter) / Double(self.restTime)
        }
    }
    
    func calcRemainTime() -> String {
        let maxTime = self.isWorking ? self.workTime : self.restTime
        return intToTime(value: maxTime - self.counter)
    }
    
    func countDownTimer(){
        var countTime: Int
        
        countTime = self.isWorking ? self.workTime : self.restTime
        self.spentTime += self.isWorking ? 1:0
        self.counter += 1
        if countTime - self.counter <= 0{
            self.isWorking.toggle()
            countTime = self.isWorking ? self.workTime : self.restTime
            self.counter = 0
            self.timerHandler?.invalidate()
            self.timerHandler = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.countDownTimer()
            })
        }
        self.time = intToTime(value: countTime - self.counter)
        self.calcProgress()
    }
    
    func startTimer() {
        var countTime: Int
        
        countTime = self.isWorking ? self.workTime : self.restTime
        if let unwrapedTimerHandler = self.timerHandler {
            if unwrapedTimerHandler.isValid == true {
                return
            }
        }
        if countTime - self.counter <= 0 {
            self.counter = 0
        }
        self.timerHandler = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.countDownTimer()
        })
        self.isCounwtDown = true
    }
    
    func stopTimer() {
        if let unwrapedTimerHandler = self.timerHandler {
            if unwrapedTimerHandler.isValid == true {
                unwrapedTimerHandler.invalidate()
            }
        }
        self.isCounwtDown = false
    }
    
    func finishTimer() async {
        let today = dateToString(date: Date())
        if let unwrapedTimerHandler = self.timerHandler {
            if unwrapedTimerHandler.isValid == true {
                unwrapedTimerHandler.invalidate()
            }
        }
        self.isCounwtDown = false
        self.isWorking = true
        self.counter = 0
        self.calcProgress()
        self.time = intToTime(value: self.workTime)
        if self.lastDay == today {
            self.updateSpendTime(date: today, inSpentTime: self.spentTime, inGoalTime: self.goalTime)
        }
        else {
            await self.create(inSpentTime: self.spentTime, inGoalTime: self.goalTime)
            self.lastDay = today
        }
        self.spentTime = 0
    }
    
    private func create(inSpentTime: Int, inGoalTime: Int, content: String? = nil) async {
        await StudyDataService.shared.createStudyData(inSpentTime: inSpentTime, inGoalTime: inGoalTime)
        self.lastDay = dateToString(date: Date())
    }
    
    private func add(spentTime: Int, goalTime: Int, content: String? = nil) {
        let data = StudyData(spentTime: spentTime, goalTime: goalTime, content: content)
        self.context.insert(data)
        self.lastDay = dateToString(date: Date())
    }
    private func delete(studyData: StudyData) {
        self.context.delete(studyData)
    }
    private func updateSpendTime(date: String, inSpentTime: Int, inGoalTime:Int) {
        let updatingIndex = self.studyDatas.firstIndex { $0.dDate == date }
        guard let updatingIndex else { return }
        self.studyDatas[updatingIndex].dSpentTime += spentTime
        self.studyDatas[updatingIndex].dGoalTime = goalTime
        try? self.context.save()
    }
}

extension Text {
    func circleButton(_ color:Color) -> some View {
        self
            .foregroundColor(.black)
            .frame(width: 100, height: 100)
            .background(color)
            .clipShape(Circle())
    }
}

struct TimerGauge: View {
    let expandRate = 0.75
    @Binding var value: CGFloat
    private let parentSize: CGSize
    private let status: String
    private let time: String
    var frameSize: Double
    let gradient = LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
    
    init(_ value: Binding<CGFloat>, status: String, time: String, parentSize: CGSize) {
        self._value = value
        self.parentSize = parentSize
        self.status = status
        self.time = time
        if self.parentSize.width > self.parentSize.height {
            self.frameSize = self.parentSize.height * expandRate
        }
        else {
            self.frameSize = self.parentSize.width * expandRate
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            timerGauge(proxy: proxy)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func timerGauge(proxy: GeometryProxy) -> some
    View {
        ZStack {
            Circle()
                .foregroundColor(Color(.systemGray6).opacity(0.7))
            Circle()
                .trim(from: 0, to: 1 * self.value)
                .stroke(gradient, lineWidth: 20)
                .rotationEffect(.degrees(-90))
                .rotation3DEffect(
                    Angle(degrees: 180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            
            VStack {
                Text(self.status)
                    .font(.title)
                    .bold()
                Text(self.time)
                    .font(.largeTitle)
                    .bold()
            }
        }
        .frame(width: frameSize, height: frameSize, alignment: .center)
    }
}


struct SettingView: View {
    @AppStorage("workTime") var workTime = 25 * 60
    @AppStorage("restTime") var restTime = 5 * 60
    @AppStorage("goalTime") var goalTime = 1// * 60 * 60
    @State private var workTimeDate = Date()
    @State private var restTimeDate = Date()
    @State private var goalTimeDate = Date()
    @State private var isShowSheet = false
    
    var body: some View {
        VStack {
            DatePicker("Work time",
                       selection: $workTimeDate,
                       displayedComponents: [.hourAndMinute]
            )
            .onAppear{
                var dateComponents = DateComponents()
                dateComponents.hour = self.workTime / 3600
                dateComponents.minute = (self.workTime / 60) % 60
                let userCalendar = Calendar.current
                self.workTimeDate = userCalendar.date(from: dateComponents) ?? Date()
            }
            .onChange(of: workTimeDate, {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: self.workTimeDate)
                workTime = timeToInt(value: timeString) ?? 0
                
            })
            .fixedSize()
            .padding()
            DatePicker("Rest time",
                       selection: $restTimeDate,
                       displayedComponents: [.hourAndMinute]
            )
            .onAppear{
                var dateComponents = DateComponents()
                dateComponents.hour = self.restTime / 3600
                dateComponents.minute = (self.restTime / 60) % 60
                let userCalendar = Calendar.current
                self.restTimeDate = userCalendar.date(from: dateComponents) ?? Date()
            }
            .onChange(of: restTimeDate, {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: self.restTimeDate)
                restTime = timeToInt(value: timeString) ?? 0
                
            })
            .fixedSize()
            .padding()
            DatePicker("Goal time",
                       selection: $goalTimeDate,
                       displayedComponents: [.hourAndMinute]
            )
            .onAppear{
                var dateComponents = DateComponents()
                dateComponents.hour = self.goalTime / 3600
                dateComponents.minute = (self.goalTime / 60) % 60
                let userCalendar = Calendar.current
                self.goalTimeDate = userCalendar.date(from: dateComponents) ?? Date()
            }
            .onChange(of: goalTimeDate, {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: self.goalTimeDate)
                goalTime = timeToInt(value: timeString) ?? 0
            })
            .fixedSize()
            .padding()
        }
    }
}

func intToTime(value: Int) -> String {
    let hours = value / 3600
        let minutes = (value % 3600) / 60
        let seconds = (value % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

func timeToInt(value: String) -> Int? {
    let timeComponents = value.split(separator: ":")

        guard timeComponents.count == 2,
              let hours = Int(timeComponents[0]),
              let minutes = Int(timeComponents[1]) else {
            return nil
        }

        let totalSeconds = hours * 3600 + minutes * 60
        return totalSeconds
}   //hh:mm形式


#Preview {
    TimerView()
        .modelContainer(for: StudyData.self)
}
