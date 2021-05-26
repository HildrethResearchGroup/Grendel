//
//  Node.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

class Node: Identifiable, Codable {
    private(set) var children = Array<Node>()
    private(set) var parent: Node? = nil
    let id = UUID()
    private(set) var selected: Bool = false
    var depth: Int {
        switch parent {
        case nil:
            return 0
        default:
            return parent!.depth + 1
        }
    }
    
    init() {}
    
    // MARK: modify node
    func insertChild(child: Node, at insertIndex: Int) {
        children.insert(child, at: insertIndex)
        child.parent = self
    }
    
    func removeChild(child: Node) {
        let indexToRemove = indexOfChild(child)
        children.remove(at: indexToRemove!)
        child.parent = nil
    }
    
    func copy() -> Node {
        return Node()
    }
    
    
    
    // MARK: info in node
    func indexOfChild(_ child: Node) -> Int? {
        return children.firstIndex(where: {$0.id == id})
    }
    
    // MARK: JSON encoding
    private enum CodingKeys : String, CodingKey {
        case children
        case parent
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        children = try container.decode(Array<Node>.self, forKey: .children)
        parent = try container.decode(Node.self, forKey: .parent)
        selected = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(children, forKey: .children)
        try container.encode(parent, forKey: .parent)
    }
}
