//
//  Tree.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

class Tree: Codable {
    // The root node is used as a container for other nodes only, it contains no data, is not rendered,
    var rootNode = Node<String>(content: "")
    var selectedLevel: Int? = nil
    var maxDepth: Int = 0
    var levelWidths: [CGFloat] = [0.2]
    

    
    // MARK: modifications
    // Move a node to being a child of the node above it in its subtree
    func indent(node: Node<String>) {
        let nodesIndex = node.parent!.indexOfChild(node)
        // If there isn't a node above the this node then indenting can't happen
        if(nodesIndex! == 0) {
            print("Alert, couldn't indent")
            // TODO: alert of unable to indent
        } else {
            // Store the node above it
            let newParent = node.parent!.children[nodesIndex! - 1]
            // Move to the end of the list of children of the node above it
            move(node, toParent: newParent, at: newParent.children.endIndex)
        }
        
        findMaxDepth()
    
    }
    
    func findMaxDepth() {
        
        maxDepth = rootNode.checkMaxDepth()
        
        let count = 0..<maxDepth
        
        for i in count {
            if(i>=levelWidths.count){
                levelWidths.insert(0.2, at: i)
            }
        }
        
    }
    
    // Move a node to be under its parent node
    func outdent(node: Node<String>) {
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
        findMaxDepth()
    }
    
    // Move a node from one parent to another, breaking the relationship between its current parent and making one with the new parent
    func move(_ node: Node<String>, toParent newParent: Node<String>, at index: Int) {
        // Remove relationship to old parent
        if(node.parent != nil) {
            node.parent!.removeChild(child: node)
        }
        
        // Add the relationship to the new parent
        newParent.insertChild(child: node, at: index)
    }
    
    // Creates a copy of a node, and copies all of its children and
    func copySubtree(rootOfSubtree: Node<String>) -> Node<String> {
        // Create a copy of the root of the current subtree
        let copyOfRootOfSubtree = rootOfSubtree.copy()
        // Loop through each child of the current subtree
        rootOfSubtree.children.forEach { childNode in
            // Use a copy of each child of the subtree as the root of a new subtree to copy
            let copyOfChildNode = copySubtree(rootOfSubtree: childNode.copy())
            // Add the complete copy subtree of the copy of the child to the copy of the current subtree
            copyOfRootOfSubtree.insertChild(child: copyOfChildNode, at: copyOfRootOfSubtree.children.endIndex)
        }
        // Return the copy of the current subtree
        return copyOfRootOfSubtree
    }
}
