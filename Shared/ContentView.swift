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
func treeViewAction() {
    print("Switch between tree and list view")
}

func listViewAction() {
    print("Switch between tree and list view")
}

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

func textAction() {
    print("Change font")
}

struct Toolbar: View {
    @State private var view = 0
    var body: some View {
        // main buttons to modify the model
        //FIXME: Enter doesn't work in full screen
//        ActionPicker(imageNames: ["ListView", "TreeView"], labels: ["List View", "Tree View"], customAction: viewAction)
//        HStack(alignment: .center) {
//            ActionButton(imageName: "ListView", label: "List View", customAction: viewAction)
//            ActionButton(imageName: "TreeView", label: "Tree View", customAction: viewAction)
//        }
        ViewPicker()
        Spacer()
        HStack(alignment: .center) {
            ActionButton(imageName: "DeleteItem", title: "Delete Item(s)", help: "Delete", customAction: deleteAction)
                .shadow(radius: 1)
                .keyboardShortcut(.delete, modifiers: [.shift])
            ActionButton(imageName: "AddItem", title: "Add Item", help: "Add an item", customAction: addItemAction)
                .shadow(radius: 1)
                .keyboardShortcut(.return, modifiers: [])
            ActionButton(imageName: "AddChild", title: "Add Child", help: "Add a child", customAction: addChildAction)
                .shadow(radius: 1)
                .keyboardShortcut(.return, modifiers: [.shift])
            ActionButton(imageName: "Indent", title: "Indent", help: "Indent", customAction: indentAction)
                .shadow(radius: 1)
                .keyboardShortcut(.tab, modifiers: [])
            ActionButton(imageName: "Outdent", title: "Outdent", help: "Outdent", customAction: outdentAction)
                .shadow(radius: 1)
                .keyboardShortcut(.tab, modifiers: [.shift])
            ActionButton(imageName: "ToggleFamily", title: "Toggle Family", help: "Toggle family", customAction: toggleAction)
                .shadow(radius: 1)
        }
        //HStack(alignment: .bottom){
            //ActionButton(imageName: "pencil", label: "Edit Note", customAction: editAction)
            //ActionButton(imageName: "label", label: "label", customAction: labelAction)
        //}
        Spacer()
        HStack(alignment: .bottom){
            ActionButton(imageName: "Colors", title: "Colors", help: "Choose text color", customAction: colorAction)
            ActionButton(imageName: "Text", title: "Text", help: "Choose text style", customAction: textAction)
        }
    }
}


/**
 ActionButton is the struct used to create toolbar buttons.
 
 - Parameters:
    - imageName: The name of the image in assets
    - title: The name of the button
    - help: The help tag for the button
    - customAction: The toolbar action that is represented
 */
struct ActionButton: View {
    var imageName: String
    var title: String
    var help: String
    var customAction: () -> Void
    
    var body: some View {
        Button(action: customAction, label: {
            Image(imageName, label: Text(title))
                //.font(.title)
                .resizable()
                .scaledToFit()
                .frame(width: 25.0, height: 25.0)
        })
        .help(help)
    }
}

/**
 ViewPicker is the struct used to create toolbar segmented controls for viewing the document as a tree or list.
 */
struct ViewPicker: View {
    
    private enum ViewNotes: String, CaseIterable, Identifiable {
        case tree
        case list

        var id: String { self.rawValue }
        
        var viewAction: () {
            switch self {
            case .tree: return treeViewAction()
            case .list: return listViewAction()
            }
        }
    }
    
    @State private var selectedView = ViewNotes.tree
    @State private var selectedAction: () = treeViewAction()
    
    var body: some View {
        HStack { // horizontal controls
            Picker("View", selection: $selectedView) {
                /// TODO: get the picker selection with \($selectedView) or \($selectedAction) and bind to the func to change how the document is drawn
                Image("TreeView", label: Text("Tree View"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25.0, height: 25.0)
                    .tag(ViewNotes.tree)
                    .help("View notes as tree") /// TODO: fix why the help tags don't display in the picker?
                Image("ListView", label: Text("List View"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25.0, height: 25.0)
                    .tag(ViewNotes.list)
                    .help("View notes as list")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(OutlinerDocument()))
            
    }
}

