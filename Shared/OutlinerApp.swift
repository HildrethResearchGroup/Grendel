//
//  OutlinerApp.swift
//  Shared
//
//  Created by Team Illus-tree-ous (Mines CS Field Session) on 5/24/21.
//

import SwiftUI
import Combine

@main
struct OutlinerApp: App {
    var body: some Scene {
        DocumentWindow()
            .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
    }
    
    /**
     Handles the exporting of files and the addition of the menu buttons to do so.
     */
    struct DocumentWindow: Scene {
        // Used as a SwiftUI workaround to access members of the file var inside ContentView
        private let exportCommand = PassthroughSubject<Void, Never>()
        
        var body : some Scene {
            DocumentGroup(newDocument: OutlinerDocument()) { file in
                ContentView(file.$document)
                    // Export to text file
                    .onReceive(exportCommand) { _ in
                        do {
                            // Get the name of the file, including extension
                            let fileName = file.fileURL?.lastPathComponent
                            
                            // Either chooses to save to the same directory or falls back to the documents folder
                            let directory = file.fileURL?.deletingLastPathComponent() ?? getDocumentsFolder()
                            
                            // Writes to the predetermined filename or uses 'output' if it cannot be found
                            let outputFile = directory.appendingPathComponent(fileName ?? "output.tree").appendingPathExtension("txt")
                            
                            print("Output URL: " + outputFile.path)
                            
                            // Get contents of file
                            let text = try file.document.exportToText()
                            
                            // Write to the given file
                            try text.write(to: outputFile, atomically: true, encoding: .utf8)
                        } catch let e {
                            print("Export error:\n" + e.localizedDescription)
                        }
                    }
            }
            // Adding custom commands with keybinds for main actions
            // Functionality explained in each action function
            .commands {
                CommandGroup(after: .saveItem) {
                    Button("Export to text file") {
                        exportCommand.send()
                    }
                }
                CommandMenu("Editor") {
                    Button("Delete") {
                        deleteAction()
                    }.keyboardShortcut(.delete, modifiers: [.shift])
                    
                    Button("Add Item") {
                        addItemAction()
                    }.keyboardShortcut(.return, modifiers: [])
                    
                    Button("Add Child") {
                        addChildAction()
                    }.keyboardShortcut(.return, modifiers: [.shift])
                    
                    Button("Indent") {
                        indentAction()
                    }.keyboardShortcut(.tab, modifiers: [])
                    
                    Button("Outdent") {
                        outdentAction()
                    }.keyboardShortcut(.tab, modifiers: [.shift])
                }
                CommandMenu("Node") {
                    Button("Toggle Children") {
                        toggleAction()
                    }
                    
                    Button("Font") {
                        fontAction()
                    }
                    
                    Button("Colors") {
                        // FIXME: Should open the color menu
                        // colorAction()
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
/**
 Helper function for finding a safe place to store the file. In production, it is intended to save to the user's documents folder.
 
 - Returns: A URL to the user's documents directory.
 */
func getDocumentsFolder() -> URL {
    // Find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // Just send back the first one, which ought to be the only one
    return paths[0]
}
