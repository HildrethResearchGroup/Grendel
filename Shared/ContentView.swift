//
//  ContentView.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI

var tree: Tree  = Tree()

struct ContentView: View {
    @Binding var document: OutlinerDocument
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(spacing: 0){
                DragBar(tree: tree)
                    .frame(width: geometry.size.width, height: geometry.size.height*0.03)
                Text("Tree Goes Here")
                    .font(.title)
                    .frame(minWidth: 400, idealWidth: 600, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity, alignment: .center)
                    .toolbar(content: {
                        Toolbar()
                    })
                    .focusable()
                
                
            }
            
        }
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
//TODO: Remove edit
func editAction() {
    print("Edit")
}

func toggleAction() {
    print("Toggled")
}

func labelAction() {
    print("Labled")
}
//TODO: Remove color
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
            ActionButton(imageName: "Outdent", label: "Edit Note", customAction: editAction)
            ActionButton(imageName: "Outdent", label: "Toggle Children", customAction: toggleAction)
            ActionButton(imageName: "Outdent", label: "Label", customAction: labelAction)
        }
        Spacer()
        HStack(alignment: .bottom){
            ActionButton(imageName: "Outdent", label: "Colors", customAction: colorAction)
            ActionButton(imageName: "Outdent", label: "Font", customAction: fontAction)
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
                .resizable()
                .scaledToFit()
                .frame(width: 25.0, height: 25.0)
                .shadow(radius: 5)
        })
        .help(label)
    }
}

//The Preview for SwiftUI
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ContentView(document: .constant(OutlinerDocument()))
//        }
//    }
//}
