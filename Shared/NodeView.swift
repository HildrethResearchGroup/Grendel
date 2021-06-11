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
    var ts: Node<String>.TextSettings
    init(node: Node<String>) {
        self.node = node
        ts = node.textSettings
    }
    
    
    
    
    
    var body: some View {

            TextEditor(text: $node.content)
                .onChange(of: node.content){value in
                    if value.contains("\n"){
                        node.content = value.replacingOccurrences(of: "\n", with: "")
                    }
                }
//            .if(ts.isUnderlined) { view in
//                view.underline()
//            }

            .font(ts.getFont())
                .foregroundColor(ts.foregroundColor)
            .frame(minWidth: nil, idealWidth: 100.0, maxWidth: nil, minHeight: 20.0, idealHeight: nil, maxHeight: nil, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(ts.highlightColor ?? Color.blue)
            )
        .fixedSize(horizontal: false, vertical: true)
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
