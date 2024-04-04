//
//  ContentView.swift
//  StudyKeeper
//
//  Created by FW-ynarafu on 2024/04/04.
//

import SwiftUI
import Foundation

struct TimerView: View {
    @State var path = NavigationPath()
    let timerScale: Double = 5
    @State var isPresented = false
    
    
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
                        .frame(width: 300, alignment: .trailing)
                        
                        
                        Gauge(value: 0.7, label: {
                            VStack {
                                Text("working")
                                    .font(.footnote)
                                Text("00:23:23")
                            }
                        })
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 300, height: 300, alignment: .center)
                        .scaleEffect(timerScale)
                        
                    }
                    
                    HStack(spacing: 50) {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Button")
                                .frame(width: 100, height: 100)
                                .background(.blue)
                                .clipShape(Circle())
                        })
                        .clipShape(Circle())
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Button")
                                .frame(width: 100, height: 100)
                                .background(.blue)
                                .clipShape(Circle())
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
}



#Preview {
    TimerView()
}
