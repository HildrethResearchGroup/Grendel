//
//  Node.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

class Node: Identifiable {
    private(set) var children = Array<Node>()
    private(set) var parent: Node? = nil
    let id = UUID()
    private(set) var selected: Bool = false
    
    init() {}
    
    // MARK: modify node
    func insertChild(child: Node, at insertIndex: Int) {
        switch children {
        case nil:
            if(insertIndex != 0) {
                // TODO: maybe produce an error
            }
            children = [child]
        default:
            children.insert(child, at: insertIndex)
        }
        child.parent = self
    }
    
    func removeChild(child: Node) {
        switch children {
        case nil:
            // TODO: maybe produce an error
            print("Error no children to remove from")
        default:
            let indexToRemove = indexOfChild(child)
            children.remove(at: indexToRemove!)
        }
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
