//
//  CardView.swift
//  NoteBar
//
//  Created by Bora Mert on 16.04.2024.
//

import SwiftUI

struct CardView: View {
    @Binding var note: Note
    
    public init(note: Binding<Note>) {
        self._note = note
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    Text(note.title).font(.title3).padding(.bottom,1).fontWeight(.semibold)
                    Spacer()
                    Text(note.date.formatted(.dateTime.day().month(.abbreviated).hour().minute())).padding(.trailing).font(.caption).foregroundColor(.secondary)
                }
                Text(note.note).foregroundColor(.secondary).font(.caption)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 10,height: 15)
                .padding()
                .fontWeight(.bold)
        }
        .padding(.leading,10).padding(.trailing,10).padding(.top,2).padding(.bottom,2)
    }
}

#Preview {
    CardView(note: .constant(Note(title: "Note", note: "Lorem ipsum falan filanjnljnljbljbljbljbljbljbljblnnşknşknkşkşnşknknşşknknşşknnkşnşnknkşşknnkşknkşkşn", date: Date.now)))
}
