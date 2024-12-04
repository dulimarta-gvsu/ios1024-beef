import SwiftUI

class StatisticsViewModel: ObservableObject {
    @Published var gameStats: [GameStatistic] = [] // New data structure
    @Published var sortOrder: SortOrder = .ascending // Track sort order
    @Published var sortBy: SortField = .steps // Track sorting field

    enum SortOrder {
        case ascending, descending
    }

    enum SortField {
        case steps, score, date // Add other fields as needed
    }

    struct GameStatistic: Identifiable, Hashable { // Simplified struct
        let id = UUID() // Automatic ID for each statistic
        let date: Date
        let score: Int
        let steps: Int
        // ... any other stats you want to track
    }

    func addGameStatistic(score: Int, steps: Int) {
        let newStat = GameStatistic(date: Date(), score: score, steps: steps)
        gameStats.append(newStat)
        sortStatistics() // Sort whenever a new stat is added
    }

    func sortStatistics() {
        switch sortBy {
        case .steps:
            gameStats.sort {
                sortOrder == .ascending ? $0.steps < $1.steps : $0.steps > $1.steps
            }
        case .score:
            gameStats.sort {
                sortOrder == .ascending ? $0.score < $1.score : $0.score > $1.score
            }
        case .date:
            gameStats.sort {
                sortOrder == .ascending ? $0.date < $1.date : $0.date > $1.date
            }
        }
    }

    func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
        sortStatistics()
    }

    func changeSortField(to field: SortField) {
        sortBy = field
        sortStatistics()
    }
}
