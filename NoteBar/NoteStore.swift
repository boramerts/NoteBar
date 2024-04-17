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
        guard let data = try? Data(contentsOf: fileURL) else {
            print("No data found at \(fileURL)")
            return
        }
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
