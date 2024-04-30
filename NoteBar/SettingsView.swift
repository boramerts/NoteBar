//
//  SettingsView.swift
//  NoteBar
//
//  Created by Bora Mert on 21.04.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @Binding var isShowingSettings: Bool
    
    private var headTextColor: Color {
        if settingsStore.themeColor == .white
        {
            return .black
        } else
        {
            return .white
        }
    }

    var body: some View {
        VStack{
            HStack {
                Button(action: {isShowingSettings = false}) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .fontWeight(.bold)
                        .frame(width: 10, height: 15)
                        .foregroundColor(headTextColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                Spacer()
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(headTextColor)
            }
            .padding()
            .background(settingsStore.themeColor)
            Spacer()
            Form {
                Picker("Theme Color", selection: $settingsStore.settings.themeColor) {
                    Text("Yellow").tag("yellow")
                    Text("White").tag("white")
                    Text("Gray").tag("gray")
                }
                .pickerStyle(InlinePickerStyle())
            }
            .padding()
            .onChange(of: settingsStore.settings.themeColor) { newValue in
                print("Theme color changed to \(newValue)")
            }
            .onDisappear {
                Task {
                    do {
                        try await settingsStore.saveSettings()
                        print("Saved Settings")
                    } catch {
                        print("Failed to save settings: \(error)")
                    }
                }
            }
            Spacer()
        }
        .frame(width: 300, height: 400)
    }
}
#Preview {
    SettingsView(isShowingSettings: .constant(true))
        .environmentObject(SettingsStore())
}
