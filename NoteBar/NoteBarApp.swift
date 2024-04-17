//
//  NoteBarApp.swift
//  NoteBar
//
//  Created by Bora Mert on 16.04.2024.
//

import SwiftUI

@main
struct NoteBarApp: App {
    @StateObject private var store = NoteStore()
    
    var body: some Scene {
        MenuBarExtra("NoteBar", systemImage: "note.text") {
            ContentView(notes: $store.notes) {
                Task {
                    do {
                        try await store.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }.environmentObject(store)
                .task{
                    do {
                        try await store.load()
                    }   catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }.menuBarExtraStyle(.window)
    }
}
