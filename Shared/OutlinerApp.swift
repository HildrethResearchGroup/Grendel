//
//  OutlinerApp.swift
//  Shared
//
//  Created by Mines CS Field Session Student on 5/24/21.
//

import SwiftUI

@main
struct OutlinerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: OutlinerDocument()) { file in
            ContentView(document: file.$document)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
        .commands{
            CommandMenu("Editor"){
                Button("Delete"){
                    deleteAction()
                }
                Button("Add Item"){
                    addItemAction()
                }
                Button("Add Child"){
                    addChildAction()
                }
                Button("Indent"){
                    indentAction()
                }
                Button("Outdent"){
                    outdentAction()
                }
            }
            CommandMenu("Node"){
                Button("Edit Node"){
                    editAction()
                }
                Button("Toggle Children"){
                    toggleAction()
                }
                Button("Label"){
                    labelAction()
                }
            }
            CommandMenu("Text"){
                Button("Colors"){
                    colorAction()
                }
                Button("Font"){
                    fontAction()
                }
            }
        }
    }
}
