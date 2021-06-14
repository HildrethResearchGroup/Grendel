//
//  ContentView.swift
//  Shared
//
//  Created by Team Illus-tree-ous (Mines CS Field Session) on 5/24/21.
//

import SwiftUI

var document: Binding<OutlinerDocument>?

struct ContentView: View {
    
    init(_ doc: Binding<OutlinerDocument>) {
        document = doc
    }
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                DragBar(tree: document!.wrappedValue.tree)
                    .frame(width: geo.size.width, height: 20)
                ScrollView([.vertical, .horizontal]) {
                    
                    TreeView(outlinerDocument: document!.wrappedValue)
                        .padding()
                        .toolbar(content: {
                            Toolbar()
                        })
                        .focusable()
                        .frame(minWidth: geo.size.width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                               minHeight: geo.size.height, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                               alignment: .topLeading)
                }.onTapGesture {
                    document!.wrappedValue.deselectAll()
                }
            }
        }
    }
}
