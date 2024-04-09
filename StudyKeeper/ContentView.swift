//
//  ContentView.swift
//  StudyKeeper
//
//  Created by FW-ynarafu on 2024/04/04.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @State var path = NavigationPath()
    @State private var value: CGFloat = 0.7
    @State var isPresented = false
    @State var isCounwtDown = false
    @AppStorage("workTime") var workTime = 25
    @AppStorage("restTime") var restTime = 5
    @Environment(\.modelContext) private var context
    @Query private var studyDatas: [StudyData]
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path){
                VStack(spacing: 40) {
                    VStack(spacing: 120){
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
                        
                        TimerGauge($value, maxValue: 1, parentSize: geometry.size)
                    }
                    
                    HStack(spacing: geometry.size.width/5) {
                        Button(action: {
                            self.isCounwtDown = false
                        }, label: {
                            Text("FINISH")
                                .circleButton(.mint.opacity(0.5))
                        })
                        .disabled(!self.isCounwtDown)
                        Button(action: {
                            self.isCounwtDown = !self.isCounwtDown
                        }, label: {
                            if self.isCounwtDown == false {
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
                    CalenderView()
                }
            }
        }
    }
    
    private func add(spentTime: Int, goalTime: Int, content: String? = nil) {
        let data = StudyData(spentTime: spentTime, goalTime: goalTime, content: content)
        context.insert(data)
    }
    private func delete(studyData: StudyData) {
        context.delete(studyData)
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
    private let maxValue: CGFloat
    var frameSize: Double
    let gradient = LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
    
    
    init(_ value: Binding<CGFloat>, maxValue: CGFloat, parentSize: CGSize) {
        self._value = value
        self.maxValue = maxValue
        self.parentSize = parentSize
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
                Text("work")
                    .font(.title)
                    .bold()
                Text("00:23:23")
                    .font(.largeTitle)
                    .bold()
            }
        }
        .frame(width: frameSize, height: frameSize, alignment: .center)
    }
}
 
#Preview {
    TimerView()
        .modelContainer(for: StudyData.self)
}
