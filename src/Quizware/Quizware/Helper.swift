//
//  Helper.swift
//  Quizware
//
//  Created by TechReviews on 1/11/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -8),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            topAnchor.constraint(equalTo: view.topAnchor, constant: -8),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8)
            ])
    }
}
