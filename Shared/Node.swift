//
//  Node.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import SwiftUI

class Node<Content: Codable>: Identifiable, Codable {
    var content: Content
    private(set) var children = Array<Node>()
    private(set) var parent: Node? = nil
    let id = UUID()
    var selected: Bool = false
    var depth: Int {
        switch parent {
        case nil:
            return 0
        default:
            return parent!.depth + 1
        }
    }
    
    init(content: Content) {
        self.content = content
    }
    
    // MARK: modify node
    func insertChild(child: Node, at insertIndex: Int) {
        children.insert(child, at: insertIndex)
        child.parent = self
    }
    
    func removeChild(child: Node) {
        let indexToRemove = indexOfChild(child)
        children.remove(at: indexToRemove!)
        child.parent = nil
    }
    
    func copy() -> Node {
        return Node(content: content)
    }
    
    
    
    // MARK: info in node
    func indexOfChild(_ child: Node) -> Int? {
        for (index, nodesChild) in children.enumerated() {
            if child.id == nodesChild.id {
                return index
            }
        }
        return nil
    }
    
    // MARK: JSON encoding
    private enum CodingKeys : String, CodingKey {
        case children
        case content
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        children = try container.decode(Array<Node>.self, forKey: .children)
        content = try container.decode(Content.self, forKey: .content)
        for child in children {
            child.parent = self
        }
        selected = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(children, forKey: .children)
        try container.encode(content, forKey: .content)
    }
    
    //MARK: Text settings
    struct TextSettings {
        private(set) var isBold: Bool
        private(set) var isItalicized: Bool
        private(set) var foregroundColor: Color
        private(set) var highlightColor: Color?
        private(set) var font: Font
        
        init() {
            isBold = false
            isItalicized = false
            foregroundColor = .black
            highlightColor = nil
            font = .system(.body)
        }
        
        func getFont() -> Font {
            // apply bolding, italics, etc. to a copy of the font
            var stylizedFont: Font
            stylizedFont = font
            
            // apply modifiers based on values
            if isBold {
                stylizedFont = stylizedFont.bold()
            }
            
            if isItalicized {
                stylizedFont = stylizedFont.italic()
            }
            
            return stylizedFont
        }
        
        mutating func setBold(_ boolean: Bool) {
            isBold = boolean
        }
        
        mutating func setItalicized(_ boolean: Bool) {
            isItalicized = boolean
        }
        
        mutating func setFont(_ newFont: Font) {
            font = newFont
        }
        
        mutating func setForeground(color: Color) {
            foregroundColor = color
        }
        
        mutating func setHighlight(color: Color) {
            highlightColor = color
        }
        
        // TODO: reset font settings function
    }
}
