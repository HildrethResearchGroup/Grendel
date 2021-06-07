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
        Text("Tree goes here")
            .font(.title)
            .frame(minWidth: 400, idealWidth: 600, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity, alignment: .center)
            .toolbar(content: {
                Toolbar()
            })
            .focusable()
    }
}

//Toolbar functions
func viewAction() {
    print("Switch between tree and list view")
}

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
    @State private var view = 0
    var body: some View {
        // main buttons to modify the model
        //FIXME: Enter doesn't work in full screen
//        ActionPicker(imageNames: ["ListView", "TreeView"], labels: ["List View", "Tree View"], customAction: viewAction)
        HStack(alignment: .center) {
            ActionButton(imageName: "ListView", label: "List View", customAction: viewAction)
            ActionButton(imageName: "TreeView", label: "Tree View", customAction: viewAction)
        }
        Spacer()
        HStack(alignment: .center) {
            ActionButton(imageName: "DeleteItem", label: "Delete Item(s)", customAction: deleteAction)
                .shadow(radius: 1)
                .keyboardShortcut(.delete, modifiers: [.shift])
            ActionButton(imageName: "AddItem", label: "Add Item", customAction: addItemAction)
                .shadow(radius: 1)
                .keyboardShortcut(.return, modifiers: [])
            ActionButton(imageName: "AddChild", label: "Add Child", customAction: addChildAction)
                .shadow(radius: 1)
                .keyboardShortcut(.return, modifiers: [.shift])
            ActionButton(imageName: "Indent", label: "Indent", customAction: indentAction)
                .shadow(radius: 1)
                .keyboardShortcut(.tab, modifiers: [])
            ActionButton(imageName: "Outdent", label: "Outdent", customAction: outdentAction)
                .shadow(radius: 1)
                .keyboardShortcut(.tab, modifiers: [.shift])
            ActionButton(imageName: "ToggleFamily", label: "Toggle Family", customAction: toggleAction)
                .shadow(radius: 1)
        }
        //HStack(alignment: .bottom){
            //ActionButton(imageName: "pencil", label: "Edit Note", customAction: editAction)
            //ActionButton(imageName: "label", label: "label", customAction: labelAction)
        //}
        Spacer()
        HStack(alignment: .bottom){
            ActionButton(imageName: "Colors", label: "Colors", customAction: colorAction)
            ActionButton(imageName: "Fonts", label: "Fonts", customAction: fontAction)
        }
    }
}


/**
 ActionButton is the struct used to create toolbar buttons.
 
 - Parameters:
    - imageName: The name of the image in assets
    - label: The name of the button action
    - customAction: The toolbar action that is represented
 */
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

/**
 ActionPicker is the struct used to create toolbar segmented controls.

 - Parameters:
    - imageNames: The names of the images in assets
    - labels: The names of the options
    - customAction: The toolbar action that is represented
 */
struct ActionPicker: View {
    var imageNames: 
    var labels: [String]
    var customAction: () -> Void
    
    var body: some View {
        var choice = labels[0] // the user's current selection, default is the first item
        HStack { // horizontal controls
            Picker(selection: $imageNames, label: Text("What is your favorite color?")) {
                    ForEach(labels, id: \.self) {
                        Image($0)
                            //.font(.title)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25.0, height: 25.0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

            Text("Value: \($imageNames)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(OutlinerDocument()))
    }
}

