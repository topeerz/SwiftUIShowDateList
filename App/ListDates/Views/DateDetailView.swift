//
//  DateDetailView.swift
//  SwiftUIShowDateList
//
//  Created by topeerz on 22/11/2024.
//

import Observation
import SwiftUI

struct DateDetailView: View {

    let date: Date

    var body: some View {
        Text("Date Detail \(date)")
        Image(systemName: "clock")
    }
}
