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
            VStack(spacing: 0){
                DragBar(tree: tree)
                    .frame(width: geo.size.width, height: 20)
                ScrollView([.vertical, .horizontal]) {
                    
                    TreeView()
                        .padding()
                        .frame(minWidth: geo.size.width, minHeight: geo.size.height, alignment: .topLeading)
                        .toolbar(content: {
                            Toolbar()
                        })
                        .focusable()
                    
                }
            }
        }
        //.background(Color.white)
    }
}

// Tree Functions
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
    } else {
        let selected = tree.getSelectedArray()[0]
        let tempNode = Node<String>(content: "")
        tree.move(tempNode, toParent: selected.getParent(), at: 0)
    }
}

func addChildAction() {
    if(tree.getNumSelected() != 1){
        print("Could not add Child Node")
    } else {
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
//    //ColorControls()
//    var body: some View {
//        Button
//        Menu {
//            Button(action: {}, label: {
//                Image("Colors", label: Text("here"))
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 25.0, height: 25.0)
//            })
//            .help("test")
//        }
//    }
}

func highlightAction() {

}

func textAction() {
    print("Change font")
}

// Text Editing Functions

func boldAction() {
    print("Bold node")
}

func italicAction() {
    print("Italic node")
}

func underlineAction() {
    print("Underline node")
}

func strikeAction() {
    print("Strikethrough node")
}

func fontAction() {
    
}

func sizeAction() {
    
}

struct Toolbar: View {
    @State private var view = 0
    var body: some View {
        // main buttons to modify the model
        //FIXME: Enter doesn't work in full screen
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
        Spacer()
        HStack(alignment: .center){
//            ActionButton(imageName: "Colors", title: "Colors", help: "Choose text color", customAction: colorAction)
            //ActionButton(imageName: "Text", title: "Text", help: "Choose text style", customAction: textAction)
            TextMenu()
            ColorMenu()
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

struct ColorMenu: View {
    @State private var showingPopover = false
    @State private var selection = "Default"
    
    let swatches = [
        "Watermelon",
        "Pomegranate",
        "Plum",
        "Grape",
        "Blackberry",
        "Blueberry",
        "Sky",
        "RobinEgg",
        "CopperPatina",
        "Avocado",
        "GreenApple",
        "Lime",
        "Banana",
        "Mango",
        "Tangerine",
        "Persimmon",
        "Default",
        "LittleGray",
        "BigGray",
        "Inverted"
    ]

    let columns = [
        GridItem(.fixed(25), spacing: 5),
        GridItem(.fixed(25), spacing: 5),
        GridItem(.fixed(25), spacing: 5),
        GridItem(.fixed(25), spacing: 5)
    ]
    
    var body: some View {
        Button(action: {
                showingPopover = true
        }) {
            Image("Colors", label: Text("Colors"))
                .resizable()
                .scaledToFit()
                .frame(width: 25.0, height: 25.0)
        }
        .popover(isPresented: $showingPopover) {
            VStack {
                HStack {
                    ActionButton(imageName: "TextColor", title: "Text Color", help: "Text color", customAction: colorAction)
                    ActionButton(imageName: "Highlight", title: "Highlight", help: "Highlight color", customAction: highlightAction)
                }
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(swatches, id: \.self){ swatch in
                        Button(action: {
                            selection = swatch
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color(swatch))
                                    .frame(width: 21, height: 21)
                                    .padding(5)
                                
                                if selection == swatch {
                                    Circle()
                                        .stroke(Color(swatch), lineWidth: 2)
                                        .frame(width: 25, height: 25)
                                }
                            }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .padding()
        }
        .help("Choose text color")
    }
}

struct ColorSwatch: ButtonStyle {
    var swatch: String
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(swatch))
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
    }
}

/**
 TextMenu is the struct used to create the text formatting menu to bold, italicize, underline, and strikethrough text, and also change a node's font and size.
 */
struct TextMenu: View {
    
    @State private var showingPopover = false

    var body: some View {
        Button(action: {
                showingPopover = true
        }) {
            Image("Text", label: Text("Text"))
                .resizable()
                .scaledToFit()
                .frame(width: 25.0, height: 25.0)
        }
        .popover(isPresented: $showingPopover) {
            HStack {
                ActionButton(imageName: "Bold", title: "Bold", help: "Bold", customAction: boldAction)
                ActionButton(imageName: "Italic", title: "Italic", help: "Italic", customAction: italicAction)
                ActionButton(imageName: "Underline", title: "Underline", help: "Underline", customAction: underlineAction)
                ActionButton(imageName: "Strikethrough", title: "Strikethrough", help: "Strikethrough", customAction: strikeAction)
            }
            .padding()
//            Picker("Fonts"){
//                Button("Font", action: {})
//                Button("Font2", action: {})
//            }
        }
        .help("Choose text style")
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
                    //.help("View notes as tree") /// FIXME: why don't the help tags don't display for each option?
                Image("ListView", label: Text("List View"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25.0, height: 25.0)
                    .tag(ViewNotes.list)
                    //.help("View notes as list")
            }
            .pickerStyle(SegmentedPickerStyle())
            .help("View notes as tree or list")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(OutlinerDocument()))
            
    }
}

