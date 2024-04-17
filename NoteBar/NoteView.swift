import SwiftUI

struct NoteView: View {
    @Binding var note: Note
    @Binding var notes: [Note]
    @Binding var isShowingNoteView: Bool // This binding controls the visibility
    @State private var newTitle: String
    @State private var newText: String
    
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
            
            TextField("Write here...", text: $newText, axis: .vertical)
                .scrollContentBackground(.hidden)
                .font(.system(size: 15))
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .textFieldStyle(PlainTextFieldStyle())
            
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

// Usage
struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(
            note: .constant(Note(title: "New Note", note: "Lorem", date: Date.now)),
            notes: .constant([Note(title: "Existing Note", note: "Details", date: Date.now)]),
            isShowingNoteView: .constant(true))
    }
}
