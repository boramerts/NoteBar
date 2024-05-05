//
//  NoteModel.swift
//  NoteBar
//
//  Created by Bora Mert on 16.04.2024.
//

import Foundation
import SwiftUI

struct Note: Identifiable, Codable{
    var id = UUID()
    
    var title: String
    var note: String
    var richText: Data
    var date: Date
}
