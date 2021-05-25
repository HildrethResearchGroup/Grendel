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
    }
}
