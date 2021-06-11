//
//  NodeView.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/7/21.
//

import SwiftUI

struct NodeView: View {
    @ObservedObject var node: Node<String>
    var ts: Node<String>.TextSettings
    var width: CGFloat
    var radius: CGFloat
    
    init(node: Node<String>, width: CGFloat, radius: CGFloat = 5) {
        self.node = node
        self.width = width
        self.radius = radius
        self.ts = node.textSettings
    }
    
    var body: some View {
        Text(node.content)
            .if(ts.isUnderlined) { view in
                view.underline()
            }
            .padding()
            .font(ts.getFont())
            .if(ts.foregroundColor != nil) { view in
                view.foregroundColor(ts.foregroundColor)
            }
            .frame(width: width, alignment: .topLeading)
            .if(!node.selected) {view in
                view.background(RoundedRectangle(cornerRadius: radius).fill(BackgroundStyle()))
            }
            .if(node.selected) { view in
                view.background(
                    RoundedRectangle(cornerRadius: radius)
                        .fill(Color.accentColor)
                )
            }
    }
}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        NodeView(node: Node<String>(content: "Hello World"), width: 100)
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
