//
//  DragBar.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/7/21.
//

import SwiftUI

struct DragBar: View {
    //ColorScheme allows to change UI features based on light or dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    //Requires a tree object
    @ObservedObject var tree: Tree
    
    var body: some View {
        
        //Holds the dividers, the rectangle frames the dragbar.
        return ZStack(){
            Rectangle()
                .opacity(0)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(colorScheme == .dark ? Color.black: Color.white), alignment: .bottom)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(colorScheme == .dark ? Color.black: Color.white), alignment: .top)
            
            GeometryReader{ geometry in
                HStack(){
                    //Creates the first DragDivider
                    DragDivider(tree: tree, dividerNumber: 0)
                        .offset(x: tree.levelWidths[0])
                }
            }
        }
    }
    
}
