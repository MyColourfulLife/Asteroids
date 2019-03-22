//
//  AsteroidView.swift
//  Asteroids
//
//  Created by JiaShu Huang on 2019/3/21.
//  Copyright © 2019 JiaShu Huang. All rights reserved.
//

import UIKit

class AsteroidView: UIImageView {

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        image = UIImage(named: "asteroid\((arc4random()%9)+1)")
        frame.size = image?.size ?? CGSize.zero
    }

}
