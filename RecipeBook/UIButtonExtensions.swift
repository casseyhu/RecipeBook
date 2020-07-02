//
//  UIButtonExtensions.swift
//  RecipeBook
//
//  Created by Cassey Hu on 7/1/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit

/**
    UIButton extension to perform animations
 */
extension UIButton {
    
    /// Perform pulsating animation for a button
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.98
        pulse.toValue = 1.3
        pulse.autoreverses = true
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
    }
}
