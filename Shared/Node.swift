//
//  Node.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

class Node: Identifiable {
    var text: String = ""
    var children: [Node]? = nil
    var parent: Node? = nil
    let id = UUID()
    // TODO: where/how should this be put?
    //var fontSettings = FontSettings()
    
    init(text: String) {
        self.text = text
    }
}

// TODO: where/how should this be put?
/*struct FontSettings {
    var isBold: Bool = false
    var isItalic: Bool = false
    var fontColor: String? = nil
    var fontFamily: String? = nil
    var fontSize: Int? = nil
}*/
