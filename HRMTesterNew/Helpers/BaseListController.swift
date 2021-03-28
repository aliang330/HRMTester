//
//  BaseListController.swift
//  AppStore
//
//  Created by Allen on 4/2/20.
//  Copyright © 2020 Allen. All rights reserved.
//

import UIKit


class BaseListController: UICollectionViewController {

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
