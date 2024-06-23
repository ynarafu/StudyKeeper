import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var dateSelected: DateComponents?
    @State var isShowDailyModal: Bool = false
    //@Query private var studyDatas: [StudyData]
    
    var body: some View {
        CustomCalendarView(dateSelected: $dateSelected, isShowDailyModal: $isShowDailyModal)
            .sheet(isPresented: $isShowDailyModal) {
                DailyView(dateSelected: $dateSelected)
                    .presentationDetents([.medium])
            }
    }
}


struct CustomCalendarView: UIViewRepresentable {
    @Binding var dateSelected: DateComponents?
    @Binding var isShowDailyModal: Bool
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.locale = Locale(identifier: "ja-JP")
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate ,UICalendarSelectionSingleDateDelegate{
        
        var parent: CustomCalendarView
        
        init(parent: CustomCalendarView) {
            self.parent = parent
        }
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let color100 = UIColor(red: 97/255, green: 130/255, blue: 100/255, alpha: 1.0)
            let color80 = UIColor(red: 121/255, green: 172/255, blue: 120/255, alpha: 1.0)
            let color60 = UIColor(red: 176/255, green: 217/255, blue: 177/255, alpha: 1.0)
            
            return .default(color: color60, size: .large)
        }
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
            guard dateComponents != nil else { return }
            parent.isShowDailyModal.toggle()
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
    }
}


struct DailyView : View {
    
    @Binding var dateSelected: DateComponents?
    //@Query(sort: \StudyData.dDate) private var studyDatas: [StudyData]
    //@Environment(\.modelContext) private var context
    @Query private var studyDatas: [StudyData]
    @State private var aStudyData: [StudyData] = []
    @State private var text: String = "swiftUI\nstoryboard"
    
    var body: some View {
        
        VStack {
            if let date = dateSelected {
                Text(mDateFromDateSelect(inDateSelect: date))
                    .font(.title)
                    .padding()
            }
            HStack {
                VStack (alignment: .leading) {
                    Text("勉強時間：")
                        .font(.title2)
                    Text("目標時間：")
                        .font(.title2)
                    Text("達成率：")
                        .font(.title2)
                    Text("実施内容：")
                        .font(.title2)
                }
                VStack (alignment: .leading) {
                    if !aStudyData.isEmpty {
                        Text("\(aStudyData[0].dSpentTime)")
                            .font(.title2)
                        Text("\(aStudyData[0].dGoalTime)")
                            .font(.title2)
                        Text("x %")
                            .font(.title2)
                    }
                    else {
                        Text("00:00:00")
                            .font(.title2)
                        Divider()
                        Text("00:00:00")
                            .font(.title2)
                        Text("x %")
                            .font(.title2)
                        Text(" ")
                            .font(.title2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            TextField("名前を入力してください", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .font(.title2)
            Spacer()
        }
        .task {
            guard let dateComp = dateSelected,
                  let aDate = Calendar.current.date(from: dateComp) else { return }
            aStudyData = await StudyDataService.shared.searchStudyDatas(keyword: dateToString(date: aDate))
        }
    }
    func mDateFromDateSelect(inDateSelect:DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        let calendar = Calendar.current
        if let date = calendar.date(from: inDateSelect) {
            return formatter.string(from: date)
          } else {
            return "Invalid Date"
          }
    }
}
    
#Preview {
    CalendarView().modelContainer(for: StudyData.self)
}
