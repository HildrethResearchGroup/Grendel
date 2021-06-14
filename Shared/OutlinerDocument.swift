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

class OutlinerDocument: FileDocument, ObservableObject {
    
    @Published var tree: Tree
    var nodeCopyBuffer = Array<Node<String>>()

        init() {
            tree = Tree()
            
             //TODO: remove below, was test code only
            let nodeA = Node<String>(content: "yes", width: 100.0)
            nodeA.textSettings.setWeight(.bold)
            tree.move(nodeA, toParent: tree.rootNode, at: 0)
            let nodeAB = Node<String>(content: "AB", width: 100.0)
            tree.move(nodeAB, toParent: nodeA, at: 0)
            let nodeABC = Node<String>(content: "ABC", width: 100.0)
            tree.move(nodeABC, toParent: nodeAB, at: 0)
            let nodeAC = Node<String>(content: "AC", width: 100.0)
            tree.move(nodeAC, toParent: nodeA, at: 1)
            let nodeACD = Node<String>(content: "ACD", width: 100.0)
            tree.move(nodeACD, toParent: nodeAC, at: 0)
            let nodeAA = Node<String>(content: "AA", width: 100.0)
            tree.move(nodeAA, toParent: nodeA, at: 0)
            let nodeB = Node<String>(content: "B", width: 100.0)
            tree.move(nodeB, toParent: tree.rootNode, at: 1)
            let nodeX = Node<String>(content: "X", width: 100.0)
            tree.move(nodeX, toParent: nodeB, at: 0)
            let nodeY = Node<String>(content: "Y", width: 100.0)
            tree.move(nodeY, toParent: nodeX, at: 0)

            nodeAC.childrenShown = false

            selectSingle(node: nodeA)
            
            tree.findMaxDepth()
            
    //        print(nodeY.depth)
    //        tree.findMaxDepth()
    //        print(tree.levelWidths)
    //        print(tree.maxDepth)
    //
    //        let tree2: Tree
    //        do {
    //            let encoder = JSONEncoder()
    //            encoder.outputFormatting = .prettyPrinted
    //            let data = try encoder.encode(tree)
    //            if let jsonString = String(data: data, encoding: .utf8) {
    //              print(jsonString)
    //            }
    //            let decoder = JSONDecoder()
    //            tree2 = try decoder.decode(Tree.self, from: data)
    //        } catch {
    //            print("UH Oh spagettios")
    //        }
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
    // Deselects a node while allowing for multiple nodes to still be selected
    func deselectMultiple(node: Node<String>) {
        tree.applyFuncToNodes(filter: {currNode in currNode.id == node.id}, modifyingFunc: {currNode in currNode.selected = false}, maxDepth: node.depth)
        if tree.getNumSelected() == 0 {
            tree.selectedLevel = nil
        }
    }
    
    // Deselect all nodes
    func deselectAll() {
        tree.applyFuncToNodes(filter: {node in true}, modifyingFunc: {node in node.selected = false})
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
    
    // Select all children nodes of selected nodes
    func selectAllChildrenOfSelected() {
        let selectedArray = tree.getSelectedArray()
        deselectAll()
        tree.applyFuncToNodes(filter: {childNode in
            var contains = false
            for selectedNode in selectedArray {
                if childNode.parent!.id == selectedNode.id {
                    contains = true
                    break
                }
            }
            return contains
        }, modifyingFunc: {childNode in
            tree.selectedLevel = childNode.depth
            childNode.selected = true
        }, minDepth: (tree.selectedLevel != nil && tree.selectedLevel! > 1 ? tree.selectedLevel! : 1), maxDepth: tree.selectedLevel)
    }
    
    func selectAllParentsOfSelected() {
        if tree.selectedLevel == 1 {
            print("Alert: can't select parent of left most level")
            return
        }
        let selectedArray = tree.getSelectedArray()
        deselectAll()
        tree.applyFuncToNodes(filter: {childNode in
            var contains = false
            for selectedNode in selectedArray {
                if childNode.id == selectedNode.id {
                    contains = true
                    break
                }
            }
            return contains
        }, modifyingFunc: {childNode in
            childNode.parent!.selected = true
            tree.selectedLevel = childNode.parent!.depth
        }, minDepth: (tree.selectedLevel != nil && tree.selectedLevel! > 1 ? tree.selectedLevel! : 1), maxDepth: tree.selectedLevel)
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
        objectWillChange.send()
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in tree.indent(node: node)})
        // Increment the selected level to the match
        if tree.selectedLevel != nil {
            tree.selectedLevel! += 1
        }
    }
    
    // Outdent all selected nodes
    func outdentSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in tree.outdent(node: node)}, reverse: true)
        // Decrement to match the new selected level
        if tree.selectedLevel != nil {
            tree.selectedLevel! -= 1
        }
    }
    
    // Duplicate selected nodes and place above
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
    
    func generateTreeStringSelected() -> String {
        var treeString = ""
        let selectedNodes = tree.getSelectedArray()
        for selNode in selectedNodes {
            treeString += generateTreeString(root: selNode)
            treeString += "\n"
        }
        
        return treeString
    }
    
    func newline(createUnder: Bool = true) {
        objectWillChange.send()
        let selectedNodes = tree.getSelectedArray()
        if selectedNodes.count != 1 && tree.rootNode.children.count > 0 {
            print("Alert: couldn't add new line with \(selectedNodes.count) nodes selected")
        } else {
            if tree.rootNode.children.count == 0 {
                let newNode = Node<String>(content: "", width: 100.0)
                move(node: newNode, toParent: tree.rootNode, at: 0)
                print("Okay")
            } else if createUnder {
                let newNode = Node<String>(content: "", width: tree.currentWidths[selectedNodes[0].depth-1])
                moveUnder(movingNode: newNode, aboveNode: selectedNodes.first!)
                print(tree.currentWidths[selectedNodes[0].depth-1])
                print(1)
            } else {
                let newNode = Node<String>(content: "", width: tree.currentWidths[selectedNodes[0].depth-1])
                moveAbove(movingNode: newNode, belowNode: selectedNodes.first!)
                print(tree.currentWidths[selectedNodes[0].depth-1])
                print(2)
            }
        }
    }
    
    func newchild() {
        objectWillChange.send()
        
        let selectedNodes = tree.getSelectedArray()
        if selectedNodes.count != 1 {
            print("Alert: couldn't add new line with \(selectedNodes.count) nodes selected")
        } else {
            
            var newNode : Node<String>
            if(tree.levelWidths.count == selectedNodes[0].depth || selectedNodes[0].depth < 0){
                newNode = Node<String>(content: "", width: 100.0)
            }else{
                newNode = Node<String>(content: "", width: tree.currentWidths[selectedNodes[0].depth])
            }
            move(node: newNode, toParent: selectedNodes.first!, at: selectedNodes.first!.children.endIndex)
        }
    }
    
    func deleteSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in tree.deleteNode(node: node)})
    }
    
    // Toggle family
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
    
    func cutNodesSelected() {
        objectWillChange.send()
        nodeCopyBuffer.removeAll()
        copyNodesSelected()
        //toggleSelected()
        deleteSelected()
    }
    
    // TODO: copy
    func copyNodesSelected() {
        nodeCopyBuffer.removeAll()
        let selectedNodes = tree.getSelectedArray()
        for selectedNode in selectedNodes {
            nodeCopyBuffer.append(tree.copySubtree(rootOfSubtree: selectedNode))
        }
    }
    
    // TODO: paste
    func pasteNodesSelected() {
        objectWillChange.send()
        tree.applyFuncToNodes(filter: {node in node.selected}, modifyingFunc: {node in
            node.selected = false
            for pasteNode in nodeCopyBuffer {
                let copyOfPasteNode = tree.copySubtree(rootOfSubtree: pasteNode)
                moveUnder(movingNode: copyOfPasteNode, aboveNode: node)
                copyOfPasteNode.selected = true
            }
        })
    }
    
    
}
