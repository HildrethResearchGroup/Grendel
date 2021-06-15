//
//  NodeView.swift
//  Outliner
//
//  Created by Team Illus-tree-ous (Mines CS Field Session) on 6/7/21.
//

import SwiftUI

/**
 Makes the `TextEditor` background clear so that the background can correctly show through.
 */
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear // << here clear
            drawsBackground = true
        }
    }
}

struct NodeView: View {
    @ObservedObject var node: Node<String>
    @State var shown: Bool = true
    @ObservedObject var ts: Node<String>.TextSettings
    var radius: CGFloat
    var spacing: CGFloat
    var iconRadius: CGFloat
    
    init(node: Node<String>, radius: CGFloat = 5, spacing: CGFloat = 20) {
        self.node = node
        // self.width = node.width
        self.radius = radius
        self.spacing = spacing
        self.iconRadius = (spacing/2 + 17.0/2)/2
        self.ts = node.textSettings
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Add the circle or triangle icon
            NodeIcon(hasChildren: !node.children.isEmpty)
                .fill(Color("Inverted").opacity(0.5))
                .frame(width: 2*iconRadius, height: 2*iconRadius, alignment: .center)
                .padding(.trailing, 0)
                .padding([.leading, .top, .bottom], spacing/2)
            // The text editor
            TextEditor(text: $node.content)
                .onChange(of: node.content) { value in
                    
                    // Detects when enter is pressed and takes the user out of the textEditor.
                    shown = true
                    document!.wrappedValue.deselectAll()
                    node.selected = true
                    if value.contains("\n") {
                        node.content = value.replacingOccurrences(of: "\n", with: "")
                        shown = false
                    }
                    if value.contains("\t") {
                        node.content = value.replacingOccurrences(of: "\t", with: "")
                        shown = false
                    }
                }
                .font(ts.getFont())
                .foregroundColor(ts.foregroundColor)
                .fixedSize(horizontal: false, vertical: true)
                .if(!shown) { view in
                    view.disabled(shown)
                }
                .padding(.leading, spacing/4)
                .padding([.trailing, .bottom, .top], spacing/2)
        }
        .frame(maxWidth: node.width - spacing, idealHeight: 0)
        .background(createBackgroundRectangle())
        .padding(.trailing, spacing)
    }
    
    private func createBackgroundRectangle() -> some View {
        Group {
            if node.selected {
                RoundedRectangle(cornerRadius: radius).fill(Color.accentColor)
            } else {
                RoundedRectangle(cornerRadius: radius).fill(ts.highlightColor ?? Color("Default"))
            }
        }
    }
}

/**
 Allows for easy application of view modifiers based on a condition.
 [Source](https://www.avanderlee.com/swiftui/conditional-view-modifier/)
 */
extension View {
    /**
     Applies the given transform if the given condition evaluates to true.
     - Parameters:
       - condition: The condition to evaluate
       - transform: The transform to apply to the source `View`
     - Returns: Either the original `View` or the modified `View` if the condition is `true`
     */
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/**
 Draws a triangle or circle icon by each node depending if it has children or not.
 */
struct NodeIcon: Shape {
    let hasChildren: Bool
    let radius: CGFloat = (10 + 17.0/2)/2
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            if hasChildren {
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 1.5*radius, y: radius))
                p.addLine(to: CGPoint(x: 0, y: 2*radius))
                p.closeSubpath()
            } else {
                p.addArc(center: CGPoint(x: radius,
                                         y: radius),
                         radius: radius,
                         startAngle: Angle(degrees: 0),
                         endAngle: Angle(degrees: 360),
                         clockwise: true)
            }
        }
    }
}
