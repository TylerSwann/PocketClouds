//
//  CollectionViewController.swift
//  Pocket Clouds
//
//  Created by Tyler on 15/06/2017.
//  Copyright © 2017 TylerSwann. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewController: UIViewController,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate
{
    var collectionView: UICollectionView!
    private var cancelButton: UIBarButtonItem!
    
    func reuseIdentifier() -> String {return ""}
    
    override func viewDidLoad()
    {
        self.setup()
    }
    
    private func setup()
    {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 2, 2)
        layout.itemSize = CGSize(width: 92, height: 92)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        layout.headerReferenceSize = CGSize.zero
        layout.footerReferenceSize = CGSize.zero
        let collectionFrame = CGRect.init(origin: self.absoluteCenter, size: self.absoluteSize)
        self.collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        self.collectionView.center = self.absoluteCenter
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.setLeftBarButton(self.cancelButton, animated: false)
    }
    
    func registerCellClass(_ cellClass: AnyClass)
    {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: self.reuseIdentifier())
    }
    
    @objc private func cancel(){self.dismiss(animated: true, completion: nil)}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        return UICollectionViewCell()
    }
}










