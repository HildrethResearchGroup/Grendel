//
//  ContentView.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI

var tree: Tree = Tree()

struct ContentView: View {
    @Binding var document: OutlinerDocument
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            TreeView()
                .toolbar(content: {
                    Toolbar()
                })
                .focusable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

//Toolbar functions
func deleteAction() {
    let selected = tree.getSelectedArray()
    for node in selected{
        node.getParent().removeChild(child: node)
    }
}

func addItemAction() {
    if(tree.getNumSelected() != 1){
        print("Could not add Node")
    }else{
        let selected = tree.getSelectedArray()[0]
        let tempNode = Node<String>(content: "")
        tree.move(tempNode, toParent: selected.getParent(), at: 0)
    }
    
}

func addChildAction() {
    if(tree.getNumSelected() != 1){
        print("Could not add Child Node")
    }else{
        let selected = tree.getSelectedArray()[0]
        let tempNode = Node<String>(content: "")
        tree.move(tempNode, toParent: selected, at: 0)
    }
}

func indentAction() {
    let selected = tree.getSelectedArray()
    for node in selected{
        tree.indent(node: node)
    }
}

func outdentAction() {
    let selected = tree.getSelectedArray()
    for node in selected{
        tree.outdent(node: node)
    }
}

func editAction() {
    print("Edit")
}

func toggleAction() {
    let selected = tree.getSelectedArray()
    for node in selected{
        node.childrenShown = false
    }
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

