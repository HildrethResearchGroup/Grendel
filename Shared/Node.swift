//
//  Node.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import SwiftUI

class Node<Content: Codable>: Identifiable, Codable, ObservableObject {
    var content: Content
    var textSettings: TextSettings = TextSettings()
    private(set) var children = Array<Node>()
    private(set) var parent: Node? = nil
    let id = UUID()
    @Published var selected: Bool = false
    @Published var childrenShown: Bool = true
    var depth: Int {
        switch parent {
        case nil:
            return 0
        default:
            return parent!.depth + 1
        }
    }
    var firstChild: Bool {
        return parent!.indexOfChild(self) == 0
    }
    var lastChild: Bool {
        return parent!.indexOfChild(self) == parent!.children.endIndex - 1
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
    
    func getParent() -> Node{
        return self.parent!
    }
  
    func checkMaxDepth() -> Int{
        if(children.count == 0){
            return depth
        }else{
            var maxValue = 0
            for child in children{
                let tempValue = child.checkMaxDepth()
                if( tempValue > maxValue ){
                    maxValue = tempValue
                }
                
            }
            return maxValue
            
        }
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
        textSettings = TextSettings()
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
        private(set) var weight: Font.Weight
        private(set) var isItalicized: Bool
        private(set) var isUnderlined: Bool
        private(set) var foregroundColor: Color?
        private(set) var highlightColor: Color?
        
        // font is private to force users to use getFont() which applies formatting on call
        private var font: Font
        
        init() {
            weight = .regular
            isItalicized = false
            isUnderlined = false
            foregroundColor = nil
            highlightColor = nil
            font = .system(.body)
        }
        
        // this function returns a copy of the font with appropriate modifiers
        func getFont() -> Font {
            // apply bolding, italics, etc. to a copy of the font
            var stylizedFont: Font
            stylizedFont = font
            
            stylizedFont =  stylizedFont.weight(weight)
            
            if isItalicized {
                stylizedFont = stylizedFont.italic()
            }
            
            return stylizedFont
        }
        
        mutating func setWeight(_ newWeight: Font.Weight) {
            weight = newWeight
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
        
        mutating func setUnderline(_ boolean: Bool) {
            isUnderlined = boolean
        }
        
        // TODO: reset font settings function
        mutating func reset() {
            weight = .regular
            isItalicized = false
            foregroundColor = .black
            highlightColor = nil
            font = .system(.body)
        }
    }
}

extension Node: Equatable {
    static func == (lhs: Node<Content>, rhs: Node<Content>) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
