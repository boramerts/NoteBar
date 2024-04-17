//
//  EmptyListView.swift
//  NoteBar
//
//  Created by Bora Mert on 16.04.2024.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        VStack{
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
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(width: 80,height: 80)
                .foregroundColor(.yellow)
        }
        .frame(width: 300, height: 400)
    }
}

#Preview {
    EmptyListView()
}
