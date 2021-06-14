//
//  Toolbar.swift
//  Outliner
//
//  Created by Team Illus-tree-ous (Mines CS Field Session) on 6/14/21.
//

import SwiftUI

/**
 Displays the toolbar at the top, including main buttons and menus to modify the tree.
 */
struct Toolbar: View {
    @State private var view = 0
    var body: some View {
        // FIXME: Enter doesn't work in full screen.
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
            TextMenu()
            ColorMenu()
        }
    }
}

/**
 Creates a toolbar button.
 
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
                .resizable()
                .scaledToFit()
                .frame(width: 25.0, height: 25.0)
        })
        .help(help)
    }
}

/**
 Creates the color menu with a curated color palette and buttons for changing text and highlight colors.
 */
struct ColorMenu: View {
    @State private var showingPopover = false
    @State private var selection = "Default"
    // Default text color is white for dark mode and black for light mode
    
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
                    ActionButton(imageName: "TextColor", title: "Text Color", help: "Text color", customAction: { colorAction(colorString: selection) })
                    ActionButton(imageName: "Highlight", title: "Highlight", help: "Highlight color", customAction: { highlightAction(colorString: selection) })
                }
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(swatches, id: \.self) {swatch in
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

/**
 Creates the text formatting menu to bold, italicize, underline, and strikethrough text, and also change a node's font and size.
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
                // TODO: Add support for underline and strikethrough.
//                ActionButton(imageName: "Underline", title: "Underline", help: "Underline", customAction: underlineAction)
//                ActionButton(imageName: "Strikethrough", title: "Strikethrough", help: "Strikethrough", customAction: strikeAction)
            }
            .padding()
        }
        .help("Choose text style")
    }
}

/**
 Creates toolbar segmented controls for viewing the document as a tree or list.
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
        HStack {
            Picker("View", selection: $selectedView) {
                // TODO: Get the picker selection with \($selectedView) or \($selectedAction) and bind to the function to change how the nodes are displayed.
                Image("TreeView", label: Text("Tree View"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25.0, height: 25.0)
                    .tag(ViewNotes.tree)
                Image("ListView", label: Text("List View"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25.0, height: 25.0)
                    .tag(ViewNotes.list)
            }
            .pickerStyle(SegmentedPickerStyle())
            .help("View notes as tree or list")
        }
    }
}

// MARK: Tree Functions
func treeViewAction() {
    // print("Switch between to tree view")
}

func listViewAction() {
    // print("Switch between to list view")
}

func deleteAction() {
    document!.wrappedValue.deleteSelected()
}

func addItemAction() {
    print("newline shenanigans")
    document!.wrappedValue.newLine()
//    if(tree.getNumSelected() != 1) {
//        print("Could not add Node")
//    } else {
//        let selected = tree.getSelectedArray()[0]
//        let tempNode = Node<String>(content: "")
//        tree.move(tempNode, toParent: selected.getParent(), at: 0)
//    }
}

func addChildAction() {
    document!.wrappedValue.newChild()
}

func indentAction() {
    document!.wrappedValue.indentSelected()
}

func outdentAction() {
    document!.wrappedValue.outdentSelected()
}

func toggleAction() {
    document!.wrappedValue.toggleSelected()
}

// MARK: Editing Functions
func cutAction() {
    document!.wrappedValue.cutNodesSelected()
}

func copyAction() {
    document!.wrappedValue.copyNodesSelected()
}

func pasteAction() {
    document!.wrappedValue.pasteNodesSelected()
}

func duplicateAction() {
    document!.wrappedValue.duplicateSelected()
}

func selectAboveAction() {
    
}

func selectBelowAction() {
    
}

func selectChildrenAction() {
    document!.wrappedValue.selectAllChildrenOfSelected()
}

func selectParentAction() {
    document!.wrappedValue.selectAllParentsOfSelected()
}

// MARK: Formatting Functions
func boldAction() {
    document!.wrappedValue.boldSelected()
}

func italicAction() {
    document!.wrappedValue.italicizeSelected()
}

func underlineAction() {
    print("Unsupported: Underline a node")
}

func strikeAction() {
    print("Unsupported: Strikethrough a node")
}

func fontAction() {
    print("Unsupported: Change font of node")
}

func sizeAction() {
    print("Unsupported: Change text size of node")
}

// MARK: Color Functions
func colorAction(colorString: String) {
    document!.wrappedValue.colorSelected(colorString: colorString)
}

func highlightAction(colorString: String) {
    document!.wrappedValue.highlightSelected(colorString: colorString)
}

