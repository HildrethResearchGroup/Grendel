//
//  Tree.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

class Tree: Codable, ObservableObject {
    // The root node is used as a container for other nodes only, it contains no data, is not rendered,
    @Published var rootNode = Node<String>(content: "")
    var selectedLevel: Int? = nil
    @Published var maxDepth: Int = 0
    var levelWidths: [CGFloat] = [100]
    var currentWidths: [CGFloat] = [100]
    
    
    init() {}
    
    // MARK: JSON Encoding
    private enum CodingKeys: String, CodingKey {
        case rootNode
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rootNode = try container.decode(Node<String>.self, forKey: .rootNode)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rootNode, forKey: .rootNode)
    }
    
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
                levelWidths.insert(100, at: i)
                currentWidths.insert(100, at: i)
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
        //return rootOfSubtree.copyAll()
        
        // Create a copy of the root of the current subtree
        let copyOfRootOfSubtree = rootOfSubtree.copyAll()
        // Loop through each child of the current subtree
        for childNode in rootOfSubtree.children {
        //rootOfSubtree.children.forEach { childNode in
            // Use a copy of each child of the subtree as the root of a new subtree to copy
            let copyOfChildNode = copySubtree(rootOfSubtree: childNode)
            // Add the complete copy subtree of the copy of the child to the copy of the current subtree
            copyOfRootOfSubtree.insertChild(child: copyOfChildNode, at: copyOfRootOfSubtree.children.endIndex)
        }
        // Return the copy of the current subtree
        return copyOfRootOfSubtree
    }
    
    func deleteNode(node: Node<String>) {
        node.parent!.removeChild(child: node)
    }
    
    // MARK: Utility functions
    func applyFuncToNodes(filter: (Node<String>) -> Bool, modifyingFunc: (Node<String>) -> Void, minDepth: Int? = nil, maxDepth: Int? = nil, reverse: Bool = false) {
        applyFuncToNodesRecursive(currNode: rootNode, filter: filter, modifyingFunc: modifyingFunc, minDepth: minDepth, maxDepth: maxDepth, reverse: reverse)
    }
    
    private func applyFuncToNodesRecursive(currNode: Node<String>, filter: (Node<String>) -> Bool, modifyingFunc: (Node<String>) -> Void, minDepth: Int? = nil, maxDepth: Int? = nil, reverse: Bool = false) {
        // minDepth being nil means there is no min depth
        if(minDepth == nil || currNode.depth >= minDepth!) {
            // Apply the modifyingFunc to all nodes that pass the filter
            if(filter(currNode)) {
                modifyingFunc(currNode)
            }
        }
        
        // maxDepth being nil means there is no max depth
        if(maxDepth == nil || currNode.depth <= maxDepth!) {
            // Go through the children in reverse or normal order
            for child in (reverse ? currNode.children.reversed() : currNode.children) {
                // Recursive call maintaining settings on each child node
                applyFuncToNodesRecursive(currNode: child, filter: filter, modifyingFunc: modifyingFunc, minDepth: minDepth, maxDepth: maxDepth, reverse: reverse)
            }
        }
    }
    
    // Returns an array which is a preorder traversal of tree, which will come out as a list from top to bottom in a column of selected nodes
    func getSelectedArray() -> Array<Node<String>> {
        var selectedNodes = Array<Node<String>>()
        applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in selectedNodes.append(node)})
        return selectedNodes
    }
    
    // Returns the number of selected nodes
    func getNumSelected() -> Int {
        var count: Int = 0
        applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in count += 1})
        return count
    }
}
