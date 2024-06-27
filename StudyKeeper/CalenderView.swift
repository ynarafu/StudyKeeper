import SwiftUI
import SwiftData

class DataProvider: ObservableObject {
    @Published var aAllData: [StudyData] = []

    init() {
        loadData()
    }

    private func loadData() {
        Task {
            self.aAllData = await StudyDataService.shared.getAllStudyDatas()
        }
    }

    func color(for date: DateComponents) -> UIColor {
        let color100 = UIColor(red: 97/255, green: 130/255, blue: 100/255, alpha: 1.0)
        let color80 = UIColor(red: 121/255, green: 172/255, blue: 120/255, alpha: 1.0)
        let color60 = UIColor(red: 176/255, green: 217/255, blue: 177/255, alpha: 1.0)
        let color0 = UIColor(red: 220/255, green: 240/255, blue: 220/255, alpha: 1.0)
        var aColor = UIColor(.white)
        
        if let aDate = Calendar.current.date(from: date) {
            let aDateStr = dateToString(date: aDate)
            if let aStudyData = aAllData.first(where: { $0.dDate == aDateStr }) {
                switch aStudyData.calcAchievementRate() {
                case 100:
                    aColor = color100
                case 80 ..< 100:
                    aColor = color80
                case 60 ..< 80:
                    aColor = color60
                case 0 ..< 60:
                    aColor = color0
                default:
                    aColor = UIColor(.white)
                }
            }
        }
        return aColor
    }
}

struct CalendarView: View {
    @State private var dateSelected: DateComponents?
    @State var isShowDailyModal: Bool = false
    
    var body: some View {
        CustomCalendarView(dateSelected: $dateSelected, isShowDailyModal: $isShowDailyModal)
            .sheet(isPresented: $isShowDailyModal, onDismiss: {
                dateSelected = nil
            }) {
                DailyView(dateSelected: $dateSelected)
                    .presentationDetents([.medium])
            }
    }
}

struct CustomCalendarView: UIViewRepresentable {
    @Binding var dateSelected: DateComponents?
    @Binding var isShowDailyModal: Bool
    @StateObject var dataProvider = DataProvider()
    
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
        if dateSelected == nil {
            if let dateSelection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
                dateSelection.selectedDate = nil // リセット処理
            }
        }
        
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate ,UICalendarSelectionSingleDateDelegate{
        
        var parent: CustomCalendarView
        
        init(parent: CustomCalendarView) {
            self.parent = parent
        }
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            
            let aColor = self.parent.dataProvider.color(for: dateComponents)
            
            return .default(color: aColor, size: .large)
            
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
            if(!aStudyData.isEmpty){
                HStack {
                    Text("\(aStudyData[0].dGoalTime)")
                }
            }

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
