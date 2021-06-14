//
//  OutlinerDocument.swift
//  Shared
//
//  Created by Team Illus-tree-ous (Mines CS Field Session) on 5/24/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var treeType: UTType {
        UTType(importedAs: "com.HRG.Outliner.tree")
    }
}

class OutlinerDocument: FileDocument, ObservableObject {
    @Published var tree: Tree
    var nodeCopyBuffer = Array<Node<String>>()
    
    init() {
        tree = Tree()
    }
    
    static var readableContentTypes: [UTType] { [.treeType] }
    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        tree = try JSONDecoder().decode(Tree.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(tree)
        return .init(regularFileWithContents: data)
    }

    /**
     Exports the tree to a plain text format.
     
     - Returns: A string representation of the entire tree
     */

    func exportToText() throws -> String {
        var str: String = ""
        
        // Starts with children since the root node doesn't have any content
        for child in tree.rootNode.children {
            str += generateTreeString(root: child)
        }
        
        return str
    }
    
    /**
     Generates a string representation of a tree.
     
     - Parameter root: The root node of the subtree
     
     - Returns: A string representation of the tree
     */
    func generateTreeString(root: Node<String>) -> String {
        var temp: String = ""
        let depth = root.depth
        
        // Add a tab for each layer of depth
        // We use depth-1 because we are skipping over the parent at depth 0
        for _ in 0 ..< depth-1 {
            temp += "\t"
        }
        
        // Add the content of the current node
        temp += root.content + "\n"
        
        // Add the content of each child node recursively
        for child in root.children {
            temp += generateTreeString(root: child)
        }
        
        return temp
    }
    
    // MARK: Intent Functions
    
    /**
     Deselects a node while allowing for multiple nodes to still be selected.
     
     - Parameter node: The node to deselect
     */
    func deselectMultiple(node: Node<String>) {
        tree.applyFuncToNodes(filter: { currNode in currNode.id == node.id }, modifyingFunc: { currNode in currNode.selected = false }, maxDepth: node.depth)
        if tree.getNumSelected() == 0 {
            tree.selectedLevel = nil
        }
    }
    
    /**
     Deselects all nodes.
     */
    func deselectAll() {
        tree.applyFuncToNodes(filter: { node in true }, modifyingFunc: { node in node.selected = false })
        tree.selectedLevel = nil
    }
    
    /**
     Selects a node while other nodes are already selected so multiple can be selected.
     
     - Parameter node: The node to select
     */
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
        
        // Select the node
        node.selected = true
    }
    
    /**
     Selects a node allowing for a singular node to be selected.
     
     - Parameter node: The node to select
     */
    func selectSingle(node: Node<String>) {
        deselectAll()
        tree.selectedLevel = node.depth
        node.selected = true
    }
    
    /**
     Selects all nodes in a column (depth).
     */
    func selectAll() {
        tree.applyFuncToNodes(filter: { node in tree.selectedLevel == node.depth }, modifyingFunc: { node in node.selected = true }, maxDepth: tree.selectedLevel)
    }
    
    /**
     Selects all children nodes of selected nodes.
     */
    func selectAllChildrenOfSelected() {
        let selectedArray = tree.getSelectedArray()
        deselectAll()
        tree.applyFuncToNodes(filter: { childNode in
            var contains = false
            for selectedNode in selectedArray {
                if childNode.parent!.id == selectedNode.id {
                    contains = true
                    break
                }
            }
            return contains
        }, modifyingFunc: { childNode in
            tree.selectedLevel = childNode.depth
            childNode.selected = true
        }, minDepth: (tree.selectedLevel != nil && tree.selectedLevel! > 1 ? tree.selectedLevel! : 1), maxDepth: tree.selectedLevel)
    }
    
    /**
     Selects all parent nodes of selected nodes.
     */
    func selectAllParentsOfSelected() {
        if tree.selectedLevel == 1 {
            print("Alert: can't select parent of left most level")
            return
        }
        let selectedArray = tree.getSelectedArray()
        deselectAll()
        tree.applyFuncToNodes(filter: { childNode in
            var contains = false
            for selectedNode in selectedArray {
                if childNode.id == selectedNode.id {
                    contains = true
                    break
                }
            }
            return contains
        }, modifyingFunc: { childNode in
            childNode.parent!.selected = true
            tree.selectedLevel = childNode.parent!.depth
        }, minDepth: (tree.selectedLevel != nil && tree.selectedLevel! > 1 ? tree.selectedLevel! : 1), maxDepth: tree.selectedLevel)
    }
    
    // MARK: Node Editing Functions
    
    /**
     Moves a node and all its children to be under a new parent.
     
     - Parameters:
        - node: The root node of the subtree to move
        - toParent: The parent node to move under
        - insertIndex: The index to insert the new node at
     */
    func move(node: Node<String>, toParent: Node<String>, at insertIndex: Int) {
        tree.move(node, toParent: toParent, at: insertIndex)
    }
    
    /**
     Moves under a child node.
     
     - Parameters:
        - movingNode: The node to move
        - aboveNode: The node that will be above the moved node
     */
    func moveUnder(movingNode: Node<String>, aboveNode: Node<String>) {
        let insertIndex = aboveNode.parent!.indexOfChild(aboveNode)! + 1
        tree.move(movingNode, toParent: aboveNode.parent!, at: insertIndex)
    }
    
    /**
     Moves above a child node.
     
     - Parameters:
        - movingNode: The node to move
        - belowNode: The node that will be below the moved node
     */
    func moveAbove(movingNode: Node<String>, belowNode: Node<String>) {
        let insertIndex = belowNode.parent!.indexOfChild(belowNode)!
        tree.move(movingNode, toParent: belowNode.parent!, at: insertIndex)
    }
    
    /**
     Indents all selected nodes.
     */
    func indentSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: { node in node.selected }, modifyingFunc: { node in tree.indent(node: node) })
        // Increment the selected level to the match
        if tree.selectedLevel != nil {
            tree.selectedLevel! += 1
        }
    }
    
    /**
     Outdents all selected nodes.
     */
    func outdentSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: { node in node.selected }, modifyingFunc: { node in tree.outdent(node: node) }, reverse: true)
        // Decrement to match the new selected level
        if tree.selectedLevel != nil {
            tree.selectedLevel! -= 1
        }
    }
    
    /**
     Duplicates selected nodes and place above.
     */
    func duplicateSelected() {
        objectWillChange.send()
        copyNodesSelected()
        pasteNodesSelected()
        //        let selectedNodes = tree.getSelectedArray()
        //
        //        // Insert all above the first selected node
        //        for selectedNode in selectedNodes {
        //            let copyOfSelectedNode = selectedNode.copy()
        //            moveAbove(movingNode: copyOfSelectedNode, belowNode: selectedNodes.first!)
        //            selectedNode.selected = false
        //            copyOfSelectedNode.selected = true
        //        }
    }
    
    /**
     Generate a string representation of the selected nodes.
     
     - Returns: A string representation of the selected nodes
     */
    func generateTreeStringSelected() -> String {
        var treeString = ""
        let selectedNodes = tree.getSelectedArray()
        for selNode in selectedNodes {
            treeString += generateTreeString(root: selNode)
            treeString += "\n"
        }
        
        return treeString
    }
    
    /**
     Creates a new line.
     
     - Parameter createUnder: True if there is a node to be above the new node, default is true
     */
    func newLine(createUnder: Bool = true) {
        objectWillChange.send()
        let selectedNodes = tree.getSelectedArray()
        if selectedNodes.count != 1 && tree.rootNode.children.count > 0 {
            print("Alert: couldn't add new line with \(selectedNodes.count) nodes selected")
        } else {
            if tree.rootNode.children.count == 0 {
                let newNode = Node<String>(content: "", width: 100.0)
                move(node: newNode, toParent: tree.rootNode, at: 0)
            } else if createUnder {
                let newNode = Node<String>(content: "", width: tree.currentWidths[selectedNodes[0].depth-1])
                moveUnder(movingNode: newNode, aboveNode: selectedNodes.first!)
            } else {
                let newNode = Node<String>(content: "", width: tree.currentWidths[selectedNodes[0].depth-1])
                moveAbove(movingNode: newNode, belowNode: selectedNodes.first!)
            }
        }
    }
    
    /**
     Creates a new child.
     */
    func newChild() {
        objectWillChange.send()
        
        let selectedNodes = tree.getSelectedArray()
        if selectedNodes.count != 1 {
            print("Alert: couldn't add new line with \(selectedNodes.count) nodes selected")
        } else {
            var newNode : Node<String>
            if(tree.levelWidths.count == selectedNodes[0].depth || selectedNodes[0].depth < 0) {
                newNode = Node<String>(content: "", width: 100.0)
            } else {
                newNode = Node<String>(content: "", width: tree.currentWidths[selectedNodes[0].depth])
            }
            move(node: newNode, toParent: selectedNodes.first!, at: selectedNodes.first!.children.endIndex)
        }
    }
    
    /**
     Deletes the selected node(s).
     */
    func deleteSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: { node in node.selected }, modifyingFunc: { node in tree.deleteNode(node: node) })
    }
    
    /**
     Toggles the selected family.
     */
    func toggleSelected() {
        objectWillChange.send()
        let selectedNodes = tree.getSelectedArray()
        var setShow = true
        for selNode in selectedNodes {
            if selNode.childrenShown {
                setShow = false
            }
        }
        for selNode in selectedNodes {
            selNode.childrenShown = setShow
        }
    }
    
    /**
     Cuts the selected nodes.
     */
    func cutNodesSelected() {
        objectWillChange.send()
        nodeCopyBuffer.removeAll()
        copyNodesSelected()
        // toggleSelected()
        deleteSelected()
    }
    
    /**
     Copies the selected nodes.
     */
    func copyNodesSelected() {
        nodeCopyBuffer.removeAll()
        let selectedNodes = tree.getSelectedArray()
        for selectedNode in selectedNodes {
            nodeCopyBuffer.append(tree.copySubtree(rootOfSubtree: selectedNode))
        }
    }
    
    /**
     Pastes the selected nodes.
     */
    func pasteNodesSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: { node in node.selected }, modifyingFunc: { node in
            node.selected = false
            for pasteNode in nodeCopyBuffer {
                let copyOfPasteNode = tree.copySubtree(rootOfSubtree: pasteNode)
                moveUnder(movingNode: copyOfPasteNode, aboveNode: node)
                copyOfPasteNode.selected = true
            }
        })
    }
    
    // MARK: Text Formatting Intent Functions
    
    /**
     Bolds the selected nodes.
     */
    func boldSelected() {
        let selectedNodes = tree.getSelectedArray()
        for selectedNode in selectedNodes {            
            if (selectedNode.textSettings.weight == .regular) {
                selectedNode.textSettings.setWeight(.bold)
            } else {
                selectedNode.textSettings.setWeight(.regular)
            }
        }
    }
    
    /**
     Italicizes the selected nodes.
     */
    func italicizeSelected() {
        let selectedNodes = tree.getSelectedArray()
        for selectedNode in selectedNodes {
            selectedNode.textSettings.isItalicized.toggle()
        }
    }
    
    /**
     Highlights the selected nodes.
     
     - Parameter colorString: The name of the color
     */
    func highlightSelected(colorString: String) {
        let color = Color(colorString)
        let selectedNodes = tree.getSelectedArray()
        for selectedNode in selectedNodes {
            selectedNode.textSettings.setHighlight(color: color)
        }
    }
    
    /**
     Change the text color of the selected nodes.
     
     - Parameter colorString: The name of the color
     */
    func colorSelected(colorString: String) {
        let color = Color(colorString)
        let selectedNodes = tree.getSelectedArray()
        for selectedNode in selectedNodes {
            selectedNode.textSettings.setForeground(color: color)
        }
    }
}
