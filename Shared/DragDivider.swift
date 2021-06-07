//
//  DragDivider.swift
//  Outliner
//
//  Created by Mines CS Field Session Student on 6/7/21.
//

import SwiftUI

struct DragDivider : View{
    
    //viewState records where the divider has been moved to
    @State private var viewState = CGSize.zero
    //ColorScheme allows for UI light and dark differentiation
    @Environment(\.colorScheme) var colorScheme
    
    //Requires the tree and which divider it is.
    @ObservedObject var tree: Tree
    var dividerNumber : Int
    
    var body: some View{
        //HStack contains the current divider and all subsequent dividers
        HStack{
            
            //ZStack contains the divider and an invisible rectangle that increases the size of the clicking area for the dividers.
            ZStack{
                
                Divider()
                Rectangle()
                    .frame(width: 20)
                    .opacity(0.00000000000001)
                    .foregroundColor(colorScheme == .dark ? Color.black: Color.white)
                
            }
            
            //Creates more DragDividers based on the number of levels.
            if(dividerNumber < tree.levelWidths.count - 1){
                DragDivider(tree: tree, dividerNumber: dividerNumber + 1)
                    .offset(x: tree.levelWidths[dividerNumber + 1])
            }
        }
        //Gesture recognition
        .offset(x: viewState.width, y: viewState.height)
        .gesture(
            DragGesture().onChanged { value in
                //Sets minimum space from previous divider.
                if(value.location.x > 20 - tree.levelWidths[dividerNumber]){
                    viewState = CGSize(width: value.location.x, height: 0)
                }
                else{
                    viewState = CGSize(width: 20 - tree.levelWidths[dividerNumber], height: 0)
                    
                }
                //Records the current widths of the dividers so that the tree class can space its nodes.
                tree.currentWidths[dividerNumber] = tree.levelWidths[dividerNumber] + viewState.width
                
            })
    }
}
