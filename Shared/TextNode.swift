//
//  TextNode.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import Foundation

class TextNode: Node {
    // The content for a TextNode
    var text: String = ""
    
    
    init(text: String) {
        super.init()
        self.text = text
    }
    
    // MARK: modify text node
    override func copy() -> Node{
        return TextNode(text: text)
    }
}
