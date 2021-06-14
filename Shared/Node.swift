//
//  Node.swift
//  Outliner
//
//  Created by Emily Hepperlen on 5/24/21.
//

import SwiftUI

class Node<Content: Codable>: Identifiable, Codable, ObservableObject {
    @Published var content: Content
    @Published var textSettings: TextSettings = TextSettings()
    @Published private(set) var children = Array<Node>()
    private(set) var parent: Node? = nil
    let id = UUID()
    @Published var selected: Bool = false
    @Published var childrenShown: Bool = true
    @Published var width : CGFloat
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
    
    init(content: Content, width: CGFloat) {
        self.content = content
        self.width = width
    }
    
    private init(content: Content, textSettings: TextSettings, childrenShown: Bool, width: CGFloat) {
        self.content = content
        self.textSettings = textSettings
        self.childrenShown = childrenShown
        self.width = width
        
    }
    
    func updateLevelWidths(level: Int, width: CGFloat){
        if(depth == level){
            self.width = width
        }else{
            for node in children{
                node.updateLevelWidths(level: level, width: width)
            }
        }
    }
    
    func getLevelWidths(level: Int) -> CGFloat{
        var size: CGFloat = 0.0
        
        if(depth == 1+level){
            for node in children{
                size = node.width
            }
            
            if(size == 0.0){
                size = (parent?.getLevelWidths(level: level))!
            }
        }else if(depth == level){
            size = (parent?.getLevelWidths(level: level))!
        }else{
            
        }
        
        return size
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
        return Node(content: content, width: width)
    }
    
    func copyAll() -> Node {
        var copiedChildren = Array<Node>()
        
        for child in children {
            copiedChildren.append(child.copyAll())
        }
        
        return Node(content: self.content,
                    textSettings: self.textSettings,
                    childrenShown: self.childrenShown, width: width)
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
        self.width = 100.0
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
    class TextSettings: ObservableObject {
        @Published private(set) var weight: Font.Weight
        @Published public var isItalicized: Bool
        @Published private(set) var foregroundColor: Color?
        @Published private(set) var highlightColor: Color?
        
        // font is private to force users to use getFont() which applies formatting on call
        private var font: Font
        
        init() {
            weight = .regular
            isItalicized = false
            foregroundColor = Color("Inverted")
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
        
        func setWeight(_ newWeight: Font.Weight) {
            weight = newWeight
        }
        
        func setItalicized(_ boolean: Bool) {
            isItalicized = boolean
        }
        
        func setFont(_ newFont: Font) {
            font = newFont
        }
        
        func setForeground(color: Color) {
            foregroundColor = color
        }
        
        func setHighlight(color: Color) {
            highlightColor = color
        }
        
        // TODO: reset font settings function
        func reset() {
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
