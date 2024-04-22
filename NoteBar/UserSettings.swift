//
//  UserSettings.swift
//  NoteBar
//
//  Created by Bora Mert on 21.04.2024.
//

import Foundation

struct UserSettings: Identifiable, Codable{
    var id = UUID()
    
    var themeColor: String
}
