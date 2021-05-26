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
}
