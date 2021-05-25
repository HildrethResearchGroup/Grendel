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
        TextEditor(text: $document.text)
            .toolbar(content: {
                // main buttons to modify the model
                // FIXME: find a better way to align icons?
                HStack(alignment: .bottom) {
                    ActionButton(imageName: "text.badge.minus", label: "Delete item(s)", customAction: customAction)
                    ActionButton(imageName: "text.badge.plus", label: "Add item", customAction: customAction)
                    ActionButton(imageName: "text.badge.star", label: "Add child", customAction: customAction)
                    ActionButton(imageName: "arrow.right.to.line", label: "Indent", customAction: customAction)
                    ActionButton(imageName: "arrow.left.to.line", label: "Outdent", customAction: customAction)
                }
            })
    }
}

struct ActionButton: View {
    var imageName: String
    var label: String
    var customAction: () -> Void

    var body: some View {
        Button(action: customAction, label: {
            VStack(spacing: 5) {
                Image(systemName: imageName)
                    .font(.body)
                Text(label)
                    .font(.body)
            }
            .frame(minWidth: 15, idealWidth: 64, maxWidth: 64, minHeight: 15, idealHeight: 40, maxHeight: 40)
        }).buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(OutlinerDocument()))
    }
}
