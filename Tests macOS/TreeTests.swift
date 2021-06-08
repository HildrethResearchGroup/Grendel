//
//  TreeTests.swift
//  Tests iOS
//
//  Created by Mines CS Field Session Student on 6/8/21.
//

import XCTest

class TreeTests: XCTestCase {
    
    var tree: Tree = Tree()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
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

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIndent() throws {
        //print(tree.rootNode.children[1].content)
        
        tree.indent(node: tree.rootNode.children[1])
        
        XCTAssert(tree.rootNode.children[0].children[3].content == "B", "Indent not working correctly, node name was " + tree.rootNode.children[0].children[3].content)
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testOutdent() throws{
        tree.outdent(node: tree.rootNode.children[0].children[0])
        
        XCTAssert(tree.rootNode.children[1].content == "AA", " Outdent not working correctly, node name was " + tree.rootNode.children[1].content)
    }
    
    
    func testCopySubtree() throws{
        let NodeXYZ = tree.copySubtree(rootOfSubtree: tree.rootNode.children[0].children[1])
        tree.move(NodeXYZ, toParent: tree.rootNode.children[1], at: 0)
        
        XCTAssert(tree.rootNode.children[1].children[0].content == "AB", "Copy subtree  not working correctly, begining node was " + tree.rootNode.children[1].children[0].content)
        XCTAssert(tree.rootNode.children[1].children[0].children[0].content == "ABC", "Copy Subtree not working correctly, child node was " + tree.rootNode.children[1].children[0].children[0].content)
    }
    
    

}
