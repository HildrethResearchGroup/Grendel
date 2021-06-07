//
//  ContentView.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: OutlinerDocument
    
    var body: some View {
        GeometryReader { geo in
            ScrollView([.vertical, .horizontal]) {
                TreeView()
                    .frame(minWidth: geo.size.width, minHeight: geo.size.height, alignment: .topLeading)
                    .toolbar(content: {
                        Toolbar()
                    })
                    .focusable()
                    .padding()
            }
        }
        .background(Color.white)
    }
}

//Toolbar functions
func deleteAction() {
    print("Deleted")
}

func addItemAction() {
    print("Added Item")
}

func addChildAction() {
    print("Add Child")
}

func indentAction() {
    print("Indented")
}

func outdentAction() {
    print("outdented")
}

func editAction() {
    print("Edit")
}

func toggleAction() {
    print("Toggled")
}

func labelAction() {
    print("Labled")
}

func colorAction() {
    print("Colored")
}

func fontAction() {
    print("Change font")
}

struct Toolbar: View {
    var body: some View {
        // main buttons to modify the model
        //FIXME: Enter doesn't work in full screen
        HStack(alignment: .center) {
            ActionButton(imageName: "DeleteItem", label: "Delete item(s)", customAction: deleteAction)
            .keyboardShortcut(.delete, modifiers: [.shift])
            ActionButton(imageName: "AddItem", label: "Add item", customAction: addItemAction)
            .keyboardShortcut(.return, modifiers: [])
            ActionButton(imageName: "AddChild", label: "Add child", customAction: addChildAction)
            .keyboardShortcut(.return, modifiers: [.shift])
            ActionButton(imageName: "Indent", label: "Indent", customAction: indentAction)
            .keyboardShortcut(.tab, modifiers: [])
            ActionButton(imageName: "Outdent", label: "Outdent", customAction: outdentAction)
            .keyboardShortcut(.tab, modifiers: [.shift])
        }
        Spacer()
        HStack(alignment: .bottom){
            ActionButton(imageName: "pencil", label: "Edit Note", customAction: editAction)
            ActionButton(imageName: "eye", label: "Toggle Children", customAction: toggleAction)
            ActionButton(imageName: "eyedropper", label: "Label", customAction: labelAction)
        }
        Spacer()
        HStack(alignment: .bottom){
            ActionButton(imageName: "paintbrush.fill", label: "Colors", customAction: colorAction)
            ActionButton(imageName: "character", label: "Font", customAction: fontAction)
        }
    }
}


//ActionButton is the struct used to create the toolbar buttons. It takes in the image name, the label, and the toolbar action that it represents.
struct ActionButton: View {
    var imageName: String
    var label: String
    var customAction: () -> Void
    
    var body: some View {
        Button(action: customAction, label: {
            Image(imageName)
                //.font(.title)
                .resizable()
                .scaledToFit()
                .frame(width: 25.0, height: 25.0)
        })
        .help(label)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(OutlinerDocument()))
            
    }
}

