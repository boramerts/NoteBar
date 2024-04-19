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
                    Text(note.title)
                        .font(.title3)
                        .padding(.bottom,1)
                        .fontWeight(.semibold)
                    Text(note.date.formatted(.dateTime.day().month(.abbreviated).hour().minute()))
                        .padding(.trailing)
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Text(note.note)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 10,height: 15)
                .padding()
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .padding(.leading,10)
        .padding(.trailing,-4)
        .padding(.top,2)
        .padding(.bottom,2)
    }
}

#Preview {
    CardView(note: .constant(Note(title: "Note", note:"Lorem ipsum falan filanjnljnljbljbljbljbljbljbljblnnşknşknkşkşnşknk\n nşşknknşşknnkşnşnknkşşknnkşknkşkşn", date: Date.now)))
}
