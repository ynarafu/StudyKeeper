import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var dateSelected: DateComponents?
    @State var isShowDailyModal: Bool = false
    @Query private var studyDatas: [StudyData]
    
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
    //@Environment(\.modelContext) private var context
    //@Query private var studyDatas: [StudyData]
    var aStudyData: StudyData
    
    var body: some View {
        if let dateSelected {
             
                aStudyData = await StudyDataService.shared.searchStudyDatas(keyword: dateToString(date: dateSelected))
             
        }
    }
}

#Preview {
    CalendarView().modelContainer(for: StudyData.self)
}
