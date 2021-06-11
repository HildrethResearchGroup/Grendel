//
//  NodeTests.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/8/21.
//

import XCTest

class NodeTests: XCTestCase {
    
    var tree: Tree = Tree()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        tree = Tree()
        
        let nodeA = Node<String>(content: "A")
        tree.move(nodeA, toParent: tree.rootNode, at: 0)
        let nodeAB = Node<String>(content: "AB")
        tree.move(nodeAB, toParent: nodeA, at: 0)
        let nodeABC = Node<String>(content: "ABC")
        tree.move(nodeABC, toParent: nodeAB, at: 0)
        let nodeAC = Node<String>(content: "AC")
        tree.move(nodeAC, toParent: nodeA, at: 1)
        let nodeACD = Node<String>(content: "ACD")
        tree.move(nodeACD, toParent: nodeAC, at: 0)
        let nodeAA = Node<String>(content: "AA")
        tree.move(nodeAA, toParent: nodeA, at: 0)
        let nodeB = Node<String>(content: "B")
        tree.move(nodeB, toParent: tree.rootNode, at: 1)

        // In UI tests it’s important to set the initial state required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsertChild() throws {
        let nodeX = Node<String>(content: "X")
        tree.rootNode.children[1].insertChild(child: nodeX, at: 0)
        XCTAssert(tree.rootNode.children[1].children[0].content == "X")
    }
    
    func testRemoveChild() throws {
        tree.rootNode.children[0].removeChild(child: tree.rootNode.children[0].children[0])
        XCTAssert(tree.rootNode.children[0].children.count == 2)
    }
    
    func testCheckMaxDepth() throws {
        XCTAssert(tree.rootNode.checkMaxDepth() == 3)
    }
    
    func testGetIndexOfChild() throws {
        XCTAssert(tree.rootNode.children[0].indexOfChild(tree.rootNode.children[0].children[0]) == 0)
    }

}
