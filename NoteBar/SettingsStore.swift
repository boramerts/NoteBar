//
//  SettingsStore.swift
//  NoteBar
//
//  Created by Bora Mert on 21.04.2024.
//

import Foundation
import SwiftUI

@MainActor
class SettingsStore: ObservableObject {
    @Published var settings: UserSettings = UserSettings(themeColor: "yellow") // Default color

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("userSettings.data")
    }
    
    func loadSettings() async throws {
        let fileURL = try Self.fileURL()

        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            settings = try JSONDecoder().decode(UserSettings.self, from: data)
        } else {
            print("Settings file not found, using default settings.")
        }
    }
    
    func saveSettings() async throws {
        let data = try JSONEncoder().encode(settings)
        let outfile = try Self.fileURL()
        try data.write(to: outfile)
    }
}

extension SettingsStore {
    var themeColor: Color {
        switch settings.themeColor {
        case "yellow":
            return .yellow
        case "white":
            return .white
        case "gray":
            return .gray
        default:
            return .yellow // Default case
        }
    }
}
