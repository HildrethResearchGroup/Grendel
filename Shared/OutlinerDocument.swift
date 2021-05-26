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
