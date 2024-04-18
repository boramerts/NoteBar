import SwiftUI

struct NoteView: View {
    @Binding var note: Note
    @Binding var notes: [Note]
    @Binding var isShowingNoteView: Bool // This binding controls the visibility
    @State private var newTitle: String
    @State private var newText: String
    @State private var isList = false
    
    public init(note: Binding<Note>, notes: Binding<[Note]>, isShowingNoteView: Binding<Bool>) {
        self._note = note
        self._notes = notes
        self._isShowingNoteView = isShowingNoteView
        self._newTitle = State(initialValue: note.wrappedValue.title)
        self._newText = State(initialValue: note.wrappedValue.note)
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
            
            RichTextEditor(text: $newText, isList: $isList).padding(.horizontal,10)
            
            Spacer()
            
//            TextEditor(text: $newText)
//                .font(.body)
//                .padding()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .scrollContentBackground(.hidden)
//                .onChange(of: isList) { isListEnabled in
//                    if isListEnabled {
//                        // If isList is true, insert a bullet point at the start of the text
//                        DispatchQueue.main.async {
//                            if !self.newText.starts(with: "\u{2022} ") {
//                                self.newText = "\u{2022} " + self.newText
//                            }
//                        }
//                    } else {
//                        // If isList is false, remove the bullet point from the start of the text
//                        DispatchQueue.main.async {
//                            if self.newText.starts(with: "\u{2022} ") {
//                                self.newText.removeFirst(2) // Remove the bullet and the space
//                            }
//                        }
//                    }
//                }
//                .onChange(of: newText) { newNoteText in
//                    guard isList else { return }
//                    // If there is a new line and `isList` is enabled, add a bullet point
//                    if newText.hasSuffix("\n") {
//                        DispatchQueue.main.async {
//                            self.newText.append("\u{2022} ")
//                        }
//                    }
//                }
            
            Divider()
            HStack{
                Toggle(isOn: $isList, label: { Label("List", systemImage: "list.bullet") })
                    .toggleStyle(.button)
                
                Button(action:{isList.toggle()}){
                    Image(systemName: "list.bullet")
                }.buttonStyle(BorderlessButtonStyle())
                Spacer()
                Button("Quit NoteBar") {
                    NSApplication.shared.terminate(nil)
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.horizontal).padding(.vertical,5)
            
            
            
            Spacer()
        }
        .frame(width: 300, height: 400)
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
        note.date = Date()
        
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        notes[index] = note  // Reinforce the update
        isShowingNoteView = false
        print("Note updated and view closed.")
    }
}


struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(
            note: .constant(Note(title: "New Note", note: "New Note", date: Date.now)),
            notes: .constant([Note(title: "Existing Note", note: "Details", date: Date.now)]),
            isShowingNoteView: .constant(true))
    }
}
