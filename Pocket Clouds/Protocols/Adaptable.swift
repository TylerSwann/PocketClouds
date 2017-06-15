//
//  Adaptable.swift
//  Pocket Clouds
//
//  Created by Tyler on 15/05/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

fileprivate struct ResizingMasks
{
    static let flexibleWidthHeight:UIViewAutoresizing = [.flexibleWidth, .flexibleHeight]
    static let flexibleWidthTop:UIViewAutoresizing = [.flexibleWidth, .flexibleTopMargin]
}

extension Adaptable
{
    func pinCollectionViewToSuperview(_ collectionView: UICollectionView)
    {
        if collectionView.superview != nil
        {
            collectionView.autoresizingMask = ResizingMasks.flexibleWidthHeight
        }
        else {print("Couldnt get superview for resizing mask")}
    }
    func pinToolbarToBottom(_ toolbar: UIToolbar)
    {
        if toolbar.superview != nil
        {
            toolbar.autoresizingMask = ResizingMasks.flexibleWidthTop
        }
        else {print("Couldnt get superview for resizing mask")}
    }
    func pinViewToSuperview(_ view: UIView)
    {
        if view.superview != nil
        {
            view.autoresizingMask = ResizingMasks.flexibleWidthHeight
        }
        else {print("Couldnt get superview for resizing mask")}
    }
    func collectionViewLayoutForCurrentDevice()
    {
        let layout = UICollectionViewFlowLayout()
        let currentModel = UIDevice.current.modelName
        switch (currentModel)
        {
        case .IPhone6, .IPhone6S, .IPhone7:
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 2, 2)
            layout.itemSize = CGSize(width: 92, height: 92)
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 0
            layout.headerReferenceSize = CGSize.zero
            layout.footerReferenceSize = CGSize.zero
        case .IPhone5, .IPhone5C, .IPhone5S, .IPhoneSE:
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
            layout.itemSize = CGSize(width: 78, height: 78)
            layout.minimumLineSpacing = 3
            layout.minimumInteritemSpacing = 0
            layout.headerReferenceSize = CGSize.zero
            layout.footerReferenceSize = CGSize.zero
        default:
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 2, 2)
            layout.itemSize = CGSize(width: 92, height: 92)
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 0
            layout.headerReferenceSize = CGSize.zero
            layout.footerReferenceSize = CGSize.zero
        }
    }
    //iphone5-(320.0, 568.0)
    //iphone6-(375, 667)
    func snapViewToSuperView(_ view: UIView)
    {
        view.snp.makeConstraints({make in
            make.edges.equalToSuperview()
        })
    }
}













