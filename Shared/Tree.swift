//
//  Tree.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

struct Tree {
    // The root node is used as a container for other nodes only, it contains no data, is not rendered,
    var rootNode = Node()
    
    // MARK: modifications
    // Move a node to being a child of the node above it in its subtree
    func indent(node: Node) {
        let nodesIndex = node.parent!.indexOfChild(node)
        // If there isn't a node above the this node then indenting can't happen
        if(nodesIndex! == 0) {
            print("Alert, couldn't indent")
            // TODO: alert of unable to indent
        } else {
            // Store the node above it
            let newParent = node.parent!.children![nodesIndex! - 1]
            // Move to the end of the list of children of the node above it
            switch newParent.children {
            case nil:
                move(node, toParent: newParent, at: 0)
            default:
                move(node, toParent: newParent, at: newParent.children!.endIndex)
            }
            
        }
    }
    
    // Move a node to be under its parent node
    func outdent(node: Node) {
        switch node.parent!.parent { // Can print an error only if the root node is being modified, which can't happen
        case nil:
            // TODO: alert of incorrent outdent
            print("Alert, couldn't outdent, no parent of node's parent")
        default:
            // Store the parent's parent
            let newParent = node.parent!.parent!
            let insertIndex = newParent.indexOfChild(node.parent!)! + 1
            // Move the node to the parent's parent, right after parent
            move(node, toParent: newParent, at: insertIndex) // Can print an error only if parent's parent has no children, which is impossible
        }
    }
    
    // Move a node from one parent to another, breaking the relationship between its current parent and making one with the new parent
    func move(_ node: Node, toParent newParent: Node, at index: Int) {
        // Remove relationship to old parent
        if(node.parent != nil) {
            node.parent!.removeChild(child: node)
        }
        
        // Add the relationship to the new parent
        switch newParent.children {
        case nil:
            newParent.insertChild(child: node, at: 0)
        default:
            newParent.insertChild(child: node, at: index)
        }
    }
    
    // Creates a copy of a node, and copies all of its children and
    func copySubtree(rootOfSubtree: Node) -> Node{
        // Create a copy of the root of the current subtree
        let copyOfRootOfSubtree = rootOfSubtree.copy()
        // If the current subtree has children
        if(rootOfSubtree.children != nil) {
            // Loop through each child of the current subtree
            var insertIndex = 0
            rootOfSubtree.children!.forEach { childNode in
                // Use a copy of each child of the subtree as the root of a new subtree to copy
                let copyOfChildNode = copySubtree(rootOfSubtree: childNode.copy())
                // Add the complete copy subtree of the copy of the child to the copy of the current subtree
                copyOfRootOfSubtree.insertChild(child: copyOfChildNode, at: insertIndex)
                insertIndex = copyOfRootOfSubtree.children!.endIndex
            }
        }
        // Return the copy of the current subtree
        return copyOfRootOfSubtree
    }
}
