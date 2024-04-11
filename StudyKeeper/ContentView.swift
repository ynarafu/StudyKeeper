//
//  ContentView.swift
//  StudyKeeper
//
//  Created by FW-ynarafu on 2024/04/04.
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
    @State var status: Array = ["working", "resting"]
    @State var content = ""
    @State var spentTime = 0  //second
    @State var counter = 0 //second
    
    @AppStorage("workTime") var workTime = 3  //25m×60s
    @AppStorage("restTime") var restTime = 5   //5m×60s
    @AppStorage("goalTime") var goalTime: Int = 1 * 60 * 60 //1h*60min*60sec
    @State var time: String = intToTime(value: 3)
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
                        
                        TimerGauge($value, status: status[isWorking ? 0:1], time: time, parentSize: geometry.size)
                    }
                    
                    HStack(spacing: geometry.size.width/5) {
                        Button(action: {
                            finishTimer()
                            
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
                    CalenderView(goalTime: $goalTime)
                }
            }
        }
    }
    func calcProgress() {
        if isWorking {
            self.value = Double(self.workTime - self.counter) / Double(self.workTime)
        }
        else {
            self.value = Double(self.restTime - self.counter) / Double(self.restTime)
        }
    }
    
    func countDownTimer(){
        var countTime: Int
        
        countTime = isWorking ? workTime : restTime
        spentTime += isWorking ? 1:0
        counter += 1
        if countTime - counter <= 0{
            isWorking.toggle()
            countTime = isWorking ? workTime : restTime
            counter = 0
            timerHandler?.invalidate()
            timerHandler = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                countDownTimer()
            })
        }
        time = intToTime(value: countTime - counter)
        calcProgress()
    }
    
    func startTimer() {
        var countTime: Int
        
        countTime = isWorking ? workTime : restTime
        if let unwrapedTimerHandler = timerHandler {
            if unwrapedTimerHandler.isValid == true {
                return
            }
        }
        if countTime - counter <= 0 {
            counter = 0
        }
        timerHandler = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            countDownTimer()
        })
        self.isCounwtDown = true
    }
    
    func stopTimer() {
        if let unwrapedTimerHandler = timerHandler {
            if unwrapedTimerHandler.isValid == true {
                unwrapedTimerHandler.invalidate()
            }
        }
        self.isCounwtDown = false
    }
    
    func finishTimer() {
        var today = getToday()
        if let unwrapedTimerHandler = timerHandler {
            if unwrapedTimerHandler.isValid == true {
                unwrapedTimerHandler.invalidate()
            }
        }
        self.isCounwtDown = false
        self.isWorking = true
        self.counter = 0
        calcProgress()
        self.time = intToTime(value: workTime)
        if self.lastDay == today {
            updateSpendTime(date: today, spentTime: spentTime)
        }
        else {
            add(spentTime: self.spentTime, goalTime: self.goalTime)
            self.lastDay = today
        }
        self.spentTime = 0
    }
    
    private func add(spentTime: Int, goalTime: Int, content: String? = nil) {
        let data = StudyData(spentTime: spentTime, goalTime: goalTime, content: content)
        context.insert(data)
        self.lastDay = getToday()
    }
    private func delete(studyData: StudyData) {
        context.delete(studyData)
    }
    private func updateSpendTime(date: String, spentTime: Int) {
        let updatingIndex = studyDatas.firstIndex { $0.dDate == date }
        guard let updatingIndex else { return }
        studyDatas[updatingIndex].dSpentTime += spentTime
        try? context.save()
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

func intToTime(value: Int) -> String {
    let hours = value / 3600
        let minutes = (value % 3600) / 60
        let seconds = (value % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}


#Preview {
    TimerView()
        .modelContainer(for: StudyData.self)
}
