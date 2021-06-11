//
//  NodeView.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/7/21.
//

import SwiftUI

struct NodeView: View {
    var node: Node<String>
    var ts: Node<String>.TextSettings
    
    init(node: Node<String>) {
        self.node = node
        ts = self.node.textSettings
    }
    
    var body: some View {
        Text(node.content)
            .if(ts.isUnderlined) { view in
                view.underline()
            }
            .padding()
            .font(ts.getFont())
            .foregroundColor(ts.foregroundColor)
            .frame(width: 100.0, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(ts.highlightColor ?? Color.blue)
            )
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
