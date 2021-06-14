//
//  NodeView.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/7/21.
//

import SwiftUI

//Makes the TextEditor background clear so that the background can correctly show through.

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }
        
    }
}


struct NodeView: View {
    @ObservedObject var node: Node<String>
    @State var shown: Bool = true
    @ObservedObject var ts: Node<String>.TextSettings
    var width: CGFloat
    var radius: CGFloat
    
    init(node: Node<String>, width: CGFloat, radius: CGFloat = 5) {
        self.node = node
        self.width = width
        self.radius = radius
        self.ts = node.textSettings
    }
    
    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: radius)
//                .fill(ts.highlightColor ?? .accentColor)
            TextEditor(text: $node.content)
                .onChange(of: node.content){value in
                    
                    //Detects when enter is pressed and takes the user out of the textEditor.
                    shown = true
                    document!.wrappedValue.deselectAll()
                    node.selected = true
                    if value.contains("\n"){
                        node.content = value.replacingOccurrences(of: "\n", with: "")
                        shown = false
                    }
                    if value.contains("\t"){
                        node.content = value.replacingOccurrences(of: "\t", with: "")
                        shown = false
                    }
                }
                
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                .font(ts.getFont())
                .foregroundColor(ts.foregroundColor)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 5.0)
                        .fill(ts.highlightColor ?? Color("Default"))
                )
                .fixedSize(horizontal: false, vertical: true)
                .if(!shown){view in
                    view.disabled(shown)
                }
//        }
        .frame(minWidth: width, idealWidth: width, maxWidth: width, minHeight: 20.0, idealHeight: nil, maxHeight: nil, alignment: .top)
    }
}


// allows for easy application of view modifiers based on a condition
// source: https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    // Applies the given transform if the given condition evaluates to true.
    // - Parameters:
    //   - condition: The condition to evaluate.
    //   - transform: The transform to apply to the source `View`.
    // - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
