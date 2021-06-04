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
        let nodeX = Node<String>(content: "X")
        tree.move(nodeX, toParent: nodeB, at: 0)
        let nodeY = Node<String>(content: "Y")
        tree.move(nodeY, toParent: nodeX, at: 0)
        
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
}
