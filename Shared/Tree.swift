//
//  Tree.swift
//  Outliner
//
//  Created by Team Illus-tree-ous (Mines CS Field Session) on 5/24/21.
//

import Foundation

class Tree: Codable, ObservableObject {
    // The root node is used as a container for other nodes only, it contains no data and is not rendered.
    @Published var rootNode = Node<String>(content: "", width: 0.0)
    var selectedLevel: Int? = nil
    @Published var maxDepth: Int = 0
    @Published var levelWidths: [CGFloat] = [100]
    @Published var currentWidths: [CGFloat] = [100]
    
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
    
    func updateLevelWidths(level: Int, width: CGFloat){
        rootNode.updateLevelWidths(level: level, width: width)
    }
    
    // MARK: Modifications
    
    /**
     Moves a node to being a child of the node above it in its subtree.
     
     - Parameter node: The node to indent
     */
    func indent(node: Node<String>) {
        let nodesIndex = node.parent!.indexOfChild(node)
        // If there isn't a node above the this node then indenting can't happen
        if(nodesIndex! == 0) {
            print("Alert, couldn't indent")
            // TODO: Alert of unable to indent
        } else {
            // Store the node above it
            let newParent = node.parent!.children[nodesIndex! - 1]
            // Move to the end of the list of children of the node above it
            move(node, toParent: newParent, at: newParent.children.endIndex)
        }
        findMaxDepth()
    }
    
    /**
     Finds the maximum depth of the root/tree.
     */
    func findMaxDepth() {
        maxDepth = rootNode.checkMaxDepth()
        
        let count = 0 ..< maxDepth
        
        for i in count {
            if(i >= levelWidths.count) {
                levelWidths.insert(100, at: i)
                currentWidths.insert(100, at: i)
            }
        }
    }
    
    /**
     Moves a node to be under its parent node at the same depth.
     
     - Parameter node: The node to outdent
     */
    func outdent(node: Node<String>) {
        switch node.parent!.parent { // Can print an error only if the root node is being modified, which can't happen
        case nil:
            // TODO: Alert of incorrect outdent
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
    
    /**
     Moves a node from one parent to another, breaking the relationship between its current parent and making one with the new parent.
     
     - Parameters:
        - node: The node to move
        - newParent: The parent node to move to
        - index: The index to insert the node at under the parent
     */
    func move(_ node: Node<String>, toParent newParent: Node<String>, at index: Int) {
        // Remove relationship to old parent
        if(node.parent != nil) {
            node.parent!.removeChild(child: node)
        }
        
        // Add the relationship to the new parent
        newParent.insertChild(child: node, at: index)
        
        findMaxDepth()
    }
    
    /**
     Creates a copy of a node and all of its children.
     
     - Parameter rootOfSubtree: The root node of the subtree
     
     - Returns: A copy of the node containing data about its children
     */
    func copySubtree(rootOfSubtree: Node<String>) -> Node<String> {
        // return rootOfSubtree.copyAll()
        
        // Create a copy of the root of the current subtree
        let copyOfRootOfSubtree = rootOfSubtree.copyAll()
        // Loop through each child of the current subtree
        for childNode in rootOfSubtree.children {
        // rootOfSubtree.children.forEach { childNode in
            // Use a copy of each child of the subtree as the root of a new subtree to copy
            let copyOfChildNode = copySubtree(rootOfSubtree: childNode)
            // Add the complete copy subtree of the copy of the child to the copy of the current subtree
            copyOfRootOfSubtree.insertChild(child: copyOfChildNode, at: copyOfRootOfSubtree.children.endIndex)
        }
        // Return the copy of the current subtree
        return copyOfRootOfSubtree
    }
    
    /**
     Deletes a node from the tree.
     
     - Parameter node: The node to remove
     */
    func deleteNode(node: Node<String>) {
        node.parent!.removeChild(child: node)
    }
    
    // MARK: Utility Functions
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
    
    /**
     Gets the preorder traversal of the tree as a list from top to bottom in a column of selected nodes.
     
     - Returns: An array that is the preorder traversal of the tree
     */
    func getSelectedArray() -> Array<Node<String>> {
        var selectedNodes = Array<Node<String>>()
        applyFuncToNodes(filter: { node in node.selected }, modifyingFunc: { node in selectedNodes.append(node) })
        return selectedNodes
    }
    
    /**
     Gets the current number of selected nodes.
     
     - Returns: The number of selected nodes
     */
    func getNumSelected() -> Int {
        var count: Int = 0
        applyFuncToNodes(filter: { node in node.selected }, modifyingFunc: { node in count += 1 })
        return count
    }
}
