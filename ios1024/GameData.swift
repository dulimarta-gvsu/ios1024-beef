//
//  GameData.swift
//  ios1024
//
//  Created by Keefer Riley on 11/19/24.
//
import FirebaseFirestore

struct GameData: Codable, Hashable {
    // must match exactly
    @DocumentID var id: String?
    let date: String
    let size: String
    let score: Int
    let steps: Int
    let target: Int
}
