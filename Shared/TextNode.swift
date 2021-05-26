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
    
    // MARK: JSON encoding
    private enum CodingKeys : String, CodingKey {
        case text
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
        text = try container.decode(String.self, forKey: .text)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
    }
}
