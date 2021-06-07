//
//  TreeView.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/4/21.
//

import SwiftUI

struct TreeView: View {
    let widths: Array<CGFloat> = [100, 100, 100, 100, 100, 100, 100]
    var body: some View {
        let outlinerDocument = OutlinerDocument()
        Diagram(currNode: outlinerDocument.tree.rootNode, makeNodeView: { (value: Node<String>) in
            Text("\(value.content)")
                .padding(5)
                .foregroundColor(.black)
                //.background(Color.white) // same color as the document background
                .frame(width: widths[value.depth-1], alignment: .topLeading) // width of each column/tree level is currently fixed but will later be changed to what the user specifies with the slider bar (could be default value for now)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white)))
        }).background(Color.white)
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView()
    }
}

struct CollectDict<Key: Hashable, Type>: PreferenceKey {
    typealias Value = [Key:Type]
    
    static var defaultValue: Value { [:] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct anchorID {
    let nodeID: UUID
    let position: anchorPosition
    
    enum anchorPosition {
        case left
        case right
    }
}

struct Diagram<V: View>: View {
    let currNode: Node<String>
    let makeNodeView: (Node<String>) -> V

    typealias Key = CollectDict<Node<String>.ID, Anchor<CGPoint>>

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            if currNode.depth != 0 {
                makeNodeView(currNode)
                    .anchorPreference(key: Key.self, value: .top, transform: { // the anchor point
                        [self.currNode.id: $0]
                    })
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(currNode.children, id: \.id, content: { child in
                    Diagram(currNode: child, makeNodeView: self.makeNodeView)
                })
            }
        }.backgroundPreferenceValue(Key.self, { (centers: [Node<String>.ID: Anchor<CGPoint>]) in
            if self.currNode.depth != 0 {
                GeometryReader { proxy in
                    ForEach(self.currNode.children, id: \.id, content: { child in
                        NodeConnectingLine(
                            from: proxy[centers[self.currNode.id]!],
                            to: proxy[centers[child.id]!],
                            firstChild: child.firstChild,
                            lastChild: child.lastChild
                        )
                        .stroke(Color.gray, style: StrokeStyle(dash: [2.5])) // set stroke of the lines
                    })
                }
            }
        })
    }
}

struct NodeConnectingLine: Shape {
    let offset: CGFloat = 13

    init(from: CGPoint, to: CGPoint, firstChild: Bool, lastChild: Bool) {
        self.firstChild = firstChild
        self.lastChild = lastChild
        self.to = to
        self.from = from
    }
    
    var firstChild: Bool
    var lastChild: Bool
    
    private var _from = CGPoint()
    var from: CGPoint {
        get { return _from }
        set(newValue) { _from = CGPoint(x: newValue.x, y: newValue.y + offset) }
    }
    private var _to = CGPoint()
    var to: CGPoint {
        get { return _to }
        set(newValue) { _to = CGPoint(x: newValue.x, y: newValue.y + offset) }
    }
    let radius: CGFloat = 5
    var isMiddleChild: Bool = false
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            // Move to the middle of the parent node
            p.move(to: from)
            // Draw to the halfway point
            p.addLine(to: CGPoint(x: (from.x + to.x) / 2, y: from.y))
            // Draw vertical lines?
            if !firstChild {
                // Draw down to the node that needs to the child node
                if lastChild {
                    // For the last child add a curve
                    p.addLine(to: CGPoint(x: (from.x + to.x) / 2, y: to.y - radius))
                    p.addArc(center: CGPoint(
                                x: (from.x + to.x) / 2 + radius,
                                y: to.y - radius),
                             radius: radius,
                             startAngle: Angle(degrees: 180),
                             endAngle: Angle(degrees: 90),
                             clockwise: true)
                } else {
                    // For other nodes just draw a line down
                    p.addLine(to: CGPoint(x: (from.x + to.x) / 2, y: to.y))
                }
            }
            p.addLine(to: to)
        }
    }
}
