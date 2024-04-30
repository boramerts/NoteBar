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
    @StateObject private var settingsStore = SettingsStore()

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
            }
            .environmentObject(store)
            .environmentObject(settingsStore)
            .task {
                do {
                    try await store.load()
                    try await settingsStore.loadSettings()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }.menuBarExtraStyle(.window)
    }
}
