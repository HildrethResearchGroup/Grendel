//
//  ContentView.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: OutlinerDocument
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(spacing: 0){
                DragBar()
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


var barList : [dragDivider] = []





struct DragBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    var tree: Tree

    init() {
        tree = Tree()
        
        // TODO: remove below, was test code only
        let nodeA = Node<String>(content: "A")
        tree.move(nodeA, toParent: tree.rootNode, at: 0)
        let nodeAB = Node<String>(content: "AB")
        tree.move(nodeAB, toParent: nodeA, at: 0)
        let nodeABC = Node<String>(content: "ABC")
        tree.move(nodeABC, toParent: nodeAB, at: 0)
        let nodeAC = Node<String>(content: "AC")
        tree.move(nodeAC, toParent: nodeA, at: 1)
        let nodeACD = Node<String>(content: "ACD")
        tree.move(nodeACD, toParent: nodeAC, at: 0)
        let nodeAA = Node<String>(content: "AA")
        tree.move(nodeAA, toParent: nodeA, at: 0)
        let nodeB = Node<String>(content: "B")
        tree.move(nodeB, toParent: tree.rootNode, at: 1)
        let nodeX = Node<String>(content: "X")
        tree.move(nodeX, toParent: nodeAA, at: 0)
        let nodeY = Node<String>(content: "Y")
        tree.move(nodeY, toParent: nodeX, at: 0)
        
        tree.findMaxDepth()
    }
    
    
    
    var body: some View {
        
        createBarList(tree: tree)
        
        return ZStack(){
            Rectangle()
                .opacity(0)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(colorScheme == .dark ? Color.black: Color.white), alignment: .bottom)
            
            GeometryReader{ geometry in
                HStack(){
                    ForEach(0..<tree.levelWidths.count, id: \.self){dividerNumber in
                        barList[dividerNumber]
                            .offset(x: geometry.size.width * tree.levelWidths[dividerNumber])//, y: geometry.size.height*0.5)
                        
                    }
                }
            }
        }
    }
    
    func createBarList(tree: Tree) {
        let range = 0 ..< tree.levelWidths.count
        
        for i in range{
            barList.insert(dragDivider(tree: tree, dividerNumber: i), at: i)
        }
    }
}

struct dragDivider : View{
    @State private var viewState = CGSize.zero
    @Environment(\.colorScheme) var colorScheme
    
    var tree: Tree
    var dividerNumber : Int
    
    var body: some View{
        GeometryReader{ geometry in
            //var level: CGFloat = 0.2
            ZStack{
            
            Divider()
                Rectangle()
                    .frame(width: 20)
                    .opacity(0.00000000000001)
               
                .foregroundColor(colorScheme == .dark ? Color.black: Color.white)
                
        }
            .offset(x: viewState.width, y: viewState.height)
            .gesture(
                DragGesture().onChanged { value in
                    viewState = CGSize(width: value.location.x, height: 0)
                }
                .onEnded { value in
                   
                        //viewState = .zero
                    print(viewState.width / geometry.size.width)
                    
                    let range = dividerNumber ..< tree.levelWidths.count
                    
                    for i in range {
                        tree.levelWidths[i] = 0.2 + viewState.width / geometry.size.width
                        barList[i].changeViewState(width: viewState.width)
                    }
                    
                    print(tree.levelWidths)
                    print(viewState.width / geometry.size.width)
                    
                    //repositionBars(tree: tree, width: geometry.size.width)
                    
                }
            )
            
        }
    }
    
//    func repositionBars (tree : Tree, width: CGFloat) {
//
//
//            let divider = 0..<barList.count
//            for i in divider{
//                barList[i]
//                    .offset(x:width * tree.levelWidths[i])
//
//        }
//
//    }
    
    func changeViewState (width: CGFloat){
        viewState = CGSize(width: width, height: 0)
        
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(document: .constant(OutlinerDocument()))
        }
    }
}

