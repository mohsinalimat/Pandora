///////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2015 Matteo Pacini                                              //
//                                                                               //
// Permission is hereby granted, free of charge, to any person obtaining a copy  //
// of this software and associated documentation files (the "Software"), to deal //
// in the Software without restriction, including without limitation the rights  //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     //
// copies of the Software, and to permit persons to whom the Software is         //
// furnished to do so, subject to the following conditions:                      //
//                                                                               //
// The above copyright notice and this permission notice shall be included in    //
// all copies or substantial portions of the Software.                           //
//                                                                               //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     //
// THE SOFTWARE.                                                                 //
///////////////////////////////////////////////////////////////////////////////////

import UIKit

//Expanded Layout.
//
//One item per row, and item.width == collectionView.width
class CollectionViewExpandedFlowLayout : UICollectionViewFlowLayout {
     
    override func prepare() {
        
        self.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0)
        
        let collectionViewWidth =
        self.collectionView?.bounds.size.width
        
        let itemWidth : CGFloat = collectionViewWidth!
        
        self.itemSize = CGSize(width: itemWidth,
            height: self.collectionView!.frame.height * 0.80)
        
    }
    
}

