//
//  ContentView.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI

func customAction() {
    print("Hello, world")
}

struct ContentView: View {
    @Binding var document: OutlinerDocument
    
    var body: some View {
        Text("Tree goes here")
            .font(.title)
            .frame(minWidth: 400, idealWidth: 600, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 300, idealHeight: 400, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            .toolbar(content: {
                // main buttons to modify the model
                HStack(alignment: .bottom) {
                    ActionButton(imageName: "text.badge.minus", label: "Delete item(s)", customAction: customAction)
                        .keyboardShortcut(.delete, modifiers: [])
                    ActionButton(imageName: "text.badge.plus", label: "Add item", customAction: customAction)
                        .keyboardShortcut(.return, modifiers: [])
                    ActionButton(imageName: "text.badge.star", label: "Add child", customAction: customAction)
                        .keyboardShortcut(.return, modifiers: [.shift])
                    ActionButton(imageName: "arrow.right.to.line", label: "Indent", customAction: customAction)
                        .keyboardShortcut(.tab, modifiers: [])
                    ActionButton(imageName: "arrow.left.to.line", label: "Outdent", customAction: customAction)
                        .keyboardShortcut(.tab, modifiers: [.shift])
                }
            })
            .focusable()
    }
}

struct ActionButton: View {
    var imageName: String
    var label: String
    var customAction: () -> Void

    var body: some View {
        Button(action: customAction, label: {
            Image(systemName: imageName)
                .font(.title)
        })
        .help(label)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(OutlinerDocument()))
    }
}
