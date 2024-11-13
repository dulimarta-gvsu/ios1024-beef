//
//  GameViewMode.swift
//  ios1024
//
//  Created by Hans Dulimarta for CIS357
//
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var grid: Array<Array<Int>>
    @Published private var _validSwipes = 0
    
    public var gameWon: Bool {
        for row in grid {
            for cell in row {
                if cell >= 1024 {
                    return true
                }
            }
        }
        return false
    }

    public var gameLost: Bool {
        if gridIsFull() && !canMerge() {
            return true
        }
        return false
    }
    
    public func gridIsFull() -> Bool {
        for row in grid {
            for cell in row {
                if cell == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    public func canMerge() -> Bool {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if canMerge(row: row, col: col) {
                        return true
                }
            }
        }
        return false
    }
    
    public func canMerge(row: Int, col: Int) -> Bool {
        let value = grid[row][col]
        if value == 0 { return false }

        let directions: [(Int, Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = col + dc

            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize &&
                grid[newRow][newCol] == value {
                return true
            }
        }
        return false
    }

    var validSwipes: Int {
        get {
            _validSwipes
        }
        set {
            _validSwipes = newValue
        }
    }
    
    // set gridSize
    let gridSize = 4
    
    init () {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        addRandomTile()
        addRandomTile()
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        addRandomTile()
        addRandomTile()
        _validSwipes = 0
    }
    
    func incrementValidSwipes() {
        _validSwipes += 1
    }
    
    func handleSwipe(_ direction: SwipeDirection) {
        if gameWon || gameLost { return }
        var boardChanged: Bool = false
        
        switch(direction) {
        case .left:
            boardChanged = swipeLeft()
        case .right:
            boardChanged = swipeRight()
        case .up:
            boardChanged = swipeUp()
        case .down:
            boardChanged = swipeDown()
        }
        
        if boardChanged {
            addRandomTile()
            checkWinLose()
        }
    }
    
    private func checkWinLose() {
        if gameWon {
            print("You won!")
        } else if gameLost {
            print("You lost!")
        }
    }
    
    func addRandomTile() {
        // find all empty positions in the grid
        let emptyPositions = grid.indices.flatMap { row in
            grid[row].indices.compactMap { col in
                grid[row][col] == 0 ? (row, col) : nil
            }
        }
        
        // randomly select one empty position and place a new tile there
        if let position = emptyPositions.randomElement() {
            let (row, col) = position
            grid[row][col] = [2, 4].randomElement()!
        }
    }
    private func swipeLeft() -> Bool {
        var boardChanged = false
        
        for row in 0..<gridSize {
            var merged = [Bool](repeating: false, count: gridSize)
            
            for col in 1..<gridSize {
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
        
        for row in 0..<gridSize {
            var merged = [Bool](repeating: false, count: gridSize)
            
            for col in (0..<(gridSize - 1)).reversed() {
                guard grid[row][col] != 0 else { continue }
                
                var targetCol = col
                // Move tile as far right as possible
                while targetCol < gridSize - 1 && grid[row][targetCol + 1] == 0 {
                    grid[row][targetCol + 1] = grid[row][targetCol]
                    grid[row][targetCol] = 0
                    targetCol += 1
                    boardChanged = true
                }
                
                // Merge with right tile if possible
                if targetCol < gridSize - 1 && grid[row][targetCol + 1] == grid[row][targetCol] && !merged[targetCol + 1] {
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
        
        for col in 0..<gridSize {
            var merged = [Bool](repeating: false, count: gridSize)
            
            for row in 1..<gridSize {
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

        for col in 0..<gridSize {
            var merged = [Bool](repeating: false, count: gridSize)

            for row in (0..<(gridSize - 1)).reversed() {
                guard grid[row][col] != 0 else { continue }

                var targetRow = row
                // Move tile as far down as possible
                while targetRow < gridSize - 1 && grid[targetRow + 1][col] == 0 {
                    grid[targetRow + 1][col] = grid[targetRow][col]
                    grid[targetRow][col] = 0
                    targetRow += 1
                    boardChanged = true
                }

                // Merge with lower tile if possible
                if targetRow < gridSize - 1 &&
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
