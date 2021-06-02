//
//  OutlinerDocument.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var treeType: UTType {
        UTType(importedAs: "com.HRG.Outliner.tree")
    }
}

struct OutlinerDocument: FileDocument {
    var tree: Tree

    init() {
        tree = Tree()
        
        // TODO: remove below, was test code only
        let nodeA = Node<String>(content: "A")
        tree.move(nodeA, toParent: tree.rootNode, at: 0)
        let nodeAB = Node<String>(content: "AB")
        tree.move(nodeAB, toParent: nodeA, at: 0)
        let nodeABC = Node<String>(content: "ABC")
        tree.move(nodeABC, toParent: nodeAB, at: 0)
        let nodeAC = Node<String>(content: "AC")
        tree.move(nodeAC, toParent: nodeA, at: 1)
        let nodeACD = Node<String>(content: "ACD")
        tree.move(nodeACD, toParent: nodeAC, at: 0)
        let nodeAA = Node<String>(content: "AA")
        tree.move(nodeAA, toParent: nodeA, at: 0)
        let nodeB = Node<String>(content: "B")
        tree.move(nodeB, toParent: tree.rootNode, at: 1)
        
        selectSingle(node: nodeB)//nodeB.selected = true
        
        indentSelected()
        
        selectMultiple(node: nodeAC)
        
        outdentSelected()
        
        outdentSelected()
        
        deselectMultiple(node: tree.rootNode)

        let tree2: Tree
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(tree)
            if let jsonString = String(data: data, encoding: .utf8) {
              print(jsonString)
            }
            let decoder = JSONDecoder()
            tree2 = try decoder.decode(Tree.self, from: data)
            
            tree2.copySubtree(rootOfSubtree: tree2.rootNode)
        } catch {
            print("UH Oh spagettios")
        }
    }

    static var readableContentTypes: [UTType] { [.treeType] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
          throw CocoaError(.fileReadCorruptFile)
        }
        tree = try JSONDecoder().decode(Tree.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(tree)
        return .init(regularFileWithContents: data)
    }
    

    func exportToText() throws -> String {
        var str: String = ""
        
        // starts with children since the root node doesn't have any content
        for child in tree.rootNode.children {
            str += generateTreeString(root: child)
        }
        
        return str
    }
    
    func generateTreeString(root: Node<String>) -> String {
        var temp: String = ""
        let depth = root.depth
        
        // add a tab for each layer of depth
        // we use depth-1 because we are skipping over the parent at depth 0
        for _ in 0..<depth-1 {
            temp += "\t"
        }
        
        // add the content of the current node
        temp += root.content + "\n"
        
        // add the content of each child node recursively
        for child in root.children {
            temp += generateTreeString(root: child)
        }
        
        return temp
    }

    // MARK: intent functions
    // Returns an array which is a preorder traversal of tree, which will come out as a list from top to bottom in a column of selected nodes
    func getSelectedArray() -> Array<Node<String>> {
        var selectedNodes = Array<Node<String>>()
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in selectedNodes.append(node)})
        return selectedNodes
    }
    
    // Deselects a node while allowing for multiple nodes to still be selected
    func deselectMultiple(node: Node<String>) {
        var selecetedNodes = getSelectedArray()
        for (index, selectedNode) in selecetedNodes.enumerated() {
            if selectedNode.id == node.id {
                selectedNode.selected = false
                selecetedNodes.remove(at: index)
                break
            }
        }
        if selecetedNodes.count == 0 {
            tree.selectedLevel = nil
        }
    }
    
    // Deselect all nodes
    func deselectAll() {
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in node.selected = false})
        tree.selectedLevel = nil
    }
    
    // select a node allowing for there to be multiple selected
    func selectMultiple(node: Node<String>) {
        // Find the level being selected and deselect selected nodes not on that level
        switch tree.selectedLevel {
        case nil:
            tree.selectedLevel = node.depth
        default:
            if(tree.selectedLevel != node.depth) {
                deselectAll()
                tree.selectedLevel = node.depth
            }
        }
        
        // select the node
        node.selected = true
    }
    
    // select a node allowing for a singular node to be selected
    func selectSingle(node: Node<String>) {
        deselectAll()
        tree.selectedLevel = node.depth
        node.selected = true
    }
    
    // Select all nodes in a column (depth)
    func selectAll() {
        tree.applyFuncToNodes(filter: {node in tree.selectedLevel == node.depth}, modifyingFunc: {node in node.selected = true}, maxDepth: tree.selectedLevel)
    }
    
    // Move a node and all its children to be under a new parent
    func move(node: Node<String>, toParent: Node<String>, at insertIndex: Int) {
        tree.move(node, toParent: toParent, at: insertIndex)
    }
    
    // Move under a child node
    func moveUnder(movingNode: Node<String>, aboveNode: Node<String>) {
        let insertIndex = aboveNode.parent!.indexOfChild(aboveNode)! + 1
        tree.move(movingNode, toParent: aboveNode.parent!, at: insertIndex)
    }
    
    // Move above a child node
    func moveAbove(movingNode: Node<String>, belowNode: Node<String>) {
        let insertIndex = belowNode.parent!.indexOfChild(belowNode)!
        tree.move(movingNode, toParent: belowNode.parent!, at: insertIndex)
    }
    
    // Indent all selected nodes
    func indentSelected() {
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in tree.indent(node: node)})
        // Increment the selected level to the match
        if tree.selectedLevel != nil {
            tree.selectedLevel! += 1
        }
    }
    
    // Outdent all selected nodes
    func outdentSelected() {
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in tree.outdent(node: node)}, reverse: true)
        // Decrement to match the new selected level
        if tree.selectedLevel != nil {
            tree.selectedLevel! -= 1
        }
    }
    
    // Duplicate selected nodes and place above
    func duplicateSelected() {
        let selectedNodes = getSelectedArray()
        
        // Insert all above the first selected node
        for selectedNode in selectedNodes {
            let copyOfSelectedNode = selectedNode.copy()
            moveAbove(movingNode: copyOfSelectedNode, belowNode: selectedNodes.first!)
            selectedNode.selected = false
            copyOfSelectedNode.selected = true
        }
    }
    
    // TODO: copy
    
    // TODO: paste
    
    
}
