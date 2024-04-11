//
//  CalenderView.swift
//  StudyKeeper
//
//  Created by ynarafu on 2024/04/04.
//

import SwiftUI

struct CalenderView: View {
    @Binding var goalTime: Int
    
    var body: some View {
        Text("comming soon!")
    }
}

#Preview {
    CalenderView(goalTime: .constant(60*60))
}
