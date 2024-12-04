//
//  StatisticsView.swift
//  ios1024
//
//  Created by Keefer Riley on 11/12/24.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var statsVM: StatisticsViewModel  //Use an environment object
    var body: some View {
        VStack {
            // Display statistics, now using statsVM.gameStats
            List {
                ForEach(statsVM.gameStats) { stat in
                    HStack{
                        Text(stat.date, style: .date)
                        Text("Score: \(stat.score)")
                        Text("Steps: \(stat.steps)")
                    }
                }
            }
            
            // Sorting Controls
            HStack {
                Picker("Sort by", selection: $statsVM.sortBy) {
                    Text("Steps").tag(StatisticsViewModel.SortField.steps)
                    Text("Score").tag(StatisticsViewModel.SortField.score)
                    Text("Date").tag(StatisticsViewModel.SortField.date)
                }
                .pickerStyle(SegmentedPickerStyle()) // Use segmented control for sorting field
                
                Button(statsVM.sortOrder == .ascending ? "Ascending" : "Descending") {
                    statsVM.toggleSortOrder()
                }
            }.padding(.horizontal)
        }
        
    }
}

