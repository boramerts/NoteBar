import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: NoteStore
    @Binding var notes: [Note]
    @State private var showingNoteView: Bool = false
    @State private var selectedNote: Note?
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: () -> Void
    
    var body: some View {
        VStack {
            if showingNoteView, let selectedNote = selectedNote, let index = notes.firstIndex(where: { $0.id == selectedNote.id }) {
                NoteView(note: $notes[index], notes: $notes, isShowingNoteView: $showingNoteView)
            } else {
                if notes.isEmpty {
                    EmptyListBody
                } else {
                    mainContentView
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                print("App is inactive. Saving notes.")
                Task {
                    do {
                        try await store.save()
                    } catch {
                        print("Failed to save notes on app deactivation: \(error)")
                    }
                }
            }
        }
    }
    
    var EmptyListBody: some View {
        VStack(alignment:.center){
            HStack {
                Text("NoteBar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(alignment: .leading)
                Spacer()
                Button(action: addNewNote) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color.yellow)
            
            Spacer()
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(width: 80,height: 80)
                .foregroundColor(.yellow)
                .fontWeight(.bold)
                .padding()
            
            Text("Welcome to NoteBar!\nPress + to start writing.")
            
            Spacer()
            Divider()
            
            Button("Quit NoteBar") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.bottom, 15)
        }
        .frame(width: 300, height: 400)
    }
    
    var mainContentView: some View {
        VStack {
            HStack {
                Text("NoteBar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(alignment: .leading)
                Spacer()
                Button(action: addNewNote) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color.yellow)
            
            List($notes, id: \.id) { $note in
                Button(action: {
                    self.selectedNote = note
                    self.showingNoteView = true
                }) {
                    CardView(note: $note)
                }.buttonStyle(BorderlessButtonStyle()).foregroundColor(.white)
            }.padding(-10).scrollContentBackground(.hidden)
            
            Divider()
            
            Button("Quit NoteBar") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.bottom, 15)
        }
        .frame(width: 300, height: 400)
    }
    
    private func addNewNote() {
        let newNote = Note(title: "", note: "", date: Date())
        notes.append(newNote)
        selectedNote = newNote
        showingNoteView = true
    }
}

// Preview for development purposes
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(notes: .constant([Note(title: "New Note", note: "Test note string etc. bla bla", date: Date.now)]), saveAction: {})
    }
}
