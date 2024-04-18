//
//  NoteStore.swift
//  NoteBar
//
//  Created by Bora Mert on 16.04.2024.
//

import Foundation

@MainActor
class NoteStore: ObservableObject {
    @Published var notes: [Note] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("myNotes.data")
    }
    
    func load() async throws {
        let fileURL = try Self.fileURL()

        // Check if the file exists before attempting to load data
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("No file exists at \(fileURL), initializing new notes")
            self.notes = [] // Initialize with an empty array or default notes
            return // Return early since there is no data to load
        }

        // Since the file exists, load the data
        let data = try Data(contentsOf: fileURL)
        self.notes = try JSONDecoder().decode([Note].self, from: data)
        print("Loaded notes: \(self.notes)")
    }
    
    func save() async throws {
        guard !notes.isEmpty else {
            print("No notes to save.")
            return
        }
        do {
            let data = try JSONEncoder().encode(notes)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
            print("Notes saved successfully to \(outfile)")
        } catch {
            print("Failed to save notes: \(error)")
            throw error
        }
    }
}
