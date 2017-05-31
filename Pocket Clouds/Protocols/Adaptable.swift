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

extension Adaptable
{
    func pinViewToSuperView(_ view: UIView)
    {
        view.snp.makeConstraints({make in
            make.edges.equalToSuperview()
        })
    }
}
