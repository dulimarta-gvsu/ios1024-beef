import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class GameViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var grid: Array<Array<Int>> = []
    @Published private var _validSwipes = 0
    @Published var targetScore: Int = 1024
    @Published var boardSize: Int = 4
    

    // MARK: - Private Properties

    private let db = Firestore.firestore() // part 3
    private var settingsChangedSubject = PassthroughSubject<Void, Never>()
    var settingsChangedPublisher: AnyPublisher<Void, Never> { settingsChangedSubject.eraseToAnyPublisher() }
    var cancellables: Set<AnyCancellable> = []


    // MARK: - Initialization

    init() {
        //UserDefaults Initialization: Load from UserDefaults if present
        loadSavedSettings()
        grid = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
        addRandomTile()
        addRandomTile()
    }
    
    func loadSavedSettings() {
        boardSize = UserDefaults.standard.integer(forKey: "boardSize")
        if boardSize == 0 { boardSize = 4 }

        targetScore = UserDefaults.standard.integer(forKey: "targetScore")
        if targetScore == 0 { targetScore = 2048 }
    }

    // MARK: - Game State Properties

    public var gameWon: Bool {
        for row in grid {
            for cell in row {
                if cell >= targetScore {
                    return true
                }
            }
        }
        return false
    }

    public var gameLost: Bool {
        return gridIsFull() && !canMerge()
    }


    // MARK: - Game Logic Functions

    func applySettings() {
        UserDefaults.standard.set(boardSize, forKey: "boardSize")
        UserDefaults.standard.set(targetScore, forKey: "targetScore")
        loadSavedSettings()
        settingsChangedSubject.send()
        resetGame()
    }


    func resetGame() {
        grid = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
        addRandomTile()
        addRandomTile()
        _validSwipes = 0
    }

    func incrementValidSwipes() {
        _validSwipes += 1
    }

    var validSwipes: Int {
        get { _validSwipes }
        set { _validSwipes = newValue }
    }

    func handleSwipe(_ direction: SwipeDirection) {
        if gameWon || gameLost { return }

        var boardChanged = false
        switch direction {
        case .left:  boardChanged = swipeLeft()
        case .right: boardChanged = swipeRight()
        case .up:    boardChanged = swipeUp()
        case .down:  boardChanged = swipeDown()
        }

        if boardChanged {
            addRandomTile()
            checkWinLose()
        }
    }


    func myFirestore() async {
        // Future implementation for persisting game statistics (Part 3)
    }
    
    private func checkWinLose() {
        if gameWon {
            print("You won!")
        } else if gameLost {
            print("You lost!")
        }
    }

    func addRandomTile() {
        let emptyPositions = grid.indices.flatMap { row in
            grid[row].indices.compactMap { col in
                grid[row][col] == 0 ? (row, col) : nil
            }
        }

        if let (row, col) = emptyPositions.randomElement() {
            grid[row][col] = [2, 4].randomElement()!
        }
    }

    func checkUserAcc(user: String, pwd: String) async -> Bool {
        do {
            try await Auth.auth().signIn(withEmail: user, password: pwd)
            return true
        } catch {
            print("Error \(error.localizedDescription)")
            return false
        }
    }



    // MARK: - Helper Functions (Grid Logic)
    private func gridIsFull() -> Bool {
        for row in grid {
            for cell in row {
                if cell == 0 {
                    return false
                }
            }
        }
        return true
    }


    private func canMerge(row: Int, col: Int) -> Bool {
        let value = grid[row][col]
        guard value != 0 else { return false }

        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = col + dc

            if newRow >= 0 && newRow < boardSize && newCol >= 0 && newCol < boardSize &&
                grid[newRow][newCol] == value {
                return true
            }
        }
        return false
    }

    private func canMerge() -> Bool {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if canMerge(row: row, col: col) {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Swipe Functions

    private func swipeLeft() -> Bool {
        var boardChanged = false
        
        for row in 0..<boardSize {
            var merged = [Bool](repeating: false, count: boardSize)
            
            for col in 1..<boardSize {
                guard grid[row][col] != 0 else { continue }
                
                var targetCol = col
                // Move tile as far left as possible
                while targetCol > 0 && grid[row][targetCol - 1] == 0 {
                    grid[row][targetCol - 1] = grid[row][targetCol]
                    grid[row][targetCol] = 0
                    targetCol -= 1
                    boardChanged = true
                }
                
                // Merge with left tile if possible
                if targetCol > 0 && grid[row][targetCol - 1] == grid[row][targetCol] && !merged[targetCol - 1] {
                    grid[row][targetCol - 1] *= 2
                    grid[row][targetCol] = 0
                    merged[targetCol - 1] = true
                    boardChanged = true
                }
            }
        }
        
        return boardChanged
    }
    
    private func swipeRight() -> Bool {
        var boardChanged = false
        
        for row in 0..<boardSize {
            var merged = [Bool](repeating: false, count: boardSize)
            
            for col in (0..<(boardSize - 1)).reversed() {
                guard grid[row][col] != 0 else { continue }
                
                var targetCol = col
                // Move tile as far right as possible
                while targetCol < boardSize - 1 && grid[row][targetCol + 1] == 0 {
                    grid[row][targetCol + 1] = grid[row][targetCol]
                    grid[row][targetCol] = 0
                    targetCol += 1
                    boardChanged = true
                }
                
                // Merge with right tile if possible
                if targetCol < boardSize - 1 && grid[row][targetCol + 1] == grid[row][targetCol] && !merged[targetCol + 1] {
                    grid[row][targetCol + 1] *= 2
                    grid[row][targetCol] = 0
                    merged[targetCol + 1] = true
                    boardChanged = true
                }
            }
        }
        
        return boardChanged
    }
    
    private func swipeUp() -> Bool {
        var boardChanged = false
        
        for col in 0..<boardSize {
            var merged = [Bool](repeating: false, count: boardSize)
            
            for row in 1..<boardSize {
                guard grid[row][col] != 0 else { continue }
                
                var targetRow = row
                // Move tile as far up as possible
                while targetRow > 0 && grid[targetRow - 1][col] == 0 {
                    grid[targetRow - 1][col] = grid[targetRow][col]
                    grid[targetRow][col] = 0
                    targetRow -= 1
                    boardChanged = true
                }
                
                // Merge with upper tile if possible
                if targetRow > 0 && grid[targetRow - 1][col] == grid[targetRow][col] && !merged[targetRow - 1] {
                    grid[targetRow - 1][col] *= 2
                    grid[targetRow][col] = 0
                    merged[targetRow - 1] = true
                    boardChanged = true
                }
            }
        }
        
        return boardChanged
    }
    
    private func swipeDown() -> Bool {
        var boardChanged = false

        for col in 0..<boardSize {
            var merged = [Bool](repeating: false, count: boardSize)

            for row in (0..<(boardSize - 1)).reversed() {
                guard grid[row][col] != 0 else { continue }

                var targetRow = row
                // Move tile as far down as possible
                while targetRow < boardSize - 1 && grid[targetRow + 1][col] == 0 {
                    grid[targetRow + 1][col] = grid[targetRow][col]
                    grid[targetRow][col] = 0
                    targetRow += 1
                    boardChanged = true
                }

                // Merge with lower tile if possible
                if targetRow < boardSize - 1 &&
                    grid[targetRow + 1][col] == grid[targetRow][col] &&
                    !merged[targetRow + 1] {
                    
                    grid[targetRow + 1][col] *= 2  // Accessing the specific cell, not the entire row
                    grid[targetRow][col] = 0
                    merged[targetRow + 1] = true
                    boardChanged = true
                }
            }
        }
        return boardChanged
    }

}
