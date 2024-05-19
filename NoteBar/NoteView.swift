import SwiftUI

struct NoteView: View {
    @Binding var note: Note
    @EnvironmentObject var settingsStore: SettingsStore
    @Binding var notes: [Note]
    @Binding var isShowingNoteView: Bool // This binding controls the visibility
    @State private var newTitle: String
    @State private var newText: String
    @State private var newRich: Data
    @State private var isList = false
    @State private var isBold = false
    @State private var isItalic = false

    private var headTextColor: Color {
        if settingsStore.themeColor == .white
        {
            return .black
        } else
        {
            return .white
        }
    }
    

    
    public init(note: Binding<Note>, notes: Binding<[Note]>, isShowingNoteView: Binding<Bool>) {
        self._note = note
        self._notes = notes
        self._isShowingNoteView = isShowingNoteView
        self._newTitle = State(initialValue: note.wrappedValue.title)
        self._newText = State(initialValue: note.wrappedValue.note)
        self._newRich = State(initialValue: note.wrappedValue.richText)
    }
    
    var body: some View {
        VStack{
            HStack{
                TextField("New Note", text: $newTitle) // Make title editable
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Button(action: deleteNote) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: saveNote) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 15)
            }.padding(.top, 20).padding(.bottom, 5)
            
            Divider()
            
            RichTextEditor(text: $newText, richText: $newRich, isList: $isList, isBold: $isBold, isItalic: $isItalic)
                .padding(.horizontal, 10)
            
            Spacer()
            
            Divider()
            HStack{
                Button(action:{isList.toggle()}){
                    Image(systemName: "list.bullet")
                        .foregroundColor(isList ? headTextColor : .secondary)
                }
                .buttonStyle(.borderedProminent)
                .tint(isList ? settingsStore.themeColor : .secondary)
                
                Button(action: {
                    isBold.toggle()
                    print("_________________\n isBold")
                    print(isBold)
                }) {
                    Image(systemName: "bold")
                        .foregroundColor(isList ? headTextColor : .secondary)
                }
                .buttonStyle(.borderedProminent)
                .tint(isBold ? settingsStore.themeColor : .secondary)
                
                Button(action: {
                    isItalic.toggle()
                    print("_________________\n isItalic")
                    print(isItalic)
                }) {
                    Image(systemName: "italic")
                        .foregroundColor(isList ? headTextColor : .secondary)
                }
                .buttonStyle(.borderedProminent)
                .tint(isItalic ? settingsStore.themeColor : .secondary)
                
                Spacer()
                Button("Quit NoteBar") {
                    NSApplication.shared.terminate(nil)
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.horizontal).padding(.vertical,5)
            
            
            
            Spacer()
        }
        .frame(width: 300, height: 400)
        .onAppear {
            // TODO: Keyboard shortcuts do not work after reopening saved note.
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
                if event.modifierFlags.contains(.command) && event.characters == "b" {
                    self.isBold.toggle()
                    return nil
                }
                if event.modifierFlags.contains(.command) && event.characters == "i" {
                    self.isItalic.toggle()
                    return nil
                }
                return event
            }
        }
    }
    
    private func deleteNote() {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
        }
        isShowingNoteView = false // Hide the note view
        print("Note deleted")
    }
    
    private func saveNote() {
        note.title = newTitle
        note.note = newText
        note.richText = newRich  // Ensure this line correctly updates the richText
        note.date = Date()
        
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        notes[index] = note
        
        print("Note saved. note.note:")
        print(note.note)
        
        isShowingNoteView = false
    }
}


struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(
            note: .constant(Note(title: "New Note", note: "New Note", richText: Data(), date: Date.now)),
            notes: .constant([Note(title: "Existing Note", note: "Details", richText: Data(), date: Date.now)]),
            isShowingNoteView: .constant(true))
        .environmentObject(SettingsStore())
    }
}
