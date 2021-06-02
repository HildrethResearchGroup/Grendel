//
//  OutlinerApp.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI
import Combine

@main
struct OutlinerApp: App {
    var body: some Scene {
        DocumentWindow()
            .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
            .commands{
                CommandMenu("Editor"){
                    Button("Delete"){
                        deleteAction()
                    }.keyboardShortcut(.delete, modifiers: [.shift])
                    
                    Button("Add Item"){
                        addItemAction()
                    }.keyboardShortcut(.return, modifiers: [])
                    
                    Button("Add Child"){
                        addChildAction()
                    }.keyboardShortcut(.return, modifiers: [.shift])
                    
                    Button("Indent"){
                        indentAction()
                    }.keyboardShortcut(.tab, modifiers: [])
                    
                    Button("Outdent"){
                        outdentAction()
                    }.keyboardShortcut(.tab, modifiers: [.shift])
                }
                CommandMenu("Node"){
                    Button("Edit Node"){
                        editAction()
                    }
                    
                    Button("Toggle Children"){
                        toggleAction()
                    }
                    
                    Button("Highlight"){
                        labelAction()
                    }
                    
                    Button("Font"){
                        fontAction()
                    }
                }
            }
    }
    
    struct DocumentWindow: Scene {
        private let exportCommand = PassthroughSubject<Void, Never>()
        
        var body : some Scene {
            DocumentGroup(newDocument: OutlinerDocument()) { file in
                ContentView(document: file.$document)
                    .onReceive(exportCommand) { _ in
                        do {
                            let text = try file.document.exportToText()
                            let documents = getDocumentsFolder() // FIXME: gets sandboxed url?
                            let fileName = "output" // FIXME: find how to get file name, possibly from file variable
                            let outputFile = documents.appendingPathComponent(fileName).appendingPathExtension("txt")
                            print("Output URL: " + outputFile.path)
                            try text.write(to: outputFile, atomically: true, encoding: .utf8)
                        } catch let e {
                            print("Export error:\n" + e.localizedDescription)
                        }
                    }
            }
            .commands {
                CommandGroup(after: .saveItem) {
                    Button("Export to text file") {
                        exportCommand.send()
                    }
                }
            }
        }
    }
}

func getDocumentsFolder() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // just send back the first one, which ought to be the only one
    return paths[0]
}
