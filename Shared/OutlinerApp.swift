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
            
    }
    
    // Custom scene that handles the exporting of files and the
    // addition of the menu buttons to do so
    struct DocumentWindow: Scene {
        // used as a SwiftUI workaround to access members of the file var
        private let exportCommand = PassthroughSubject<Void, Never>()
        
        var body : some Scene {
            DocumentGroup(newDocument: OutlinerDocument()) { file in
                ContentView(file.$document)
                    .onReceive(exportCommand) { _ in
                        do {
                            // get the name of the file, including extension
                            let fileName = file.fileURL?.lastPathComponent
                            
                            // either chooses to save to the same directory or falls back to the documents folder
                            let directory = file.fileURL?.deletingLastPathComponent() ?? getDocumentsFolder()
                            
                            // writes to the predetermined filename or uses 'output' if it cannot be found
                            let outputFile = directory.appendingPathComponent(fileName ?? "output.tree").appendingPathExtension("txt")
                            
                            
                            print("Output URL: " + outputFile.path)
                            
                            // get contents of file
                            let text = try file.document.exportToText()
                            
                            // write to the given file
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
                    //                    Button("Edit Node"){
                    //                        editAction()
                    //                    }
                    
                    Button("Toggle Children"){
                        toggleAction()
                    }
                    
                    //                    Button("Highlight"){
                    //                        labelAction()
                    //                    }
                    
                    Button("Text"){
                        textAction()
                    }
                    
                    
                }
                CommandMenu("Selection") {
                    Button("Select Children") {
                        selectChildrenAction()
                    }.keyboardShortcut(KeyEquivalent.rightArrow)
                    
                    Button("Select Parents") {
                        selectParentAction()
                    }.keyboardShortcut(KeyEquivalent.leftArrow)
                }
                CommandGroup(replacing: CommandGroupPlacement.pasteboard, addition: {
                    Button("Cut") {
                        cutAction()
                    }.keyboardShortcut(KeyEquivalent("x"), modifiers: .command)
                    
                    Button("Copy") {
                        copyAction()
                    }.keyboardShortcut(KeyEquivalent("c"), modifiers: .command)
                    
                    Button("Paste") {
                        pasteAction()
                    }.keyboardShortcut(KeyEquivalent("v"), modifiers: .command)
                    
                    Button("Duplicate") {
                        duplicateAction()
                    }.keyboardShortcut(KeyEquivalent("d"), modifiers: .command)
                })
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
